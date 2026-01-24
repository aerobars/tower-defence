extends Node

var game_scene
var main_menu = preload("res://GameData/MainScenes/main_menu.tscn")

func _ready() -> void:
	load_main_menu()

func load_main_menu() -> void:
	$MainMenu/Margin/VBox/NewGame.pressed.connect(on_new_game_pressed)
	$MainMenu/Margin/VBox/Quit.pressed.connect(on_quit_pressed)
	$MainMenu/Margin/VBox/Feedback.pressed.connect(on_feedback_pressed)

func on_new_game_pressed() -> void:
	get_node("MainMenu").queue_free()
	var new_game = load("res://GameData/MainScenes/game_scene.tscn").instantiate()
	new_game.game_finished.connect(endgame_check)
	game_scene = new_game
	GameData.current_wave = 0
	GameData.current_act = 0
	add_child(new_game)

func on_quit_pressed() -> void:
	get_tree().quit()

func on_feedback_pressed() -> void:
	OS.shell_open("https://forms.gle/1gdVhHvJ8LJ4wVLX9")

func endgame_check(_result) -> void:
	unload_game()

func unload_game():
	game_scene.queue_free()
	var new_menu = main_menu.instantiate()
	add_child(new_menu)
	load_main_menu()
