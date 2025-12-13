class_name BuildTowerButton extends TextureButton


##Setup
@onready var mod_slot := preload("res://GameData/UIScenes/GUI/mod_slot.tscn")
@export var slot_count : int
@export var slot_radius : float
var tower := "tower_base"


var data : Dictionary : get = get_tower_mods

func _ready() -> void:
	for i in slot_count:
		update_mod_slots(i)

func update_mod_slots(mod_num) -> void:
	var new_mod = mod_slot.instantiate()
	var angle = (TAU * mod_num) / slot_count
	new_mod.position.x = slot_radius * cos(angle) + size.x/2
	new_mod.position.y = slot_radius * sin(angle) + size.y/2
	add_child(new_mod)

func get_tower_mods() -> Dictionary:
	var dict : Dictionary
	var has_wep := false
	var has_aura := false
	var aura_tower := false
	
	#adds mods to data Dictionary and checks if it is an aura tower
	for child in get_children():
		if child.is_class("StaticBody2D"):
			dict[child] = child.data
			if not has_wep and dict[child] != null:
				if child.data.mod_class == child.data.ModType.WEAPON:
					has_wep = true
				elif child.data.mod_class == child.data.ModType.AURA:
					has_aura = true
	
	if has_aura and not has_wep:
		aura_tower = true
	
	return {
		"aura_tower": aura_tower,
		"mods": dict
		}

#func aura_check() -> bool:
	
