class_name TowerBase extends Node2D
##Handles tower setup and updates to tower mods

signal unit_selected(tower_cell : TowerCell)
signal show_upgrade_panel(popup_type : String, tower_data, tower_id : TowerBase)
signal update_mods(net_power : int)
signal clear_popup
signal update_range_display(tower_cell: TowerCell)
signal hide_range_display

## Setup
@export var non_aura_radius : float = 10
const COLUMNS : int = 3
const ROWS : int = 3
const CELL_SIZE : int = 64

var grid_size : int : 
	get():
		return CELL_SIZE * COLUMNS

const MAX_LEVEL = 4
var mod_slot_count : int = 0 #set during verify and build Game Scene function
var build_data : Dictionary
var tower_data : TowerBaseData

## Gameplay
const TOWER_CELL_PROTO : PackedScene = preload("res://GameData/Towers/Scenes/tower_cell.tscn")
const POPUP_TYPE : String = "tower"
var aura_tower : bool
var is_built := false
var net_power : int = 0
var clickable := false
var tower_children : Array = []


## Setup
func _ready() -> void:
	var tower_mods : Dictionary = build_data["mods"]
	var init_power_buffs : Dictionary = build_data["power_buffs"]
	tower_data.tower_shape = build_data["shape"]
	aura_tower = build_data["aura_tower"]
	mod_slot_count = tower_data.tower_shape.size() 
	
	#var mod_list = tower_mods.keys()
	for i in mod_slot_count:
		var new_cell = TOWER_CELL_PROTO.instantiate()
		var slot_id : int = tower_data.connected_button_id * 10 + i
		new_cell.position = get_coords_from_vectors(tower_data.tower_shape[i])
		if is_built and tower_mods[slot_id] != null:
			new_cell.data = tower_mods[slot_id].duplicate(true)
			if tower_data.level > 0:
				new_cell.data.setup_stats(tower_data.level)
		new_cell.button_slot_id = slot_id
		update_mods.connect(new_cell.update_mod)
		new_cell.unit_selected.connect(tower_selected)
		new_cell.update_range_display.connect(update_range_display_received)
		new_cell.hide_range_display.connect(hide_range_display_received)
		new_cell.non_aura_radius = non_aura_radius
		tower_children.append(new_cell)
		add_child(new_cell)
	tower_update(aura_tower, init_power_buffs)
	await get_tree().create_timer(0.25).timeout
	clickable = true

##currently unused
func get_coords_from_mod_data(button_id: int) -> Vector2:
	@warning_ignore("integer_division")
	return Vector2i(button_id / 10 * CELL_SIZE, button_id % 10 * CELL_SIZE)

func get_coords_from_vectors(cell: Vector2i) -> Vector2:
	@warning_ignore("integer_division")
	return Vector2(cell.x * CELL_SIZE, cell.y * CELL_SIZE)

func get_slot_id(_value: int) -> void:
	
	pass

## Gameplay
func tower_selected(tower_cell) -> void:
	if clickable:
		var mod_data : Array
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

func tower_update(
	aura_status: bool, 
	power_surplus_buffs : Dictionary,
	button_slot_id: int = 0, 
	button_mod_data: PrototypeMod = null, 
	) -> void:
	
	var mod_list : Dictionary = {0 : [], #Aura
								 1 : [], #Power
								 2 : []} #Weapon
	
	aura_tower = aura_status
	net_power = 0
	
	for child in tower_children: 
		if button_slot_id == child.button_slot_id:
			if child.data != null and child.data.mod_class == child.data.ModClass.AURA: #Aura
				for target in child.aura_targets: #clears aura effects of old aura before updating
					child.remove_buff(target)
				child.aura_targets = []
			if button_mod_data != null: #set tower mod's data
				child.data = button_mod_data.duplicate(true)
				child.data.data_owner = child
				if child.data.swap_enabled:
					if child.data.swap_buff == null or child.data.swap_buff_duration == 0.0:
						print("Swapper enabled with incomplete swap data for ", child.data.name)
					else:
						child.data.add_buff(child.data.swap_buff, child, tower_data.level)
			else:
				child.data = null
		if child.data != null:
			mod_list[child.data.mod_class].append(child)
			child.data.setup_stats(tower_data.level)
			net_power += child.data.current_power
			child.data.power_surplus_buffs = power_surplus_buffs
	
	if not aura_tower and mod_list[0].size() > 0:
		apply_auras(mod_list)
	
	update_mods.emit(net_power)
	
	#if low power, set low power display

func apply_auras(mod_list: Dictionary) -> void:
	#add aura effects to any weapon mods in the same tower
	for aura in mod_list[0]:
		for wep in mod_list[2]:
			wep.data.add_buff(aura.data.buff_data, aura, tower_data.level)

func clear_popup_received() -> void:
	clear_popup.emit()

func update_range_display_received(tower_cell: TowerCell) -> void:
	update_range_display.emit(tower_cell)

func hide_range_display_received() -> void:
	hide_range_display.emit()
