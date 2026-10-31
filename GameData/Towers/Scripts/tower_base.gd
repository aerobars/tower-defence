##Handles tower setup and updates to tower mods
class_name TowerBase extends Node2D

signal cell_created(tower_cell: TowerCell)
signal unit_selected(tower_cell: TowerCell)
signal show_upgrade_panel(popup_type: String, tower_data, tower_id: TowerBase)
signal update_mods(net_power: int) #connected to cells within the towewr
signal clear_popup
signal update_range_display(tower_cell: TowerCell)
signal hide_range_display

## Setup
@export var non_aura_radius: float = 10
const COLUMNS: int = 3
const ROWS: int = 3
var cell_size: int #set to Map Node CELL_SIZE in Game Scene via Build Mode Container

var grid_size: int : 
	get():
		return cell_size * COLUMNS

const MAX_LEVEL = 4
var mod_slot_count: int = 0 #set during verify and build Game Scene function
var build_data: TowerBuildData
var tower_data: TowerBaseData

## Gameplay
const TOWER_CELL_PROTO: PackedScene = preload("res://GameData/Towers/Scenes/tower_cell.tscn")
const POPUP_TYPE: String = "tower"
var aura_tower: bool
var is_built:= false
var net_power: int = 0
var clickable:= false
var tower_children: Array = []


## Setup
func _ready() -> void:
	var init_power_buffs: Dictionary = build_data.power_buffs
	aura_tower = build_data.aura_tower
	tower_data.tower_shape = build_data.shape
	mod_slot_count = tower_data.tower_shape.size() 
	cell_size = build_data.cell_size
	
	#var mod_list = tower_mods.keys()
	for i in mod_slot_count:
		tower_cell_setup(i)
	
	tower_update(ModUpdateData.new(aura_tower, init_power_buffs))
	await get_tree().create_timer(0.25).timeout
	clickable = true

func tower_cell_setup(cell_num) -> void:
	var tower_mods: Dictionary = build_data.mods
	var new_cell := TOWER_CELL_PROTO.instantiate()
	var slot_id: int = tower_data.connected_button_id * 10 + cell_num
		
	new_cell.position = get_coords_from_vectors(tower_data.tower_shape[cell_num])
	new_cell.button_slot_id = slot_id
	new_cell.non_aura_radius = non_aura_radius
	
	if is_built:
		cell_created.emit(new_cell)
		update_mods.connect(new_cell.setup_mod)
		new_cell.unit_selected.connect(tower_selected)
		new_cell.update_range_display.connect(update_range_display_received)
		new_cell.hide_range_display.connect(hide_range_display_received)
		if tower_mods[slot_id] != null:
			new_cell.data = tower_mods[slot_id].duplicate(true)
			if tower_data.level > 0:
				new_cell.data.setup_stats(tower_data.level)
	
	tower_children.append(new_cell)
	add_child(new_cell)

##currently unused
func get_coords_from_mod_data(button_id: int) -> Vector2:
	@warning_ignore("integer_division")
	return Vector2i(button_id / 10 * cell_size, button_id % 10 * cell_size)

func get_coords_from_vectors(cell: Vector2i) -> Vector2:
	@warning_ignore("integer_division")
	return Vector2(cell.x * cell_size, cell.y * cell_size)

func get_slot_id(_value: int) -> void:
	
	pass

## Gameplay

func tower_selected(tower_cell) -> void:
	if clickable:
		var mod_data: Array
		for child in tower_children:
			if child.data != null:
				mod_data.append(child.data)
			#child.set_tower_highlight(true)
		show_upgrade_panel.emit(POPUP_TYPE, mod_data, self)
		unit_selected.emit(tower_cell)

func level_up() -> void:
	tower_data.level = min(tower_data.level + 1, MAX_LEVEL)
	for child in tower_children:
		if child.data != null:
			child.data.setup_stats(tower_data.level)

##Called during tower setup and mod updates
func tower_update(updated_mod_data: ModUpdateData) -> void:
	
	var updating_cell: TowerCell
	var mod_list: Dictionary = {0: [], #Aura
								1: [], #Power
								2: []} #Weapon
	
	net_power = 0
	
	for child in tower_children: 
		if updated_mod_data.slot_id == child.button_slot_id:
			updating_cell = child #for apply_local_auras
			
			#clears aura effects of old aura before updating
			if child.data != null and child.data.mod_class == child.data.ModClass.AURA: #Aura
				for target in child.aura_targets: 
					target.remove_effect(child.data.buff_data, child)
				child.aura_targets = []
			
			#clears mod data if updated mod slot is empty
			if updated_mod_data.slot_data == null: 
				child.data = null
			
			#set updating cell's mod data
			else: 
				child.data = updated_mod_data.slot_data.duplicate(true)
				child.data.data_owner = child
				if child.data.swap_enabled:
					if child.data.swap_buff == null or child.data.swap_buff_duration == 0.0:
						print("Swapper enabled with incomplete swap data for ", child.data.name)
					else:
						child.add_effect(child.data.swap_buff, child, tower_data.level)
				for ability in child.data.innate_abilities:
					child.add_ability(ability)
		
		#update tower base data
		if child.data != null: 
			mod_list[child.data.mod_class].append(child)
			child.data.setup_stats(tower_data.level)
			net_power += child.data.current_power
			child.data.power_surplus_buffs = updated_mod_data.power_surplus_buffs
	
	#add aura effects to any weapon mods in the same tower
	if is_built and updated_mod_data.slot_data != null and not updated_mod_data.aura_status: #check this over aura_tower because it's more up to date during update
		apply_local_auras(updated_mod_data.aura_status, mod_list, updating_cell)
	aura_tower = updated_mod_data.aura_status
	
	#connected to base's tower cells to complete their update
	update_mods.emit(net_power)
	
	#if low power, set low power display

func apply_local_auras(updated_aura_status: bool, mod_list: Dictionary, updated_cell: TowerCell) -> void:
	#for all outcomes, tower must not be an aura tower
	
	#apply auras when: 
	#tower is no longer aura tower > apply aura effect to other auras and all weapon mods
	if aura_tower != updated_aura_status: #tower is no longer an aura tower
			for aura in mod_list[0]:
				for other_aura in mod_list[0]:
					if aura == other_aura: #skips adding aura effect to itself
						continue
					else: 
						aura.add_effect(aura.data.buff_data, aura, tower_data.level)
				for wep in mod_list[2]:
					wep.add_effect(aura.data.buff_data, aura, tower_data.level)
	
	#new aura is added > apply new aura to other auras and weapon mods, apply existing auras to new aura
	elif updated_cell.data is ModAura:
		for aura in mod_list[0]:
			if aura.button_slot_id != updated_cell.button_slot_id:
				aura.add_effect(updated_cell.data.buff_data, updated_cell, tower_data.level)
				updated_cell.add_effect(aura.data.buff_data, aura, tower_data.level)
		for wep in mod_list[2]:
			wep.add_effect(updated_cell.data.buff_data, updated_cell, tower_data.level)
	
	#new weapon is added > apply all auras to new weapon mod
	elif updated_cell.data is ModWeapon:
		for aura in mod_list[0]:
			updated_cell.add_effect(aura.data.buff_data, aura, tower_data.level)

func clear_popup_received() -> void:
	clear_popup.emit()

func update_range_display_received(tower_cell: TowerCell) -> void:
	update_range_display.emit(tower_cell)

func hide_range_display_received() -> void:
	hide_range_display.emit()
