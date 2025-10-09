extends Node

func _ready() -> void:
	load_main_menu()

func load_main_menu():
	get_node("MainMenu/Margin/VBox/NewGame").pressed.connect(on_new_game_pressed)
	get_node("MainMenu/Margin/VBox/Quit").pressed.connect(on_quit_pressed)

func on_new_game_pressed():
	get_node("MainMenu").queue_free()
	var game_scene = load("res://GameData/MainScenes/game_scene.tscn").instantiate()
	game_scene.connect("game_finished", Callable(self, "unload_game"))
	add_child(game_scene)

func on_quit_pressed():
	get_tree().quit()

func unload_game():
	$game_scene.queue_free()
	var main_menu = load("res://GameData/UIScenes/main_menu.tscn").instantiate()
	add_child(main_menu)
	load_main_menu()
