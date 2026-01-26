class_name TowerBase extends StaticBody2D

signal show_upgrade_panel(popup_type : String, tower_data, tower_id : TowerBase)

## Setup
@export var marker_pos_radius : float = 10
const MAX_LEVEL = 4
var mod_slot_count : int = 0 #set during verify and build Game Scene function
var all_marker_pos : Dictionary[Marker2D,Vector2]
var marker_keys : Array
var build_btn_mods : Dictionary
var build_keys : Array

## Gameplay
const TOWER_MOD_PROTO : PackedScene = preload("res://GameData/Towers/tower_mod.tscn")
const POPUP_TYPE : String = "tower"
var aura_tower : bool
var is_built := false
var is_powered := false
var level := 0 #level 0 to line up with arrays
var net_power : int = 0


func _ready() -> void:
	marker_setup() #use markers instead of directly setting TowerMod scene so that this can show mod textures during build mode
	if build_btn_mods.size() > 0:
		for i in range(build_btn_mods.size()):
			marker_keys = all_marker_pos.keys()
			build_keys = build_btn_mods.keys()
			var marker_key = marker_keys[i]
			var build_key = build_keys[i]
			var tower_mod = TOWER_MOD_PROTO.instantiate()
			tower_mod.position = all_marker_pos[marker_key]
			#set mod textures on tower preview, or full mod data if built
			#does not do former for now
			if is_built:
				tower_mod.data = build_btn_mods[build_key]
				tower_mod.mod_slot_ref = build_key
				build_key.mod_updated.connect(tower_mod.mod_slot_updated) 
				tower_mod.power_check.connect(power_check)
			#else:
				#print(tower_mod.get_child(0))
				#tower_mod.get_child(0).texture = build_btn_mods[build_key].texture
			add_child(tower_mod)


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
	if is_built:
		if event.is_action("ui_accept"):
			var tower_data : Array
			for child in get_children():
				if child is TowerMod and child.data != null:
					tower_data.append(child.data)
			show_upgrade_panel.emit(POPUP_TYPE, tower_data, self)

func level_up() -> void:
	level = min(level + 1, MAX_LEVEL)
	for child in get_children():
		if child is TowerMod and child.data != null:
			child.data.setup_stats(level)

func power_check() -> void:
	net_power = 0
	for child in get_children():
		if child is TowerMod and child.data != null:
			net_power += child.data.current_power
	if net_power >= 0:
		is_powered = true
	else:
		is_powered = false
		#display low power symbol on tower

func aura_update(aura_status : bool) -> void:
	aura_tower = aura_status
