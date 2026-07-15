extends Node2D

signal game_finished(result)
signal tower_cell_update_check

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
@export var path_ui : CanvasLayer
@export var path_range_display : Sprite2D
@export var path_camera : Camera2D
var cur_popup : Node2D

@export_subgroup("Containers", "path_")
@export var path_build_mode_container : Node2D
@export var path_tower_container : Node2D
@export var path_baddy_container : Node2D
@export var path_projectile_container : Node2D

## Pathfinding

@export_subgroup("Map and Pathfinding", "path_")
@export var path_map_node : Node2D #set in _ready instead if using multiple maps
@export var path_pathfinding_line :Line2D
var preview_path : PackedVector2Array = []

var tower_grid_size : int :
	get():
		return path_map_node.CELL_SIZE * 3 #CELL_SIZE * number of columns in tower grid(3)
var previous_tiles : Array[Vector2i]

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
var is_game_over : bool = false


## Build Mode

##"aura_tower": bool, "mods": button_data.mod_data (Dictionary[slot_id: int, PrototypeMod]), "power_buffs": power_surplus_buffs (Dictionary[stat, amt: int]), "shape": button_data.tower_shape (Array[Vector2i])
var build_data : TowerBuildData
var build_location : Vector2 = Vector2(0, 0)
var build_rotation : float = 0.0
var build_mode : bool = false
var build_tiles : Array[Vector2i]
var build_valid : bool = false
@onready var tower_base_scene : PackedScene = preload("res://GameData/Towers/Scenes/tower_base.tscn")
var tower_preview : Node2D


func _ready() -> void:
	
	## Child Node Setup
	path_ui.update_health_bar(player_health, max_player_health)
	path_ui.update_cash_display(player_cash)
	path_ui.check_build_mode.connect(path_build_mode_container.check_build_mode)
	path_ui.connect_new_button.connect(connect_new_button)
	path_ui.connect_inv_button.connect(connect_inv_slot)
#	path_ui.create_popup.connect(create_popup)
#	path_ui.clear_popup.connect(clear_popup)
#	path_ui.engage_build_mode.connect(path_build_mode_container.initiate_build_mode)
	path_ui.start_next_wave.connect(path_baddy_container.start_next_wave)
	
	path_baddy_container.new_baddy_spawned.connect(new_baddy_spawn)
	path_baddy_container.base_damaged.connect(on_base_damage)
	path_baddy_container.game_over.connect(game_over)
	path_baddy_container.wave_cleared.connect(wave_cleared)
	
	path_build_mode_container.cell_size = path_map_node.CELL_SIZE
	path_build_mode_container.path_map = path_map_node
	path_build_mode_container.build_tower.connect(on_tower_built)
	
	path_map_node.path_baddy_container = path_baddy_container
	
	path_tower_container.connect_new_tower.connect(connect_new_tower_base)
	path_tower_container.new_tower_built.connect(path_map_node.on_tower_built)
	path_tower_container.tower_sold.connect(path_map_node.on_tower_sold)
	path_tower_container.tower_sold.connect(on_tower_sold)
	
	## Initial Setup
	
	path_ui.setup_ui()
	
	
	if SaveManager.save_data_run.new_game : #rest of func only needs to run to load saved towers
		SaveManager.complete_new_game_setup()
		return
	
	## Saved Run Setup
	
	for tower in SaveManager.save_data_run.tower_data:
		for button in get_tree().get_nodes_in_group("build_buttons"):
			if button.button_data.button_id == tower.connected_button_id:
				path_tower_container.create_tower(button.tower_data, button, tower.position, tower.rotation, tower.level, true)
	
	## Saved Draggable Mod Position Set
	await get_tree().process_frame
	for mod in get_tree().get_nodes_in_group("droppable"):
		if mod is ModDraggable:
			mod.global_position = mod.mod_slot_ref.global_position



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel") and path_build_mode_container.build_mode:
		path_build_mode_container.cancel_build_mode()
	if event.is_action("ui_accept"): 
		clear_popup()
		if current_unit:
			current_unit.set_selected(false)
			current_unit = null
		if path_build_mode_container.build_mode:
			path_build_mode_container.verify_and_build()
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
	if not path_build_mode_container.build_mode:
		return
	if event.is_action_pressed("rotate_counterclockwise"):
		var tween = get_tree().create_tween()
		tween.tween_property(path_build_mode_container, "rotation", path_build_mode_container.rotation - PI/2, 0.1)
#		tower_preview.tower_data.rotation = path_build_mode_container.rotation
		#counter rotate mod image
		return
	if event.is_action_pressed("rotate_clockwise"):
		var tween = get_tree().create_tween()
		tween.tween_property(path_build_mode_container, "rotation", path_build_mode_container.rotation + PI/2, 0.1)
#		tower_preview.tower_data.rotation = path_build_mode_container.rotation
		#counter rotate mod image
		return

## Wave Functions

func new_baddy_spawn(new_baddy) -> void:
	new_baddy.unit_selected.connect(on_unit_selection)
	new_baddy.update_baddy_display.connect(path_ui.update_baddy_info)
	new_baddy.open_baddy_display.connect(path_ui.open_baddy_display)
	path_map_node.pathing_updated.connect(new_baddy.update_pathing)
	new_baddy.path_map = path_map_node
	new_baddy.global_position = path_map_node.path_start_point.global_position + path_map_node.CELL_CENTRE

func on_base_damage(damage) -> void:
	player_health -= damage
	if player_health <= 0 and not is_game_over:
		game_over()

func wave_cleared() -> void:
	if is_game_over:
		return
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

func game_over() -> void:
	is_game_over = true
	path_ui.game_over(is_game_over)

## Building Functions

func check_cash(value) -> bool:
	if player_cash < value:
		path_ui.update_game_message("Unable to build: insufficient funds", 1.0, 0.5)
		return false
	return true

func connect_new_tower_base(new_tower: TowerBase) -> void:
	new_tower.show_upgrade_panel.connect(create_popup)
	new_tower.unit_selected.connect(on_unit_selection)
	new_tower.update_range_display.connect(update_range_display)
	new_tower.hide_range_display.connect(hide_range_display)
	new_tower.cell_created.connect(connect_new_tower_cell)

func connect_new_tower_cell(new_cell: TowerCell) -> void:
	new_cell.create_projectile.connect(path_projectile_container.create_projectile)
	new_cell.mod_updated.connect(tower_cell_updated) #for when new_cell gets updated
	tower_cell_update_check.connect(new_cell.on_tower_cell_updated) #for when other mods get updated

func on_tower_built(data, build_btn_ref, tower_rotation) -> void:
	player_cash -= build_btn_ref.build_cost
	path_ui.update_cash_display(player_cash)
	path_tower_container.create_tower(data, build_btn_ref, tower_rotation)

func on_tower_sold(sell_value: int, _tower) -> void:
	player_cash += sell_value
	path_ui.update_cash_display(player_cash)

func upgrade_check(upgrade_cost : int, tower : TowerBase, popup : TowerPopup) -> void:
	if player_cash < upgrade_cost:
		path_ui.update_game_message("Unable to upgrade: insufficient funds", 1.0, 0.5)
	else:
		tower.level_up()
		popup.setup_stats()
		player_cash -= upgrade_cost
		path_ui.update_cash_display(player_cash)

## GUI Functions

func connect_new_button(new_button: BuildTowerButton) -> void:
	new_button.create_draggable.connect(create_draggable)
	new_button.pressed.connect(func(): path_build_mode_container.initiate_build_mode(new_button.tower_data, new_button))

func connect_inv_slot(new_inv_slot: InventorySlotUI) -> void:
	new_inv_slot.button_down.connect(func(): create_draggable(new_inv_slot.slot_data.inventory_mod))
	new_inv_slot.hovered.connect(create_popup)
	new_inv_slot.clear_popup.connect(clear_popup)

func create_draggable(
	tower_mod: ModPrototype, 
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
		popup.sell.connect(path_tower_container.sell_tower)
	path_ui.add_child(popup)
	cur_popup = popup

func clear_popup() -> void:
	if cur_popup != null:
		cur_popup.queue_free()

func update_range_display(tower: TowerCell) -> void:
	path_range_display.global_position = tower.global_position
	var scaling : float = tower.data.current_range / 300.0
	if tower.data.mod_class == ModPrototype.ModClass.WEAPON:
		path_range_display.modulate = Color("CRIMSON")
	elif tower.data.mod_class == ModPrototype.ModClass.AURA:
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

func tower_cell_updated(cell: TowerCell) -> void:
	tower_cell_update_check.emit(cell)
