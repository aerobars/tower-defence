extends Node2D

signal game_finished(result)
signal pathing_updated

## UI

const BADDY_SCENE := preload("res://GameData/Baddies/ScriptsAndProtos/baddy.tscn")
const DRAGGABLE_MOD := preload("res://GameData/UIScenes/GUI/Scenes/mod_draggable.tscn")
const TOWER_BUTTON := preload("res://GameData/UIScenes/GUI/Scenes/tower_button.tscn")
const PREVIEW_RANGE_DISPLAY : CompressedTexture2D = preload("res://Assets/UI/range_overlay.png")
const REWARD_UI = preload("res://GameData/UIScenes/GUI/RewardSelection/reward_selection.tscn")
const POPUPS : Dictionary = {
	"mod" : preload("res://GameData/UIScenes/GUI/Scenes/mod_popup.tscn"),
	"tower" : preload("res://GameData/UIScenes/GUI/Scenes/tower_popup.tscn")
}
@export_group("Scene Paths")
@export_subgroup("UI", "path_")
@export var path_tower_preview_container : Node2D
@export var path_ui : CanvasLayer
@export var path_range_display : Sprite2D
@export var path_camera : Camera2D
var cur_popup : Node2D

## Pathfinding

@export_subgroup("Map and Pathfinding", "path_")
@export var path_map_node : Node2D #set in _ready instead if using multiple maps
@export var path_pathfinding_line :Line2D
var preview_path : PackedVector2Array = []

var tower_grid_size : int :
	get():
		return path_map_node.CELL_SIZE * 3 #CELL_SIZE * number of columns in tower grid(3)
var previous_tiles := [Vector2i(0, 0)]

## Gameplay 

var new_game : bool
@export_group("Gameplay")
var remaining_spawns := 0 
var wave_total := 0
var living_baddies := 0
var escaped_baddies := 0
@export_range(0, 100, 1, "suffix: hp") var max_player_health : int = 100
var player_health : int :
	set(value):
		SaveManager.save_data_run.current_player_health = value
		if path_ui:
			path_ui.update_health_bar(SaveManager.save_data_run.current_player_health, max_player_health)
	get:
		return SaveManager.save_data_run.current_player_health
#var character : String = "Tester"
var player_cash : int :
	set(value):
		SaveManager.save_data_run.current_cash = value
		if path_ui:
			path_ui.update_cash_display(SaveManager.save_data_run.current_cash)
	get:
		return SaveManager.save_data_run.current_cash
var wave_reward : int :
	get:
		return randi_range(50, 50) # (1 + float(SaveManager.save_data_run.current_wave)/10)
var current_unit : Node2D


## Build Mode

var build_btn_ref
##"aura_tower": bool, "mods": button_data.mod_data (Dictionary[slot_id: int, PrototypeMod]), "power_buffs": power_surplus_buffs (Dictionary[stat, amt: int]), "shape": button_data.tower_shape (Array[Vector2i])
var build_data : Dictionary
var build_location : Vector2 = Vector2(0, 0)
var build_rotation : float = 0.0
var build_mode : bool = false
var build_tiles : Array[Vector2i]
var build_valid : bool = false
@onready var tower_base_scene : PackedScene = preload("res://GameData/Towers/Scenes/tower_base.tscn")
var tower_preview : Node2D


func _ready() -> void:
	## Pathfinding setup
	pathing_update()
	
	## UI Setup
	path_ui.update_health_bar(player_health, max_player_health)
	path_ui.update_cash_display(player_cash)
	path_ui.create_draggable.connect(create_draggable)
	path_ui.engage_build_mode.connect(initiate_build_mode)
	path_ui.start_next_wave.connect(start_next_wave)
	path_ui.check_build_mode.connect(check_build_mode)
	path_ui.create_popup.connect(create_popup)
	path_ui.clear_popup.connect(clear_popup)
	
	##Saved Run Setup
	if SaveManager.save_data_run.new_game : #rest of func only needs to run to load saved towers
		return
	for tower in SaveManager.save_data_run.tower_data:
		for button in get_tree().get_nodes_in_group("build_buttons"):
			if button.button_data.button_id == tower.connected_button_id:
				create_tower(tower.rotation, tower.position, button.tower_data, button, tower.level, true)
	
	##Saved Draggable Mod Position Set
	await get_tree().process_frame
	for mod in get_tree().get_nodes_in_group("droppable"):
		if mod is ModDraggable:
			mod.global_position = mod.mod_slot_ref.global_position
	
	#for each tower in saved tower data
	#create a new tower at the saved position
	#add saved mods to tower
	#set tower level to saved level
	#connect linked button signals

func _process(_delta: float) -> void:
	if build_mode:
		update_tower_preview()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel") and build_mode:
		cancel_build_mode()
	if event.is_action("ui_accept"): 
		clear_popup()
		if current_unit:
			current_unit.set_selected(false)
			current_unit = null
		if build_mode:
			verify_and_build()
	if event.is_action_pressed("hotkey_button_1"):
		path_ui.path_tower_buttons.get_child(0).pressed.emit()
	if event.is_action_pressed("hotkey_button_2"):
		path_ui.path_tower_buttons.get_child(1).pressed.emit()
	#if event.is_action_pressed("hotkey_button_3"):
		#tower_buttons.get_child(2).pressed.emit()
	#if event.is_action_pressed("hotkey_button_4"):
		#tower_buttons.get_child(3).pressed.emit()
	#if event.is_action_pressed("hotkey_button_5"):
		#tower_buttons.get_child(4).pressed.emit()
	if not build_mode:
		return
	if event.is_action_pressed("rotate_counterclockwise"):
		var tween = get_tree().create_tween()
		tween.tween_property(path_tower_preview_container, "rotation", path_tower_preview_container.rotation - PI/2, 0.1)
		tower_preview.tower_data.rotation = path_tower_preview_container.rotation
		#counter rotate mod image
		return
	if event.is_action_pressed("rotate_clockwise"):
		var tween = get_tree().create_tween()
		tween.tween_property(path_tower_preview_container, "rotation", path_tower_preview_container.rotation + PI/2, 0.1)
		tower_preview.tower_data.rotation = path_tower_preview_container.rotation
		#counter rotate mod image
		return

## Wave Functions

func start_next_wave() -> void:
	SaveManager.save_data_run.current_wave += 1
	var wave_data = GameData.get_wave_data()
	wave_total = wave_data["wave_total"]
	remaining_spawns = wave_total
	living_baddies = 0
	escaped_baddies = 0
	spawn_baddies(wave_data["wave_baddies"])

func spawn_baddies(wave_data) -> void:
	var wave_baddies : Array[Dictionary]
	var spawning := true
	
	for i in wave_data: 
		var baddy_data = load("res://GameData/Baddies/Act" + str(SaveManager.save_data_run.current_act + 1) + "/" + i)
		
		wave_baddies.append({
			"data" : baddy_data,
			"spawn_count" : 0,
			"spawn_per_wave" : baddy_data.spawn_per_wave,
			"spawn_interval" : baddy_data.spawn_interval
			})
	path_ui.update_wave_info(wave_baddies)
		
	while spawning:
		spawning = false
		for baddy in wave_baddies:
			if baddy["spawn_count"] < baddy["spawn_per_wave"]:
				spawning = true
				
				var new_baddy = BADDY_SCENE.instantiate()
				new_baddy.data = baddy["data"].duplicate(true)
				
				
				new_baddy.base_damage.connect(on_base_damage)
				new_baddy.baddy_death.connect(on_baddy_death)
				new_baddy.unit_selected.connect(on_unit_selection)
				new_baddy.update_baddy_display.connect(path_ui.update_baddy_info)
				new_baddy.open_baddy_display.connect(path_ui.open_baddy_display)
				pathing_updated.connect(new_baddy.update_pathing)
				new_baddy.path_map = path_map_node
				new_baddy.global_position = path_map_node.path_start_point.global_position + path_map_node.CELL_CENTRE
				path_map_node.path_baddy_container.add_child(new_baddy, true)
				
				baddy["spawn_count"] += 1
				living_baddies += 1
				remaining_spawns -= 1
				await get_tree().create_timer(baddy["spawn_interval"], false).timeout

func on_base_damage(damage, is_summon) -> void:
	player_health -= damage
	if not is_summon:
		escaped_baddies += 1
	if (player_health <= 0 or escaped_baddies == wave_total) and not path_ui.path_game_bookend_popup.game_over:
		path_ui.path_game_bookend_popup.game_over = true
		path_ui.update_game_message("Game Over!", 2.0, 0.0, 75)
		path_ui.path_game_bookend_popup.get_node("TextureRect/Label").text = "Thank you for playing! 
		Please click the button below to complete a quick feedback survey and return to the main menu (and start a new game (＾ ＾)b )"
		path_ui.path_game_bookend_popup.get_node("TextureRect/Button").text = "Go to survey"
		path_ui.path_game_bookend_popup.visible = true
	else:
		on_baddy_death()

func on_baddy_death() -> void:
	living_baddies -= 1
	if living_baddies == 0 and remaining_spawns == 0:
		wave_cleared()

func wave_cleared() -> void:
	path_ui.update_game_message("Wave Cleared!", 2.0, 0.5, 65)
	player_cash += wave_reward
	var new_reward_ui = REWARD_UI.instantiate()
	new_reward_ui.total_rewards = SaveManager.save_data_run.wave_reward_total
	new_reward_ui.connect_reward_card.connect(reward_signal_connection)
	path_ui.clear_baddy_info()
	path_ui.add_child(new_reward_ui)
	path_ui.update_wave_button()
	#load next level/wave selection

func reward_signal_connection(reward_card) -> void:
	reward_card.reward_selected.connect(path_ui.path_inventory_ui.data.update_inventory)

## Pathfinding Functions

func pathing_update() -> void:
	preview_path = path_map_node.update_preview()
	path_pathfinding_line.clear_points()
	for cell in preview_path:
		path_pathfinding_line.add_point(cell)

## Building Functions

func initiate_build_mode(data: Dictionary, btn_ref) -> void: #connected to build buttons' pressed signal, data contains tower mods and aura tower status
	if build_mode:
		cancel_build_mode()
	if player_cash < btn_ref.build_cost:
		path_ui.update_game_message("Unable to build: insufficient funds", 1.0, 0.5)
		return
	build_btn_ref = btn_ref
	build_data = data
	build_mode = true
	previous_tiles = [Vector2i(-100,-100)]
	build_valid = false
	path_tower_preview_container.rotation = 0
	#move tower instatiation to hear as a variable, to allow for rotation during update_tower_preview
	#path_ui.set_tower_preview(get_global_mouse_position(), build_data, tower_preview)
	set_tower_preview()

func set_tower_preview() -> void:
	tower_preview = create_tower()
	tower_preview.set_name("DragTower")
	tower_preview.modulate = Color("GREEN")
	tower_preview.build_data = build_data
	
	var range_texture : Sprite2D
	
	##use build_data dictionary to set correct position of preview range.
	
	for key in build_data["mods"]: #adds range indictator to auras and weapons
		if key == null or build_data["mods"][key] == null:
			continue
		var mod = build_data["mods"][key]
		var slot_id = key % 10
		if mod.mod_class == mod.ModClass.AURA or mod.mod_class == mod.ModClass.WEAPON:
			range_texture = Sprite2D.new()
			var scaling : float = mod.current_range / 300.0
			range_texture.texture = PREVIEW_RANGE_DISPLAY
			if mod.mod_class == mod.ModClass.WEAPON:
				range_texture.modulate = Color("CRIMSON")
			elif build_data["aura_tower"]:
				range_texture.modulate = Color("BLUE")
			else: #mod is an aura but not aura tower
				scaling = tower_preview.non_aura_radius / 600.0
			range_texture.scale = Vector2(scaling, scaling)
			path_tower_preview_container.add_child(range_texture, true)
			range_texture.position = Vector2(build_data["shape"][slot_id].x * path_map_node.CELL_SIZE, build_data["shape"][slot_id].y * path_map_node.CELL_SIZE) #position needed if range is offest from tower
			#add mod texture

	path_tower_preview_container.add_child(tower_preview, true)
	path_tower_preview_container.set_position(get_global_mouse_position())

func update_tower_preview() -> void:
	var mouse_pos : Vector2 = get_global_mouse_position()
	var centre_tile : Vector2i = path_map_node.path_exclusion_layer.local_to_map(mouse_pos)
	var centre_tile_pos : Vector2 = path_map_node.path_exclusion_layer.map_to_local(centre_tile)
	var colour : String
	var all_cells : Array[Vector2i] = []
	
	#for each cell in tower shape, do below code
	build_valid = true
	for child in tower_preview.tower_children:
		var current_cell : Vector2i = path_map_node.path_exclusion_layer.local_to_map(child.global_position)
		all_cells.append(current_cell)
		path_map_node.path_pathfinding_layer.set_cell(current_cell, 0, Vector2i(0,0), 0)
		path_map_node.astar_preview.set_point_solid(current_cell, true)
		if path_map_node.path_exclusion_layer.get_cell_source_id(current_cell) != -1 or preview_path.is_empty():
			build_valid = false
	if build_valid:
		colour = "GREEN"
		build_location = centre_tile_pos
		build_tiles = all_cells
		build_rotation = tower_preview.tower_data.rotation
	else:
		colour = "CRIMSON"

	path_tower_preview_container.set_position(centre_tile_pos)
	if tower_preview.modulate != Color(colour):
		tower_preview.modulate = Color(colour)
	
	for tile in previous_tiles:
		if all_cells.has(tile):
			continue
		if path_map_node.path_exclusion_layer.get_cell_source_id(tile) == -1:
			path_map_node.astar_preview.set_point_solid(tile, false)
		path_map_node.path_pathfinding_layer.clear()
	previous_tiles = all_cells
	
	pathing_update()

func check_build_mode() -> void:
	if build_mode:
		cancel_build_mode()

func cancel_build_mode() -> void:
	build_mode = false
	build_valid = false
	path_map_node.path_pathfinding_layer.clear()
	for child in path_tower_preview_container.get_children():
		child.free()
	for tile in previous_tiles:
		path_map_node.astar_preview.set_point_solid(tile, false)
	pathing_update()

func verify_and_build() -> void:
	if build_valid:
		var tower_rotation = path_tower_preview_container.rotation
		cancel_build_mode()
		create_tower(tower_rotation)
		player_cash -= build_btn_ref.build_cost
		pathing_update()
		pathing_updated.emit()

func create_tower(
	_build_rotation: float = 0.0, 
	_build_location: Vector2 = build_location,
	_build_data: Dictionary = build_data, 
	connected_btn: BuildTowerButton = build_btn_ref, 
	level: int = 0,
	saved_tower: bool = false,
	):
	
	var new_tower = tower_base_scene.instantiate()
	new_tower.build_data = _build_data
	new_tower.tower_data = TowerBaseData.new()
	new_tower.tower_data.connected_button_id = connected_btn.button_data.button_id
	if build_mode:
		return new_tower
	new_tower.tower_data.level = level
	new_tower.tower_data.position = _build_location
	new_tower.position = new_tower.tower_data.position
	new_tower.is_built = true
	new_tower.show_upgrade_panel.connect(create_popup)
	new_tower.unit_selected.connect(on_unit_selection)
	new_tower.update_range_display.connect(update_range_display)
	new_tower.hide_range_display.connect(hide_range_display)
	connected_btn.update_towers.connect(new_tower.tower_update)
	if not saved_tower:
		SaveManager.save_data_run.tower_data.append(new_tower.tower_data)
		new_tower.rotation = _build_rotation
	else:
		new_tower.rotation = new_tower.tower_data.rotation
	path_map_node.path_tower_container.add_child(new_tower, true) #TowerContainer is in Map Scene
	for child in new_tower.tower_children:
		var child_tile = path_map_node.path_exclusion_layer.local_to_map(child.global_position)
		path_map_node.path_exclusion_layer.set_cell(child_tile, 5, Vector2i(1,0), 0)
		path_map_node.astar_pathing.set_point_solid(child_tile, true)
		path_map_node.astar_preview.set_point_solid(child_tile, true)

func upgrade_check(upgrade_cost : int, tower : TowerBase, popup : TowerPopup) -> void:
	if player_cash < upgrade_cost:
		path_ui.update_game_message("Unable to upgrade: insufficient funds", 1.0, 0.5)
	else:
		tower.level_up()
		popup.setup_stats()
		player_cash -= upgrade_cost
		path_ui.update_cash_display(player_cash)

func sell_tower(sell_value : int, tower : TowerBase) -> void:
	for child in tower.tower_children:
		var tile_pos: Vector2i = path_map_node.path_exclusion_layer.local_to_map(child.global_position)
		path_map_node.path_exclusion_layer.set_cell(tile_pos)
		path_map_node.astar_pathing.set_point_solid(tile_pos, false)
	pathing_update()
	pathing_updated.emit()
	tower.queue_free()
	player_cash += sell_value
	path_ui.update_cash_display(player_cash)

## GUI Functions

func create_draggable(
	tower_mod: PrototypeMod, 
	initial_pos : Vector2 = get_global_mouse_position(), 
	slot_occupied : TowerButtonModSlot = null, 
	_is_dragging = true
	) -> void: #button down for inventory slot
	
	var new_draggable = DRAGGABLE_MOD.instantiate()
	GameData.is_dragging = _is_dragging
	new_draggable.draggable = _is_dragging
	new_draggable.data = tower_mod.duplicate()
	new_draggable.mod_dropped.connect(path_ui.path_inventory_ui.data.update_inventory)
	path_ui.path_build_bar.add_child(new_draggable)
	new_draggable.inventory_pos = Vector2((path_ui.path_inventory_ui.global_position.x + path_ui.path_inventory_ui.size.x/2), (path_ui.path_inventory_ui.global_position.y + path_ui.path_inventory_ui.size.y/2))
	new_draggable.initial_pos = initial_pos
	if slot_occupied != null:
		slot_occupied.occupying_mod = new_draggable
		new_draggable.mod_slot_ref = slot_occupied
		#new_draggable.global_position = initial_pos
		new_draggable.in_inventory = false

func create_popup(popup_type: String , data, popup_owner : TowerBase = null) -> void:
	clear_popup()
	var popup = POPUPS[popup_type].instantiate()
	var popup_size = popup.get_child(0).size
	popup.data = data #data is ModPrototype if it is from inventory, Array if it's from TowerBase
	popup.global_position = Vector2(get_global_mouse_position().x + 15, get_global_mouse_position().y - popup_size.y/2)
	if popup_owner != null:
		popup.popup_owner = popup_owner
		popup.upgrade_check.connect(upgrade_check)
		popup.sell.connect(sell_tower)
	path_ui.add_child(popup)
	cur_popup = popup

func clear_popup() -> void:
	if cur_popup != null:
		cur_popup.queue_free()

func update_range_display(tower: TowerCell) -> void:
	path_range_display.global_position = tower.global_position
	var scaling : float = tower.data.current_range / 300.0
	if tower.data.mod_class == PrototypeMod.ModClass.WEAPON:
		path_range_display.modulate = Color("CRIMSON")
	elif tower.data.mod_class == PrototypeMod.ModClass.AURA:
		path_range_display.modulate = Color("BLUE")
	path_range_display.scale = Vector2(scaling, scaling)
	path_range_display.visible = true

func hide_range_display() -> void:
	path_range_display.visible = false

## Runtime Functions

func on_unit_selection(unit) -> void:
	if current_unit == unit:
		return
	
	if current_unit:
		current_unit.set_selected(false)
	current_unit = unit
	current_unit.set_selected(true)
	

##Save/Load Testing
func _on_save_button_up() -> void:
	game_finished.emit(false)
