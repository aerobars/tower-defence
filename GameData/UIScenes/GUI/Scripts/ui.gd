extends CanvasLayer

signal create_draggable
signal engage_build_mode(data: Dictionary, btn_ref)
signal start_next_wave
signal check_build_mode
signal create_popup
signal clear_popup

@export_group("Node Paths", "path_")
@export var path_hp_bar : TextureProgressBar
@export var path_hp_text : Label
@export var path_cash_display : Label
@export var path_game_message : Label
@export var path_baddy_info_foldbable : FoldableContainer

@export var path_next_wave_button : Button
@export var path_pause_button : TextureButton
@export var path_ff_button : TextureButton
@export var path_build_bar : ColorRect
@export var path_inventory_ui : GridContainer
@export var path_tower_buttons : HBoxContainer
@export var path_game_bookend_popup : Control
@export var path_tutorial : Control

@onready var new_slot := path_inventory_ui.connect("slot_created", connect_inv_button_signal)

const GAME_MESSAGE_A_VALUE = 0.78
const TOWER_BUTTON := preload("res://GameData/UIScenes/GUI/Scenes/tower_button.tscn")
@onready var texture : CompressedTexture2D = preload("res://Assets/UI/range_overlay.png")
@onready var tower : PackedScene = preload("res://GameData/Towers/Scenes/tower_base.tscn")

func _ready() -> void:
	update_wave_button()
	
	## Button Setup
	var build_buttons_count : int
	if SaveManager.save_data_run.new_game:
		build_buttons_count = SaveManager.save_data_run.init_btn_count
	else:
		build_buttons_count = SaveManager.save_data_run.button_data.size() #input some other value once it's time
	for i in build_buttons_count:
		create_tower_button(i)

## Tower Preview

func initiate_build_mode(data: TowerBuildData, btn_ref: BuildTowerButton) -> void:
	engage_build_mode.emit(data, btn_ref)

## UI

func _on_pause_play_pressed() -> void:
	check_build_mode.emit()
	if get_tree().is_paused():
		get_tree().paused = false
	else:
		get_tree().paused = true

func _on_next_wave_pressed() -> void:
	check_build_mode.emit()
	if get_tree().is_paused():
		get_tree().paused = false
		path_pause_button.set_pressed_no_signal(true)
	update_game_message("Next wave starting", 3.0, 0.5)
	await get_tree().create_timer(2.0, false).timeout #padding before wave start
	start_next_wave.emit()

func _on_fast_forward_pressed() -> void:
	check_build_mode.emit()
	if Engine.get_time_scale() == 2.0:
		Engine.set_time_scale(1.0)
	else:
		Engine.set_time_scale(2.0)

func create_tower_button(num: int) -> void:
	var new_button = TOWER_BUTTON.instantiate()
	new_button.button_data = TowerButtonData.new()
	if SaveManager.save_data_run.new_game:
		new_button.button_data.button_id = num + 1
		new_button.button_data.tower_shape = SaveManager.save_data_run.init_tower_shapes[num] as Array[Vector2i]
		SaveManager.save_data_run.button_data.append(new_button.button_data)
	else:
		new_button.button_data = SaveManager.save_data_run.button_data[num]
	new_button.create_draggable.connect(initiate_create_draggable)
	new_button.pressed.connect(func(): initiate_build_mode(new_button.tower_data, new_button))
	path_tower_buttons.add_child(new_button)

func initiate_create_draggable(
	tower_mod: ModPrototype, 
	initial_pos : Vector2 = Vector2(0,0), 
	slot_occupied : TowerButtonModSlot = null, 
	_is_dragging = true
	) -> void:
	create_draggable.emit(tower_mod, initial_pos, slot_occupied, _is_dragging)

func connect_inv_button_signal(inventory_slot) -> void: #connects new inventory slot signal
	inventory_slot.button_down.connect(func(): initiate_create_draggable(inventory_slot.slot_data.inventory_mod))
	inventory_slot.hovered.connect(initiate_create_popup)
	inventory_slot.clear_popup.connect(initiate_clear_popup)

func initiate_create_popup(popup_type: String , data, popup_owner : TowerBase = null) -> void:
	create_popup.emit(popup_type, data, popup_owner)

func initiate_clear_popup() -> void:
	clear_popup.emit()

## Display Updates

func update_health_bar(cur_health: int, max_health: int) -> void:
	var hp_bar_tween := path_hp_bar.create_tween()
	hp_bar_tween.tween_property(path_hp_bar, "value", cur_health, 0.1)
	path_hp_text.text = str(max(cur_health, 0)) + "/" + str(max_health)
	if cur_health >= 60:
		path_hp_bar.set_tint_progress("00a800")#Green
	elif cur_health >= 25:
		path_hp_bar.set_tint_progress("c77200")#Orange
	else:
		path_hp_bar.set_tint_progress("ff0000")#Red

func update_cash_display(amount: int) -> void:
	path_cash_display.text = str(amount)

func update_wave_button() -> void:
	path_next_wave_button.text = "Start Wave " + str(SaveManager.save_data_run.current_wave + 1)

func update_game_message(message : String, display_time : float = 3.0, fade_time : float = 0.0, font_size : int = 25) -> void:
	path_game_message.modulate.a = GAME_MESSAGE_A_VALUE
	path_game_message.add_theme_font_size_override("font_size", font_size)
	path_game_message.text = message
	path_game_message.visible = true
	await(get_tree().create_timer(display_time - fade_time, false)).timeout
	await path_game_message.create_tween().tween_property(path_game_message, "modulate:a", 0.0, fade_time).finished
	path_game_message.visible = false

## Baddy Info Foldable

func update_wave_info(baddy_data: Array) -> void:
	path_baddy_info_foldbable.wave_display(baddy_data)

func open_baddy_display(baddy: Baddy) -> void:
	path_baddy_info_foldbable.open_display(baddy)

func update_baddy_info(baddy: Baddy) -> void:
	path_baddy_info_foldbable.update_display(baddy)

func clear_baddy_info() -> void:
	path_baddy_info_foldbable.clear_display()

func game_over(_result) -> void:
	path_game_bookend_popup.game_over = true
	update_game_message("Game Over!", 2.0, 0.0, 75)
	path_game_bookend_popup.get_node("TextureRect/Label").text = "Thank you for playing! 
	Please click the button below to complete a quick feedback survey and return to the main menu (and start a new game (＾ ＾)b )"
	path_game_bookend_popup.get_node("TextureRect/Button").text = "Go to survey"
	path_game_bookend_popup.visible = true
