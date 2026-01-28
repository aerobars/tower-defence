extends Node2D

signal game_finished(result)

## Gameplay 
var spawns_per_wave := 1 
var wave_total := 0
@export_range(0, 100, 1, "suffix: hp") var max_player_health : int = 100
var current_player_health : int
var character : String = "Tester"
@export_range(0, 1000, 1.0, "suffix: coins") var player_cash : int

## UI
const POPUPS : Dictionary = {
	"mod" : preload("res://GameData/UIScenes/GUI/mod_popup.tscn"),
	"tower" : preload("res://GameData/UIScenes/GUI/tower_popup.tscn")
}
const DRAGGABLE_MOD := preload("res://GameData/UIScenes/GUI/mod_draggable.tscn")
const REWARD_UI = preload("res://GameData/UIScenes/GUI/RewardSelection/reward_selection.tscn")
@export_group("Scene Paths")
@export_subgroup("UI")
@export var ui : CanvasLayer
@export var build_bar : ColorRect
@export var inventory_ui : GridContainer
@export var baddy_info_foldable : FoldableContainer
@export var pause_button : TextureButton
@export var game_bookend_popup : Control
@onready var new_slot := inventory_ui.connect("slot_created", connect_inv_button_signal)
var cur_popup : Node2D

## Pathfinding
@export_subgroup("Map and Pathfinding")
@export var map_node : Node2D #set in _ready instead if using multiple maps
@export var path_debug :Line2D
@onready var ground_layer : TileMapLayer = $Map/Ground
@onready var exclusion_layer : TileMapLayer = $Map/Exclusion
@onready var pathing_layer : TileMapLayer = $Map/Pathfinding
@onready var start_cell : Marker2D = $Map/StartPoint
@onready var end_cell : Marker2D = $Map/EndPoint
@onready var baddy_path : Path2D = $Map/Path

var astar : AStarGrid2D = AStarGrid2D.new()
var path : PackedVector2Array = []
const WALL_TILE_COORD := Vector2i(0,0)
const FLOOR_TILE_COORD := Vector2i(0,0)
const CELL_SIZE : int = 64
const CELL := Vector2(CELL_SIZE, CELL_SIZE)
const CELL_CENTRE := Vector2(CELL_SIZE/2, CELL_SIZE/2)
var previous_tile := Vector2i(0, 0)

## Build Mode
var build_btn_ref
var build_data : Dictionary
var build_location
var build_mode : bool = false
var build_tile
var build_type : String
var build_valid : bool = false


func _ready() -> void:
	## Pathfinding setup
	astar.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	astar.region = ground_layer.get_used_rect()
	astar.update()
	for tile in exclusion_layer.get_used_cells():
		#pathing_layer.set_cell(tile, 0, Vector2i(0,0), 0)
		astar.set_point_solid(tile, true)
	baddy_path_update()
	
	## UI Setup
	current_player_health = max_player_health
	ui.update_cash_display(player_cash)
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.pressed.connect(func(): initiate_build_mode(i.data, i, i.tower))

func _process(_delta: float) -> void:
	if build_mode:
		update_tower_preview()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel") and build_mode:
		cancel_build_mode()
	if event.is_action("ui_accept"): 
		clear_popup()
		if build_mode:
			verify_and_build()
			cancel_build_mode()
	if event.is_action_pressed("press_build_button_1"):
		build_bar.get_node("HBoxContainer/TowerBase").pressed.emit()

func pause_resume_game() -> void:
	if build_mode:
		cancel_build_mode()
	if get_tree().is_paused():
		get_tree().paused = false
	elif GameData.current_wave == 0:
		start_next_wave(0)
	else:
		get_tree().paused = true

func _on_fast_forward_pressed() -> void:
	if build_mode:
		cancel_build_mode()
	if Engine.get_time_scale() == 2.0:
		Engine.set_time_scale(1.0)
	else:
		Engine.set_time_scale(2.0)

## Wave Functions
func start_next_wave(_data) -> void:
	if get_tree().is_paused():
		pause_resume_game()
		pause_button.set_pressed_no_signal(true)
	GameData.current_wave += 1
	var wave_data = GameData.get_wave_data()
	wave_total = wave_data["wave_total"]
	if GameData.current_wave > 1:
		ui.update_game_message("Next wave starting", 3.0, 0.5) #padding before wave start
	spawn_baddies(wave_data["wave_baddies"])

func spawn_baddies(wave_data) -> void:
	for i in wave_data: 
		var spawn_count : int = 1
		var baddy_scene = load("res://GameData/Baddies/Act" + str(GameData.current_act + 1) + "/" + i)
		var new_baddy = baddy_scene.instantiate() 
		#first instantiate outside of loop for one-time variable setting
		spawns_per_wave = new_baddy.data.spawns_per_wave
		baddy_info_foldable.update_baddy_info(new_baddy)
		new_baddy.base_damage.connect(on_base_damage)
		new_baddy.baddy_death.connect(on_baddy_death)
		map_node.get_node("Path").add_child(new_baddy, true)
		await(get_tree().create_timer(new_baddy.data.spawn_interval, false)).timeout
		while spawn_count != spawns_per_wave: #only run if more than 1 enemy is spawned in the wave
			new_baddy = baddy_scene.instantiate()
			new_baddy.base_damage.connect(on_base_damage)
			new_baddy.baddy_death.connect(on_baddy_death)
			map_node.get_node("Path").add_child(new_baddy, true)
			spawn_count += 1
			await(get_tree().create_timer(new_baddy.data.spawn_interval, false)).timeout
			if spawn_count == spawns_per_wave:
				continue

func on_base_damage(damage) -> void:
	current_player_health -= damage
	$UI.update_health_bar(current_player_health, max_player_health)
	if current_player_health <= 0 and not game_bookend_popup.game_over:
		game_bookend_popup.game_over = true
		ui.update_game_message("Game Over!", 2.0, 0.0, 75)
		game_bookend_popup.get_node("TextureRect/Label").text = "Thank you for playing! 
		Please click the button below to complete a quick feedback survey and return to the main menu (and start a new game (＾ ＾)b )"
		game_bookend_popup.get_node("TextureRect/Button").text = "Go to survey"
		game_bookend_popup.visible = true
	else:
		on_baddy_death()

func on_baddy_death() -> void:
	wave_total -= 1
	if wave_total == 0:
		wave_cleared()
		#game_finished.emit(true)

func wave_cleared() -> void:
	ui.update_game_message("Wave Cleared!", 2.0, 0.5, 65)
	pause_resume_game()
	pause_button.set_pressed_no_signal(false)
	var new_reward = REWARD_UI.instantiate()
	new_reward.connect_reward_card.connect(reward_signal_connection)
	ui.add_child(new_reward)
	#load next level/wave selection

func reward_signal_connection(reward_card) -> void:
	reward_card.reward_selected.connect(inventory_ui.data.update_inventory)
	reward_card.reward_selected.connect(start_next_wave)

## Pathfinding Functions
func baddy_path_update() -> void:
	#not needed if whole map is set at initiation, called in _ready
	#astar.update()
	
	path = astar.get_point_path(start_cell.position / CELL_SIZE, end_cell.position / CELL_SIZE)
	var curve = Curve2D.new()
	path_debug.clear_points()
	for cell in path:
		curve.add_point(cell + CELL_CENTRE)
		path_debug.add_point(cell + CELL_CENTRE)
	baddy_path.curve = curve
	path.clear()

func pathfinding_update() -> void:
	path = astar.get_point_path(start_cell.position / CELL_SIZE, end_cell.position / CELL_SIZE)
	path_debug.clear_points()
	for cell in path:
		path_debug.add_point(cell + CELL_CENTRE)

## Building Functions
func initiate_build_mode(data: Dictionary, btn_ref, tower_type: String = "tower_base") -> void: #connected to build buttons' pressed signal, data contains tower mods and aura tower status
	if build_mode:
		cancel_build_mode()
	if player_cash < btn_ref.build_cost:
		ui.update_game_message("Unable to build: insufficient funds", 1.0, 0.5)
		return
	build_btn_ref = btn_ref
	build_data = data
	build_mode = true
	build_type = tower_type
	previous_tile = Vector2i(-100,-100)
	ui.set_tower_preview(build_type, get_global_mouse_position(), build_data)

func update_tower_preview() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var current_tile: Vector2i = exclusion_layer.local_to_map(mouse_pos)
	var tile_pos: Vector2 = exclusion_layer.map_to_local(current_tile)
	
	pathing_layer.set_cell(current_tile, 0, Vector2i(0,0), 0)
	astar.set_point_solid(current_tile, true)
	if previous_tile != current_tile:
		if exclusion_layer.get_cell_source_id(previous_tile) == -1:
			astar.set_point_solid(previous_tile, false)
		pathing_layer.clear()
		previous_tile = current_tile
	
	pathfinding_update()
	
	if exclusion_layer.get_cell_source_id(current_tile) == -1 and not path.is_empty():
		ui.update_tower_preview(tile_pos, "GREEN")
		build_valid = true
		build_location = tile_pos
		build_tile = current_tile
	else:
		ui.update_tower_preview(tile_pos, "CRIMSON")
		build_valid = false

func cancel_build_mode() -> void:
	build_mode = false
	build_valid = false
	pathing_layer.clear()
	$UI/TowerPreview.free()

func verify_and_build() -> void:
	if build_valid:
		var new_tower = load("res://GameData/Towers/" + build_type + ".tscn").instantiate()
		new_tower.position = build_location
		new_tower.is_built = true
		new_tower.build_btn_mods = build_data["mods"]
		new_tower.aura_tower = build_data["aura_tower"]
		new_tower.init_power_buffs = build_data["power_buffs"]
		new_tower.mod_slot_count = build_data["mods"].size()
		new_tower.show_upgrade_panel.connect(create_popup)
		build_btn_ref.aura_update.connect(new_tower.aura_update)
		build_btn_ref.power_update.connect(new_tower.power_update)
		
		map_node.get_node("TowerContainer").add_child(new_tower, true) #TowerContainer is in Map Scene
		exclusion_layer.set_cell(build_tile, 5, Vector2i(1,0), 0)
		astar.set_point_solid(build_tile, true)
		baddy_path_update()
		player_cash -= build_btn_ref.build_cost
		ui.update_cash_display(player_cash)

func upgrade_check(upgrade_cost : int, tower : TowerBase, popup : TowerPopup) -> void:
	if player_cash < upgrade_cost:
		ui.update_game_message("Unable to upgrade: insufficient funds", 1.0, 0.5)
	else:
		tower.level_up()
		popup.setup_stats()
		player_cash -= upgrade_cost
		ui.update_cash_display(player_cash)
	

func sell_tower(sell_value : int, tower : TowerBase) -> void:
	player_cash += sell_value
	ui.update_cash_display(player_cash)
	tower.queue_free()

## UI Functions
func connect_inv_button_signal(inventory_slot) -> void: #connects new inventory slot signal
	inventory_slot.button_down.connect(on_inv_button_down.bind(inventory_slot, inventory_slot.slot_data.inventory_mod))
	inventory_slot.hovered.connect(create_popup)
	inventory_slot.clear_popup.connect(clear_popup)

func on_inv_button_down(_inventory_slot, tower_mod) -> void: #button down for inventory slot
	var new_draggable = DRAGGABLE_MOD.instantiate()
	GameData.is_dragging = true
	new_draggable.draggable = true
	new_draggable.data = tower_mod
	new_draggable.get_child(0).texture = tower_mod.texture
	new_draggable.mod_dropped.connect(inventory_ui.data.update_inventory)
	build_bar.add_child(new_draggable)
	new_draggable.inventory_pos = Vector2((inventory_ui.global_position.x + inventory_ui.size.x/2), (inventory_ui.global_position.y + inventory_ui.size.y/2))
	new_draggable.initial_pos = get_global_mouse_position()

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
	ui.add_child(popup)
	cur_popup = popup

func clear_popup() -> void:
	if cur_popup != null:
		cur_popup.queue_free()
