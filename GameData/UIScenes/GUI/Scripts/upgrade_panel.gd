class_name UpgradePanel extends Node2D

signal upgrade

var data : Array #contains all towermod data of tower's mods, last array entry is level name
@onready var container : VBoxContainer = $Background/VBoxContainer
@onready var tower_name : Label = $Background/VBoxContainer/Name
#@onready var mod_class : Label = $Background/VBoxContainer/Class
#@onready var power : Label = $Background/VBoxContainer/Power
#@onready var description : Label = $Background/VBoxContainer/Description
var level = 0
var level_names := ["Basic", "Advanced", "Expert", "Master", "Grandmaster"]
var current_level_name : String: 
	get:
		return level_names[level]

func _ready() -> void:
	level = data[-1]
	tower_name.text = current_level_name + " Tower"
	for i in data:
		pass

	#stats_setup()
	#description.text = data.description


func _on_button_pressed() -> void:
	#confirm sufficient cash for upgrade before proceeding
	#deduct cash
	level = min(level + 1, 4)
	tower_name.text = current_level_name + " Tower"
	upgrade.emit()
