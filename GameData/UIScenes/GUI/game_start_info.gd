extends Control

var game_over := false


func _on_button_button_up() -> void:
	if not game_over:
		visible = false
	else:
		OS.shell_open("https://forms.gle/1gdVhHvJ8LJ4wVLX9")
		get_parent().get_parent().get_parent().game_finished.emit(false)
