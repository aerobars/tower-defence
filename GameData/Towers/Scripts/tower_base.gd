class_name TowerBase extends StaticBody2D

signal show_upgrade_panel(popup_type : String, tower_data, tower_id : TowerBase)
signal update_mods(net_power : int)

## Setup
@export var marker_pos_radius : float = 10
const MAX_LEVEL = 4
var mod_slot_count : int = 0 #set during verify and build Game Scene function
var all_marker_pos : Dictionary[Marker2D,Vector2]
var marker_keys : Array
var build_data : Dictionary
var tower_mods : Dictionary
var build_keys : Array
var init_power_buffs : Dictionary
var tower_id : String

## Gameplay
const TOWER_MOD_PROTO : PackedScene = preload("res://GameData/Towers/tower_mod.tscn")
const POPUP_TYPE : String = "tower"
var aura_tower : bool
var is_built := false
var net_power : int = 0
var level : int = 0 #level 0 to line up with arrays
var clickable := false
var tower_children : Array :
	get:
		var children := []
		for child in get_children():
			if child is TowerMod:
				children.append(child)
		return children

## Setup
func _ready() -> void:
	marker_setup() #use markers instead of directly setting TowerMod scene so that this can show mod textures during build mode
	#tower_mods = build_data["mods"]
	#aura_tower = build_data["aura_tower"]
	#init_power_buffs = build_data["power_buffs"]
	#mod_slot_count = build_data["mods"].size()
	if tower_mods.size() > 0:
		for i in range(tower_mods.size()):
			marker_keys = all_marker_pos.keys()
			build_keys = tower_mods.keys()
			var marker_key = marker_keys[i]
			var build_key = build_keys[i]
			var tower_mod = TOWER_MOD_PROTO.instantiate()
			tower_mod.position = all_marker_pos[marker_key]
			#set mod textures on tower preview, or full mod data if built
			#does not do former for now
			if is_built:
				if tower_mods[build_key] != null:
					tower_mod.data = tower_mods[build_key].duplicate(true)
				tower_mod.button_slot_ref = build_key
				update_mods.connect(tower_mod.update_mod)
				tower_mod.non_aura_radius = marker_pos_radius
			#else:
				#print(tower_mod.get_child(0))
				#tower_mod.get_child(0).texture = build_btn_mods[build_key].texture
			add_child(tower_mod)
	tower_update(aura_tower, init_power_buffs)
	await get_tree().create_timer(0.25).timeout
	clickable = true

## Marker Functions
func marker_setup() -> void:
	for i in mod_slot_count:
		var marker = Marker2D.new()
		set_marker_pos(marker, i)
		add_child(marker)

func set_marker_pos(marker, count) -> void:
	var angle = (TAU * count) / mod_slot_count
	marker.position.x = marker_pos_radius * cos(angle)
	marker.position.y = marker_pos_radius * sin(angle)
	all_marker_pos[marker] = marker.position

func update_markers() -> void: #called if # of markers gets updated
	var count = 0
	for child in get_children():
		if child is Marker2D:
			set_marker_pos(child, count)
			count +=1

## Gameplay
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if clickable:
		if event.is_action("ui_accept"):
			var tower_data : Array
			for child in get_children():
				if child is TowerMod and child.data != null:
					tower_data.append(child.data)
			show_upgrade_panel.emit(POPUP_TYPE, tower_data, self)

func level_up() -> void:
	level = min(level + 1, MAX_LEVEL)
	for child in tower_children:
		if child.data != null:
			child.data.setup_stats(level)

func tower_update(
	aura_status: bool, 
	power_surplus_buffs : Dictionary,
	button_slot_ref: StaticBody2D = null, 
	button_mod_data: PrototypeMod = null, 
	) -> void:
	aura_tower = aura_status
	net_power = 0
	for child in tower_children: 
		if button_slot_ref != null and button_slot_ref == child.button_slot_ref:
			if child.data != null and child.data.mod_class == child.data.ModClass.AURA: 
				for body in child.aura_targets: #clears aura effects of old aura before updating
					child.clear_buffs(body)
			if button_mod_data != null:
				child.data = button_mod_data.duplicate(true)
			else:
				child.data = null
		if child.data != null:
			child.data.setup_stats(level)
			net_power += child.data.current_power
			child.data.power_surplus_buffs = power_surplus_buffs
	
	update_mods.emit(net_power)
	#if low power, set low power display
