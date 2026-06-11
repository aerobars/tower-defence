extends Node2D

@export var path_health_bar : TextureProgressBar
@export var path_defence_label : Label 
@export var path_buff_display_container : HBoxContainer

func update_defence(value: int) -> void:
	path_defence_label.text = str(value)
