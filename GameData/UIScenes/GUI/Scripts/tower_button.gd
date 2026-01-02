class_name BuildTowerButton extends TextureButton

##Setup
@onready var mod_slot := preload("res://GameData/UIScenes/GUI/mod_slot.tscn")
@export var build_cost_label : Label
@export var slot_count : int
@export var slot_radius : float
var tower := "tower_base"
var build_cost : int : 
	set(value): 
		build_cost = 4 + value * 2 #value should always be slot count
		build_cost_label.text = "$" + str(build_cost)


var data : Dictionary : get = get_tower_mods

func _ready() -> void:
	for i in slot_count:
		new_mod_slot()
	update_mod_slots()

func new_mod_slot() -> void:
	var new_mod = mod_slot.instantiate()
	add_child(new_mod)

func update_mod_slots() -> void:
	var slot_num := 0
	for slot in get_children():
		if slot is ButtonModSlot:
			var angle = (TAU * slot_num) / slot_count
			slot.position.x = slot_radius * cos(angle) + size.x/2
			slot.position.y = slot_radius * sin(angle) + size.y/2
			slot_num += 1
	build_cost = slot_count

func get_tower_mods() -> Dictionary:
	var dict : Dictionary
	var has_wep := false
	var has_aura := false
	var aura_tower := false
	
	for child in get_children(): #adds mods to data Dictionary and checks if it is an aura tower
		if child.is_class("StaticBody2D"):
			dict[child] = child.data
			if not has_wep and dict[child] != null:
				if child.data.mod_class == child.data.ModClass.WEAPON:
					has_wep = true
				elif child.data.mod_class == child.data.ModClass.AURA:
					has_aura = true
	
	if has_aura and not has_wep:
		aura_tower = true
	
	return {
		"aura_tower": aura_tower,
		"mods": dict
		}
