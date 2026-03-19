extends Node

@onready var continue_button := $MainMenu/Margin/VBox/Continue
@onready var new_game := $MainMenu/Margin/VBox/NewGame
@onready var quit_button := $MainMenu/Margin/VBox/Quit
@onready var feedback_button := $MainMenu/Margin/VBox/Feedback

const GAME_SCENE = preload("res://GameData/MainScenes/game_scene.tscn")
var main_menu = preload("res://GameData/MainScenes/main_menu.tscn")
var game_instance
var unloading_game : bool = false
var unload_count : int = 0

var profile_data : Resource #variable to profile settings(resolution, sound volumes, etc.)

func _ready() -> void:
	load_main_menu()


func load_main_menu() -> void:
	continue_button.pressed.connect(on_continue_pressed)
	new_game.pressed.connect(on_new_game_pressed)
	quit_button.pressed.connect(on_quit_pressed)
	feedback_button.pressed.connect(on_feedback_pressed)
	if SaveManager.existing_save():
		continue_button.visible = true
	else:
		continue_button.visible = false

func on_continue_pressed() -> void:
	create_new_game(false)

func on_new_game_pressed() -> void:
	create_new_game(true)

func create_new_game(new_game_status: bool) -> void: 
	get_node("MainMenu").queue_free()
	var game_scene = GAME_SCENE.instantiate()
	game_scene.game_finished.connect(endgame_check)
	game_instance = game_scene
	if new_game_status:
		SaveManager.new_game()
	SaveManager.save_data_run.new_game = new_game_status
	add_child(game_instance)

func on_quit_pressed() -> void:
	get_tree().quit()

func on_feedback_pressed() -> void:
	OS.shell_open("https://forms.gle/1gdVhHvJ8LJ4wVLX9")

func endgame_check(_result) -> void:
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
