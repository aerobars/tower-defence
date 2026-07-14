extends Node2D

signal build_tower(tower_data: TowerBuildData, tower_rotation: float)

const PREVIEW_RANGE_DISPLAY : CompressedTexture2D = preload("res://Assets/UI/range_overlay.png")
const TOWER_BASE_SCENE : PackedScene = preload("res://GameData/Towers/Scenes/tower_base.tscn")

var cell_size : int #set to Map Node CELL_SIZE in Game Scene
var path_map : Node2D

var build_btn_ref : BuildTowerButton
##aura_tower: bool, mods: button_data.mod_data (Dictionary[slot_id: int, PrototypeMod]), power_buffs: power_surplus_buffs (Dictionary[stat, amt: int]), shape: button_data.tower_shape (Array[Vector2i])
var build_data : TowerBuildData
##Used for valid build locations
var build_location : Vector2 = Vector2(0, 0)
var build_mode : bool = false
var tower_preview : TowerBase

func _process(_delta: float) -> void:
	if build_mode:
		update_tower_preview()

func initiate_build_mode(data: TowerBuildData, btn_ref: BuildTowerButton) -> void: #connected to build buttons' pressed signal, data contains tower mods and aura tower status
	check_build_mode()
	
	if build_btn_ref != btn_ref: #maintains rotation when building multiple of same tower
		rotation = 0
	build_btn_ref = btn_ref
	build_data = data
	build_data.cell_size = cell_size
	build_mode = true
	path_map.reset_previous_tiles()
	
	set_tower_preview()

func set_tower_preview() -> void:
	tower_preview = create_tower_preview()
	tower_preview.modulate = Color("GREEN")
	
	var range_texture : Sprite2D
	
	##use build_data dictionary to set correct position of preview range.
	
	for button_id in build_data.mods: #adds range indicator to auras and weapons
		if button_id == null or build_data.mods[button_id] == null:
			continue
		var mod = build_data.mods[button_id]
		var slot_id = button_id % 10
		if mod.mod_class == mod.ModClass.AURA or mod.mod_class == mod.ModClass.WEAPON:
			range_texture = Sprite2D.new()
			var scaling : float = mod.base_range_levels[0] / 300.0
			range_texture.texture = PREVIEW_RANGE_DISPLAY
			if mod.mod_class == mod.ModClass.WEAPON:
				range_texture.modulate = Color("CRIMSON")
			elif build_data["aura_tower"]:
				range_texture.modulate = Color("BLUE")
			else: #mod is an aura but not aura tower
				scaling = tower_preview.non_aura_radius / 600.0
			range_texture.scale = Vector2(scaling, scaling)
			add_child(range_texture, true)
			range_texture.position = Vector2(build_data.shape[slot_id].x * cell_size, build_data.shape[slot_id].y * cell_size) #position needed if range is offest from tower
			#add mod texture

	add_child(tower_preview, true)
	set_position(get_global_mouse_position())

func create_tower_preview() -> TowerBase:
	var new_tower = TOWER_BASE_SCENE.instantiate()
	
	new_tower.build_data = build_data
	new_tower.tower_data = TowerBaseData.new(build_data.shape, build_btn_ref.button_data.button_id)
	new_tower.cell_size = cell_size
	
	return new_tower

func update_tower_preview() -> void:
	var colour : String
	
	path_map.update_build_status(tower_preview)
	
	if tower_preview.build_data.build_valid:
		colour = "GREEN"
	else:
		colour = "CRIMSON"
	
	set_position(tower_preview.build_data.build_position)
	
	if tower_preview.modulate != Color(colour):
		tower_preview.modulate = Color(colour)

func check_build_mode() -> void:
	if build_mode:
		cancel_build_mode()

func cancel_build_mode() -> void:
	build_mode = false
	for child in get_children():
		child.free()
	build_data = null
	path_map.build_mode_cleanup()

func verify_and_build() -> void:
	if tower_preview.build_data.build_valid and get_parent().check_cash(build_btn_ref.build_cost):
		build_tower.emit(
			tower_preview.build_data, 
			build_btn_ref, 
			tower_preview.build_data.build_position, 
			rotation
			)
		cancel_build_mode()
