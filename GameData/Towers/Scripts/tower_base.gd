class_name TowerBase extends Node2D
##Handles tower setup and updates to tower mods

signal show_upgrade_panel(popup_type : String, tower_data, tower_id : TowerBase)
signal update_mods(net_power : int)

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
var all_marker_pos : Dictionary[Marker2D,Vector2]
var build_data : Dictionary
var tower_data : TowerBaseData

## Gameplay
const TOWER_MOD_PROTO : PackedScene = preload("res://GameData/Towers/Scenes/tower_mod.tscn")
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
	
	var mod_list = tower_mods.keys()
	for i in mod_slot_count:
		var new_mod = TOWER_MOD_PROTO.instantiate()
		new_mod.position = get_coords_from_vectors(tower_data.tower_shape[i])
		if is_built and tower_mods[mod_list[i]] != null:
			new_mod.data = tower_mods[mod_list[i]].duplicate(true)
			if tower_data.level > 0:
				new_mod.data.setup_stats(tower_data.level)
		new_mod.button_slot_id = mod_list[i]
		update_mods.connect(new_mod.update_mod)
		new_mod.tower_clicked.connect(tower_clicked)
		new_mod.non_aura_radius = non_aura_radius
		tower_children.append(new_mod)
		add_child(new_mod)
	tower_update(aura_tower, init_power_buffs)
	await get_tree().create_timer(0.25).timeout
	clickable = true

func get_coords_from_mod_data(button_id: int) -> Vector2:
	@warning_ignore("integer_division")
	return Vector2i(button_id / 10 * CELL_SIZE, button_id % 10 * CELL_SIZE)

func get_coords_from_vectors(cell: Vector2i) -> Vector2:
	@warning_ignore("integer_division")
	return Vector2(cell.x * CELL_SIZE, cell.y * CELL_SIZE)


## Gameplay
func tower_clicked() -> void:
	if clickable:
		var mod_data : Array
		for child in tower_children:
			if child.data != null:
				mod_data.append(child.data)
		show_upgrade_panel.emit(POPUP_TYPE, mod_data, self)

func _unhandled_key_input(event: InputEvent) -> void:
	if is_built:
		return
	if event.is_action_pressed("rotate_counterclockwise"):
		var tween = get_tree().create_tween()
		tween.tween_property(self, "rotation", rotation - PI/2, 0.1)
		tower_data.rotation = rotation
		#counter rotate mod image
		return
	if event.is_action_pressed("rotate_clockwise"):
		var tween = get_tree().create_tween()
		tween.tween_property(self, "rotation", rotation + PI/2, 0.1)
		tower_data.rotation = rotation
		#counter rotate mod image
		return

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
	
	aura_tower = aura_status
	net_power = 0
	
	for child in tower_children: 
		if button_slot_id == child.button_slot_id:
			if child.data != null and child.data.mod_class == child.data.ModClass.AURA: 
				for body in child.aura_targets: #clears aura effects of old aura before updating
					child.clear_buffs(body)
				child.aura_targets = []
			if button_mod_data != null: #set tower mod's data
				child.data = button_mod_data.duplicate(true)
				child.data.buff_owner = child
				if child.data.swap_enabled:
					if child.data.swap_buff == null or child.data.swap_buff_duration == 0.0:
						print("Swapper enabled with incomplete swap data for ", child.data.name)
					else:
						child.data.add_buff(child.data.swap_buff)
			else:
				child.data = null
		if child.data != null:
			child.data.setup_stats(tower_data.level)
			net_power += child.data.current_power
			child.data.power_surplus_buffs = power_surplus_buffs

	
	update_mods.emit(net_power)
	#if low power, set low power display

func apply_auras(buff: Buff) -> void:
	#add aura effects to any weapon mods in the same tower
	for child in tower_children:
		if child.data.mod_class == child.data.ModClass.WEAPON:
			child.data.add_buff(buff)
	pass
