extends Node2D

signal game_finished(result)

var map_node : Node
const DRAGGABLE_MOD := preload("res://GameData/UIScenes/GUI/mod_draggable.tscn")
@onready var new_slot := $UI/HUD/BuildBar/InventoryContainer/InventoryGrid.connect("slot_created", connect_inv_button_signal)
@onready var build_bar := $UI/HUD/BuildBar
@onready var inventory_ui := $UI/HUD/BuildBar/InventoryContainer/InventoryGrid

var build_mode := false
var build_valid := false
var build_tile
var build_location
var build_type : String
var build_data : Dictionary[StaticBody2D, TowerMod]

var current_wave := 0
var enemies_in_wave := 0

var base_health := 100

func _ready() -> void:
	map_node = $Map #turn into variable if using multiple maps
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.pressed.connect(initiate_build_mode.bind(i.name.to_snake_case(), i.data))

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
		var new_enemy = load("res://GameData/Enemies/" + i[0] + ".tscn").instantiate()
		new_enemy.connect("base_damage", Callable(self, "on_base_damage"))
		map_node.get_node("Path").add_child(new_enemy, true)
		await(get_tree().create_timer(i[1])).timeout

func on_base_damage(damage) -> void:
	base_health -= damage
	if base_health <= 0:
		emit_signal("game_finished", false)
	else:
		$UI.update_health_bar(base_health)


## Building Functions

##connected to build buttons' pressed signal
func initiate_build_mode(tower_type: String, dict: Dictionary[StaticBody2D, TowerMod]) -> void:
	if build_mode:
		cancel_build_mode()
	build_data = dict
	build_type = tower_type
	build_mode = true
	$UI.set_tower_preview(build_type, get_global_mouse_position(), dict)

func update_tower_preview() -> void:
	var mouse_pos := get_global_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").local_to_map(mouse_pos)
	var tile_pos = map_node.get_node("TowerExclusion").map_to_local(current_tile)
	
	if map_node.get_node("TowerExclusion").get_cell_source_id(current_tile) == -1:
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
	$UI/TowerPreview.free()

func verify_and_build() -> void:
	if build_valid:
		var new_tower = load("res://GameData/Towers/" + build_type + ".tscn").instantiate()
		new_tower.position = build_location
		new_tower.is_built = true
		#type not needed for tower base
#		new_tower.type = build_type
#		new_tower.category = GameData.tower_data[build_type]["category"]
		#TowerContainer is in Map Scene
		map_node.get_node("TowerContainer").add_child(new_tower, true)
		map_node.get_node("TowerExclusion").set_cell(build_tile, 5, Vector2i(1,0), 0)
		#deduct cash
		#update cash label


## Inventory Functions

func connect_inv_button_signal(inventory_slot) -> void: #connects new inventory slot signal
	inventory_slot.button_down.connect(on_inv_button_down.bind(inventory_slot, inventory_slot.slot_data.tower_mod))

##button down for inventory slot
func on_inv_button_down(_inventory_slot, tower_mod) -> void:
	var new_draggable = DRAGGABLE_MOD.instantiate()
	GameData.is_dragging = true
	new_draggable.draggable = true
	new_draggable.data = tower_mod
	new_draggable.get_child(0).texture = tower_mod.texture
	new_draggable.mod_dropped.connect(inventory_ui.update_inventory)
	build_bar.add_child(new_draggable)
	new_draggable.inventory_pos = get_global_mouse_position()
	new_draggable.initial_pos = get_global_mouse_position()
