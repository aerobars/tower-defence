extends Control

signal close_settings

func _on_return_button_up() -> void:
	#save settings to profile_data
	close_settings.emit()
