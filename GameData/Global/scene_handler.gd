extends Node

@onready var continue_button := $MainMenu/Margin/VBox/Continue
@onready var new_game := $MainMenu/Margin/VBox/NewGame
@onready var quit_button := $MainMenu/Margin/VBox/Quit
@onready var feedback_button := $MainMenu/Margin/VBox/Feedback
@onready var settings_button := $MainMenu/Margin/VBox/Settings

const GAME_SCENE = preload("res://GameData/MainScenes/Scenes/game_scene.tscn")
const SETTINGS_SCENE = preload("res://GameData/MainScenes/Scenes/settings.tscn")
var main_menu = preload("res://GameData/MainScenes/Scenes/main_menu.tscn")
var game_instance
var settings_instance
var unloading_game : bool = false
var unload_count : int = 0

var profile_data : Resource #variable to profile settings(resolution, sound volumes, etc.)

func _ready() -> void:
	#if player hasn't completed the tutorial, load into the game instead of the main menu
	if SaveManager.save_data_profile.tutorial_completed:
		load_main_menu()
	else:
		create_new_game(true)

func load_main_menu() -> void:
	continue_button.pressed.connect(on_continue_pressed)
	new_game.pressed.connect(on_new_game_pressed)
	quit_button.pressed.connect(on_quit_pressed)
	feedback_button.pressed.connect(on_feedback_pressed)
	settings_button.pressed.connect(open_settings)
	if SaveManager.existing_save():
		continue_button.visible = true
	else:
		continue_button.visible = false

func on_continue_pressed() -> void:
	create_new_game(false)

func on_new_game_pressed() -> void:
	create_new_game(true)

func create_new_game(is_new_game: bool) -> void: 
	get_node("MainMenu").queue_free()
	game_instance = game_scene_setup()
	if is_new_game:
		SaveManager.new_game()
	add_child(game_instance)

func game_scene_setup() -> Node2D:
	var game_scene = GAME_SCENE.instantiate()
	game_scene.open_settings.connect(open_settings)
	SaveManager.start_new_run.connect(game_scene.new_run_start)
	SaveManager.setup_saved_run.connect(game_scene.saved_run_setup)
	return game_scene

func open_settings() -> void:
	settings_instance = SETTINGS_SCENE.instantiate()
	settings_instance.close_settings.connect(close_settings)
	if game_instance:
		game_instance.connect_settings(settings_instance)
	add_child(settings_instance)
	get_tree().paused = true

func close_settings() -> void:
	get_tree().paused = false
	settings_instance.queue_free()
	

func on_quit_pressed() -> void:
	get_tree().quit()

func on_feedback_pressed() -> void:
	OS.shell_open("https://forms.gle/1gdVhHvJ8LJ4wVLX9")

func endgame_check() -> void:
	if unloading_game:
		return
	unloading_game = true
	unload_game()

func unload_game():
	game_instance.queue_free()
	var new_menu = main_menu.instantiate()
	add_child(new_menu)
	continue_button = $MainMenu/Margin/VBox/Continue
	new_game = $MainMenu/Margin/VBox/NewGame
	quit_button = $MainMenu/Margin/VBox/Quit
	feedback_button = $MainMenu/Margin/VBox/Feedback
	load_main_menu()
