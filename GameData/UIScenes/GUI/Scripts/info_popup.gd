class_name InfoPanel extends Node2D

var data : TowerMod
@onready var container : VBoxContainer = $Background/VBoxContainer
@onready var mod_name : Label = $Background/VBoxContainer/Name
@onready var mod_class : Label = $Background/VBoxContainer/Class
@onready var power : Label = $Background/VBoxContainer/Power
@onready var description : Label = $Background/VBoxContainer/Description
var level = 0

func _ready() -> void:
	mod_name.text = data.name
	mod_class.text = data.class_string.to_pascal_case() + " class"
	stats_setup()
	description.text = data.description

func stats_setup() -> void:
	match data.mod_class:
		0: #Aura
			var mod_range = Label.new()
			mod_range.text = "Aura range: " + str(data.base_range_levels[level]) + " units"
			container.add_child(mod_range)
			container.move_child(mod_range, 2)
			power.text = "Power Cost: " + str(data.base_power_levels[level])
		1: #Power
			power.text = "Power Supply: " + str(data.base_power_levels[level])
		2: #Weapon
			var mod_range = Label.new()
			var dps = Label.new()
			dps.text = str(data.base_damage_levels[level]) + " dmg per " + str(data.base_attack_speed_levels[level]) + "s (" + str(data.base_damage_levels[level]/data.base_attack_speed_levels[level]) + " dps)"
			mod_range.text = "Range: " + str(data.base_range_levels[level]) + " units"
			container.add_child(dps)
			container.move_child(dps, 2)
			if data.current_aoe > 0:
				var aoe = Label.new()
				aoe.text = str(data.base_aoe_levels[level]) + " unit aoe"
				container.add_child(aoe)
				container.move_child(aoe, 3)
			container.add_child(mod_range)
			container.move_child(mod_range, 4)
			power.text = "Power Cost: " + str(data.base_power_levels[level])
			power.text = "Power Cost: " + str(data.base_power_levels[level])
