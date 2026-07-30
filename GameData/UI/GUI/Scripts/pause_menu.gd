class_name PauseMenu extends Control

signal open_settings
signal save_and_quit
signal close_pause_menu


func _on_settings_button_up() -> void:
	open_settings.emit()

func _on_save_quit_button_up() -> void:
	save_and_quit.emit()

func _on_return_button_up() -> void:
	close_pause_menu.emit()
