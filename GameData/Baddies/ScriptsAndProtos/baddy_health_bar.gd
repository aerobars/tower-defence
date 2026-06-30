extends Node2D

@export var path_health_bar : TextureProgressBar
@export var path_defence_label : Label 
@export var path_buff_display_container : HBoxContainer
@export var path_defence_icon : TextureRect

#func _ready() -> void:
#	var atlas = AtlasTexture.new()
#	atlas.atlas = GameData.ICON_ATLAS
#	atlas.region = GameData.ICON_DEFENCE_COORDS
#	path_defence_icon.texture = atlas

func update_defence(value: int) -> void:
	path_defence_label.text = str(value)
