class_name UpgradePanel extends Node2D

var data : Array
@onready var container : VBoxContainer = $Background/VBoxContainer
@onready var mod_name : Label = $Background/VBoxContainer/Name
@onready var mod_class : Label = $Background/VBoxContainer/Class
@onready var power : Label = $Background/VBoxContainer/Power
@onready var description : Label = $Background/VBoxContainer/Description
var level = 0

func _ready() -> void:
	pass
	#mod_name.text = data.name
	#mod_class.text = data.class_string.to_pascal_case() + " class"
	#stats_setup()
	#description.text = data.description
