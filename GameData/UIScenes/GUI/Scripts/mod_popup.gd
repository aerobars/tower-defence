class_name InfoPopup extends Node2D

var data : PrototypeMod
@export var container : VBoxContainer
@export var mod_name : Label
@export var mod_class : Label
@export var power : RichTextLabel
@export var description : Label
var level = 0

func _ready() -> void:
	mod_name.text = data.name
	mod_class.text = data.class_string.to_pascal_case() + " class"
	setup_stats()
	description.text = data.description

func setup_stats() -> void:
	match data.mod_class:
		0: #Aura
			var mod_range = rich_text_setup()
			mod_range.text = "Aura range: " + base_stats_array("range") + " units"
			container.add_child(mod_range)
			container.move_child(mod_range, 2)
			power.text = "Power Cost: " + base_stats_array("power")
			#set power font color to positive color
		1: #Power
			power.text = "Power Supply: " + base_stats_array("power")
		2: #Weapon
			var mod_range = rich_text_setup()
			var dps = rich_text_setup()
			dps.text = "DPS: " + base_stats_array("damage") + " dmg per " + base_stats_array("attack_speed") + " s"
			mod_range.text = "Range: " + base_stats_array("range") + " units"
			container.add_child(dps)
			container.move_child(dps, 2)
			if data.current_aoe > 0:
				var aoe = rich_text_setup()
				aoe.text = "AOE: " + base_stats_array("aoe") + " units"
				container.add_child(aoe)
				container.move_child(aoe, 3)
			container.add_child(mod_range)
			container.move_child(mod_range, 4)
			power.text = "Power Cost: " + base_stats_array("power")
	

func base_stats_array(value : String) -> String:
	var base_array
	var bold_text : String = "["
	var base_name : String = "base_" + value + "_levels"
	base_array = data.get(base_name)
	for i in base_array.size():
		if i == level:
			bold_text += "[b]%s[/b]" % str(base_array[i]) + ", "
		else:
			bold_text += "%s" % str(base_array[i]) + ","
	bold_text = bold_text.erase(bold_text.length() - 1, 1)
	bold_text += "]"
	return bold_text

func rich_text_setup() -> RichTextLabel:
	var rich : RichTextLabel = RichTextLabel.new()
	rich.bbcode_enabled = true
	rich.fit_content = true
	return rich
