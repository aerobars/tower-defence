extends Node

func _ready() -> void:
	load_main_menu()

func load_main_menu():
	$MainMenu/Margin/VBox/NewGame.pressed.connect(on_new_game_pressed)
	$MainMenu/Margin/VBox/Quit.pressed.connect(on_quit_pressed)

func on_new_game_pressed():
	get_node("MainMenu").queue_free()
	var new_game = load("res://GameData/MainScenes/game_scene.tscn").instantiate()
	new_game.game_finished.connect(endgame_check)
	add_child(new_game)

func on_quit_pressed():
	get_tree().quit()

func endgame_check(_result) -> void:
	await get_tree().create_timer(5.0, true).timeout
	unload_game()

func unload_game():
	$GameScene.queue_free()
	var main_menu = load("res://GameData/UIScenes/main_menu.tscn").instantiate()
	add_child(main_menu)
	load_main_menu()
