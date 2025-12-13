class_name TowerBase extends StaticBody2D


@export var marker_pos_radius : float = 10
var level := 0 #level 0 to line up with arrays
var marker_count : int = 0 #set during verify and build Game Scene function
var all_marker_pos : Dictionary[Marker2D,Vector2]
var marker_keys : Array

var build_btn_mods : Dictionary
var build_keys : Array

var aura_tower : bool
var is_powered := false
var net_power : int

var tower_mod_proto := preload("res://GameData/TowerMods/tower_mod.tscn")
var is_built := false

func _ready() -> void:
	marker_setup() #use markers instead of directly setting TowerMod scene so that this can show mod textures during build mode
	if build_btn_mods.size() > 0:
		for i in range(build_btn_mods.size()):
			marker_keys = all_marker_pos.keys()
			build_keys = build_btn_mods.keys()
			var marker_key = marker_keys[i]
			var build_key = build_keys[i]
			var tower_mod = tower_mod_proto.instantiate()
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

func level_up() -> void:
	for child in get_children():
		child.level_up()

## Marker Functions
func marker_setup() -> void:
	for i in marker_count:
		var marker = Marker2D.new()
		set_marker_pos(marker, i)
		add_child(marker)

func set_marker_pos(marker, count) -> void:
	var angle = (TAU * count) / marker_count
	marker.position.x = marker_pos_radius * cos(angle)
	marker.position.y = marker_pos_radius * sin(angle)
	all_marker_pos[marker] = marker.position

#called if # of markers gets updated
func update_markers() -> void:
	var count = 0
	for child in get_children():
		if child is Marker2D:
			set_marker_pos(child, count)
			count +=1

func power_check() -> void:
	for child in get_children():
		if child is TowerModPrototype and child.data != null:
			net_power += child.data.current_power
	if net_power >= 0:
		is_powered = true
	else:
		is_powered = false
		#display low power symbol on tower
