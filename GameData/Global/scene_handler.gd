extends Node

@onready var continue_button := $MainMenu/Margin/VBox/Continue
@onready var new_game := $MainMenu/Margin/VBox/NewGame
@onready var quit_button := $MainMenu/Margin/VBox/Quit
@onready var feedback_button := $MainMenu/Margin/VBox/Feedback

const GAME_SCENE = preload("res://GameData/MainScenes/game_scene.tscn")
var main_menu = preload("res://GameData/MainScenes/main_menu.tscn")
var game_instance

var profile_data : Resource #variable to profile settings(resolution, sound volumes, etc.)

func _ready() -> void:
	load_main_menu()
	if SaveManager.existing_save():
		continue_button.visible = true
	else:
		continue_button.visible = false

func load_main_menu() -> void:
	continue_button.pressed.connect(on_continue_pressed)
	new_game.pressed.connect(on_new_game_pressed)
	quit_button.pressed.connect(on_quit_pressed)
	feedback_button.pressed.connect(on_feedback_pressed)

func on_continue_pressed() -> void:
	pass

func on_new_game_pressed() -> void:
	get_node("MainMenu").queue_free()
	var new_game = GAME_SCENE.instantiate()
	new_game.game_finished.connect(endgame_check)
	game_instance = new_game
	SaveManager.save_data_run.current_wave = 0
	SaveManager.save_data_run.current_act = 0
	add_child(new_game)

func on_quit_pressed() -> void:
	get_tree().quit()

func on_feedback_pressed() -> void:
	OS.shell_open("https://forms.gle/1gdVhHvJ8LJ4wVLX9")

func endgame_check(_result) -> void:
	unload_game()

func unload_game():
	game_instance.queue_free()
	var new_menu = main_menu.instantiate()
	add_child(new_menu)
	load_main_menu()
