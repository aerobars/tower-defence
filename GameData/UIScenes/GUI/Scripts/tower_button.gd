class_name BuildTowerButton extends TextureButton

##Signals
signal aura_update(aura_status: bool)

##Setup
@onready var mod_slot_scene := preload("res://GameData/UIScenes/GUI/mod_slot.tscn")
@export var build_cost_label : Label
@export var slot_count : int
@export var slot_radius : float
var tower := "tower_base"

##Gametime
var build_cost : int : 
	set(value): 
		build_cost = 1 + value * 3 #value should always be slot count
		build_cost_label.text = "$" + str(build_cost)
var current_mod_slots : Array : 
	get:
		var children : Array
		for child in get_children(): #adds mods to data Dictionary and checks if it is an aura tower
			if child.is_class("StaticBody2D"):
				children.append(child)
		return children
var data : Dictionary : get = get_tower_mods


##Setup
func _ready() -> void:
	for i in slot_count:
		new_mod_slot()
	update_mod_slots()

func new_mod_slot() -> void:
	var new_mod = mod_slot_scene.instantiate()
	add_child(new_mod)
	new_mod.mod_updated.connect(aura_check)

func update_mod_slots() -> void:
	var slot_num := 0
	for slot in get_children():
		if slot is ButtonModSlot:
			var angle = 0
			if slot_count > 4:
				angle = -PI/2 + slot_num * (TAU / (slot_count))
			else:
				angle = -(slot_num * (PI / (slot_count-1)))
			slot.position.x = slot_radius * cos(angle) + size.x/2
			slot.position.y = slot_radius * sin(angle) + size.y/2
			slot_num += 1
	build_cost = slot_count


##In-Game
func slot_added() -> void:
	slot_count += 1
	new_mod_slot()
	update_mod_slots()

func slot_removed() -> void:
	slot_count -= 1
	update_mod_slots()

func get_tower_mods() -> Dictionary:
	var dict : Dictionary
	var has_wep := false
	var has_aura := false
	var aura_tower := false
	
	for mod in current_mod_slots:
		dict[mod] = mod.data
		if not has_wep and dict[mod] != null:
			if mod.data.mod_class == mod.data.ModClass.WEAPON:
				has_wep = true
			elif mod.data.mod_class == mod.data.ModClass.AURA:
				has_aura = true
	
	if has_aura and not has_wep:
		aura_tower = true
	
	return {
		"aura_tower": aura_tower,
		"mods": dict
		}

func aura_check(_thing1, _thing2) -> void:
	var has_wep := false
	var has_aura := false
	var aura_tower := false
	
	for mod in current_mod_slots:
		if mod.data != null and not has_wep:
			if mod.data.mod_class == mod.data.ModClass.WEAPON:
				has_wep = true
			elif mod.data.mod_class == mod.data.ModClass.AURA:
				has_aura = true
	
	if has_aura and not has_wep:
		aura_tower = true
	aura_update.emit(aura_tower)
