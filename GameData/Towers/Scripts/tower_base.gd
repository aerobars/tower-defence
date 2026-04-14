class_name TowerBase extends StaticBody2D

signal show_upgrade_panel(popup_type : String, tower_data, tower_id : TowerBase)
signal update_mods(net_power : int)

## Setup
@export var marker_pos_radius : float = 10
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
var tower_children : Array :
	get:
		var children := []
		for child in get_children():
			if child is TowerMod:
				children.append(child)
		return children

## Setup
func _ready() -> void:
	if not is_built:
		return
	var tower_mods : Dictionary = build_data["mods"]
	var init_power_buffs : Dictionary = build_data["power_buffs"]
	aura_tower = build_data["aura_tower"]
	mod_slot_count = tower_mods.size()
	marker_setup() #use markers instead of directly setting TowerMod scene so that this can show mod textures during build mode
	if mod_slot_count > 0:
		var marker_keys : Array
		var build_keys : Array
		for i in range(mod_slot_count):
			marker_keys = all_marker_pos.keys()
			build_keys = tower_mods.keys()
			var marker_key = marker_keys[i]
			var build_key = build_keys[i]
			var tower_mod = TOWER_MOD_PROTO.instantiate()
			tower_mod.position = all_marker_pos[marker_key]
			#set mod textures on tower preview, or full mod data if built
			#does not do former for now
			if tower_mods[build_key] != null:
				tower_mod.data = tower_mods[build_key].duplicate(true)
				if tower_data.level > 0:
					tower_mod.data.setup_stats(tower_data.level)
			tower_mod.button_slot_id = build_key
			update_mods.connect(tower_mod.update_mod)
			tower_mod.non_aura_radius = marker_pos_radius
				
			#else:
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
			var mod_data : Array
			for child in get_children():
				if child is TowerMod and child.data != null:
					mod_data.append(child.data)
			show_upgrade_panel.emit(POPUP_TYPE, mod_data, self)

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
			if button_mod_data != null: #set tower mod's data
				child.data = button_mod_data.duplicate(true)
				child.data.buff_owner = child
				if child.data.swapper:
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
