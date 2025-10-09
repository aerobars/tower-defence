class_name TowerMod extends Resource

@export var name : String = ""
@export_multiline var description : String = ""
@export var texture: Texture2D

#level 0 to line up with arrays
var level := 0
var level_names := ["Basic", "Advanced", "Expert", "Master", "Grandmaster"]
var current_level_name : String : get = get_level_name

enum ModType { WEAPON, POWER, AURA }
@export var mod_class : ModType

@export var range : int = 0

func get_level_name() -> String:
	return level_names[level]

func level_up():
	level += 1
