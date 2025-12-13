extends Node

func _ready() -> void:
	load_main_menu()

func load_main_menu():
	$MainMenu/Margin/VBox/NewGame.pressed.connect(on_new_game_pressed)
	$MainMenu/Margin/VBox/Quit.pressed.connect(on_quit_pressed)

func on_new_game_pressed():
	get_node("MainMenu").queue_free()
	var game_scene = load("res://GameData/MainScenes/game_scene.tscn").instantiate()
	game_scene.game_finished.connect(endgame_check)
	add_child(game_scene)

func on_quit_pressed():
	get_tree().quit()

func endgame_check(result) -> void:
	if result:
		pass
	else:
		unload_game()

func unload_game():
	$GameScene.queue_free()
	var main_menu = load("res://GameData/UIScenes/main_menu.tscn").instantiate()
	add_child(main_menu)
	load_main_menu()
