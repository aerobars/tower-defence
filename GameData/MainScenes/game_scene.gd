extends Node2D

signal game_finished(result)

#ui variables
var map_node : Node
const POPUP_PANEL := preload("res://GameData/UIScenes/GUI/InfoPopup.tscn")
const DRAGGABLE_MOD := preload("res://GameData/UIScenes/GUI/mod_draggable.tscn")
@onready var new_slot := $UI/HUD/BuildBar/InventoryContainer/InventoryGrid.connect("slot_created", connect_inv_button_signal)
@onready var build_bar := $UI/HUD/BuildBar
@onready var inventory_ui := $UI/HUD/BuildBar/InventoryContainer/InventoryGrid
var cur_popup : Node2D

#pathfinding variables
@onready var ground_layer := $Map/Ground
@onready var exclusion_layer := $Map/Exclusion
@onready var pathing_layer := $Map/Pathfinding
@onready var start_cell := $Map/StartPoint
@onready var end_cell := $Map/EndPoint
@onready var baddy_path := $Map/Path
@onready var path_debug := $PathDebug

var astar : AStarGrid2D = AStarGrid2D.new()
var path : PackedVector2Array = []
const WALL_TILE_COORD = Vector2i(0,0)
const FLOOR_TILE_COORD = Vector2i(0,0)
const CELL_SIZE = 64
const CELL := Vector2(CELL_SIZE, CELL_SIZE)
const CELL_CENTRE := Vector2(CELL_SIZE/2, CELL_SIZE/2)
var previous_tile: Vector2i

#build mode variables
var build_mode := false
var build_valid := false
var build_tile
var build_location
var build_type : String
var build_data : Dictionary

#gameplay variables
var current_wave := 0
var enemies_in_wave := 0

var base_health := 100

func _ready() -> void:
	map_node = $Map #turn into variable if using multiple maps

	astar.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	astar.region = ground_layer.get_used_rect()
	astar.update()
	for tile in exclusion_layer.get_used_cells():
		#pathing_layer.set_cell(tile, 0, Vector2i(0,0), 0)
		astar.set_point_solid(tile, true)
	baddy_path_update()
	
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.pressed.connect(func(): initiate_build_mode(i.name.to_snake_case(), i.data))
	

func _process(_delta: float) -> void:
	if build_mode:
		update_tower_preview()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel") and build_mode:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode:
		#Verify player has enough cash and only proceed with below if true
		verify_and_build()
		cancel_build_mode()
	if event.is_action_pressed("press_build_button_1"):
		build_bar.get_node("HBoxContainer/TowerBase").pressed.emit()

## Wave Functions

func start_next_wave() -> void:
	var wave_data = retrieve_wave_data()
	await(get_tree().create_timer(0.2)).timeout ##padding between wave
	spawn_enemies(wave_data)

func retrieve_wave_data() -> Array:
	var wave_data = [["blue_tank", 3.0], ["blue_tank", 0.1]]
	current_wave += 1
	enemies_in_wave = wave_data.size()
	return wave_data

func spawn_enemies(wave_data) -> void:
	for i in wave_data:
		var new_enemy = load("res://GameData/Baddies/" + i[0] + ".tscn").instantiate()
		new_enemy.connect("base_damage", Callable(self, "on_base_damage"))
		map_node.get_node("Path").add_child(new_enemy, true)
		await(get_tree().create_timer(i[1])).timeout

func on_base_damage(damage) -> void:
	base_health -= damage
	if base_health <= 0:
		emit_signal("game_finished", false)
	else:
		$UI.update_health_bar(base_health)


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

##connected to build buttons' pressed signal, data contains tower mods and aura tower status
func initiate_build_mode(tower_type: String, data: Dictionary) -> void:
	if build_mode:
		cancel_build_mode()
	build_data = data
	build_type = tower_type
	build_mode = true
	previous_tile = Vector2i(-100,-100)
	$UI.set_tower_preview(build_type, get_global_mouse_position(), build_data)

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
		$UI.update_tower_preview(tile_pos, "GREEN")
		build_valid = true
		build_location = tile_pos
		build_tile = current_tile
	else:
		$UI.update_tower_preview(tile_pos, "CRIMSON")
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
		
		#type not needed for mods/tower base
#		new_tower.type = build_type
#		new_tower.category = GameData.tower_data[build_type]["category"]

		##TowerContainer is in Map Scene
		map_node.get_node("TowerContainer").add_child(new_tower, true)
		exclusion_layer.set_cell(build_tile, 5, Vector2i(1,0), 0)
		astar.set_point_solid(build_tile, true)
		baddy_path_update()
		#deduct cash
		#update cash label


## Inventory Functions

func connect_inv_button_signal(inventory_slot) -> void: #connects new inventory slot signal
	inventory_slot.button_down.connect(on_inv_button_down.bind(inventory_slot, inventory_slot.slot_data.tower_mod))
	inventory_slot.hovered.connect(create_popup)
	inventory_slot.clear_popup.connect(clear_popup)

##button down for inventory slot
func on_inv_button_down(_inventory_slot, tower_mod) -> void:
	var new_draggable = DRAGGABLE_MOD.instantiate()
	GameData.is_dragging = true
	new_draggable.draggable = true
	new_draggable.data = tower_mod
	new_draggable.get_child(0).texture = tower_mod.texture
	new_draggable.mod_dropped.connect(inventory_ui.data.update_inventory)
	new_draggable.hovered.connect(create_popup)
	new_draggable.clear_popup.connect(clear_popup)
	build_bar.add_child(new_draggable)
	new_draggable.inventory_pos = Vector2((inventory_ui.global_position.x + inventory_ui.size.x/2), (inventory_ui.global_position.y + inventory_ui.size.y/2))
	new_draggable.initial_pos = get_global_mouse_position()

func create_popup(data) -> void:
	var popup = POPUP_PANEL.instantiate()
	var popup_size = popup.get_child(0).size
	popup.data = data
	popup.global_position = Vector2(get_global_mouse_position().x + (popup_size.x/2), get_global_mouse_position().y - popup_size.y)
	add_child(popup)
	clear_popup()
	cur_popup = popup

func clear_popup() -> void:
	if cur_popup != null:
		cur_popup.queue_free()
