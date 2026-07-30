class_name BuildTowerButton extends TextureButton

## Signals

signal update_towers(update_data : ModUpdateData) 
signal create_draggable(
	tower_mod: ModPrototype, 
	initial_pos : Vector2, 
	slot_occupied : TowerButtonModSlot,
	is_dragging : bool,
	)

## Setup

@onready var mod_slot_scene := preload("res://GameData/UI/GUI/Scenes/tower_button_mod_slot.tscn")
@onready var mod_draggable_scene := preload("res://GameData/UI/GUI/Scenes/mod_draggable.tscn")
const TOWER_CELL_TEXTURE := preload("res://Assets/Towers/towerDefense_tile181.png")

@export var build_cost_label : Label
@export var net_power_display : Label
@export var mod_slot_container : Container
@export var tower_icon_container :Container
@export var pwr_icon : TextureRect
@export var button_data : TowerButtonData #contains mod slot data, slot count, and id
@export var slot_radius : float = 64
var slot_data_ref : Dictionary
var button_slots : Array =[]
var cell_size : int

## Gametime Functions

var build_cost : int : 
	set(value): 
		build_cost = 1 + value * 3 #value should always be slot count
		build_cost_label.text = "$" + str(build_cost)
var tower_data : TowerBuildData : get = get_tower_mods

#################
### Functions ###
#################

## Setup

func _ready() -> void:
	set_tower_icons()
	for i in button_data.slot_count:
		new_mod_slot(i)
		if SaveManager.save_data_run.new_game:
			button_data.mod_data[get_slot_id(i)] = null
		on_mod_update(get_slot_id(i))
	build_cost = button_data.tower_shape.size()
	pwr_icon.modulate.a = 0.5

func set_tower_icons() -> void:
	for child in tower_icon_container.get_children():
		child.queue_free()
	for cell in button_data.tower_shape:
		var new_cell = TextureRect.new()
		new_cell.texture = TOWER_CELL_TEXTURE
		new_cell.scale = Vector2(0.5, 0.5)
#		new_cell.pivot_offset_ratio = Vector2(1, 1)
		tower_icon_container.add_child(new_cell)
		new_cell.position = get_coords_from_vectors(cell, 0.5)

func new_mod_slot(slot_num: int) -> void:
	var new_slot = mod_slot_scene.instantiate()
	new_slot.mod_updated.connect(on_mod_update)
	new_slot.slot_id = get_slot_id(slot_num)
	button_slots.append(new_slot)
	mod_slot_container.add_child(new_slot)
	new_slot.position = get_coords_from_vectors(button_data.tower_shape[slot_num], 0.75)
#	set_slot_position(new_slot, slot_num)
	if button_data.mod_data.has(new_slot.slot_id) and button_data.mod_data[new_slot.slot_id] != null:
		new_slot.occupied = true
		create_draggable.emit(button_data.mod_data[new_slot.slot_id], new_slot.global_position, new_slot, false)

func get_slot_id(slot_num: int) -> int:
	return button_data.button_id * 10 + slot_num

func get_coords_from_vectors(cell: Vector2i, ratio : float) -> Vector2:
	@warning_ignore("integer_division")
	return Vector2(cell.x * cell_size * ratio, cell.y * cell_size * ratio)

## In-Game

##Returns RefCounted of type TowerBuildData containing tower data stored in button,
##specifically, aura status, mod_data, 
func get_tower_mods() -> TowerBuildData:
	var power_surplus_buffs : Dictionary
	var has_wep := false
	var has_aura := false
	
	for child in button_slots: #adds mods to data Dictionary and checks if it is an aura tower
		var child_data = button_data.mod_data[child.slot_id]
		if not has_wep and child_data != null:
			if child_data.mod_class == child_data.ModClass.WEAPON:
				has_wep = true
			elif child_data.mod_class == child_data.ModClass.AURA:
				has_aura = true
		if child_data is ModPower:
			var stat_name : String = ""
			for stat in GlobalEnums.BuffableStats.keys():
				for i in child_data.power_surplus_buffable_stats:
					if i & GlobalEnums.BuffableStats[stat]:
						stat_name = stat.to_lower()
						if not power_surplus_buffs.has(stat_name):
							power_surplus_buffs[stat_name] = 0
						power_surplus_buffs[stat_name] += 1
	
	return TowerBuildData.new(
		has_aura and not has_wep, 
		button_data.mod_data, 
		power_surplus_buffs,
		button_data.tower_shape)

func on_mod_update(slot_id : int, data : ModPrototype = button_data.mod_data[slot_id]) -> void:
	var net_power := 0
	var power_surplus_buffs : Dictionary = {}
	var has_aura := false
	var has_wep := false
	
	
	button_data.mod_data[slot_id] = data
	
	for child in button_slots:
		var child_data = button_data.mod_data[child.slot_id]
		if child_data != null:
			net_power += child_data.base_power_levels[0]
			match child_data.mod_class: 
				0: #Aura
					has_aura = true
				1: #Power
					var stat_name : String = ""
					for stat in GlobalEnums.BuffableStats.keys():
						for i in child_data.power_surplus_buffable_stats:
							if i & GlobalEnums.BuffableStats[stat]:
								stat_name = stat.to_lower()
								if not power_surplus_buffs.has(stat_name):
									power_surplus_buffs[stat_name] = 0
								power_surplus_buffs[stat_name] += 1
				2: #Weapon
					has_wep = true
	
	update_towers.emit(ModUpdateData.new(
		has_aura and not has_wep, 
		power_surplus_buffs, 
		slot_id, 
		data))
	
	net_power_display.text = str(net_power)

func _on_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)

func _on_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
