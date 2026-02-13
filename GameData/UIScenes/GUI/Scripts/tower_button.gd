class_name BuildTowerButton extends TextureButton

## Signals
signal update_towers(mod_slot_ref: StaticBody2D, slot_data: PrototypeMod, aura_status: bool, power_surplus_buffs : Dictionary)

## Setup
@onready var mod_slot_scene := preload("res://GameData/UIScenes/GUI/mod_slot.tscn")
@export var build_cost_label : Label
@export var net_power_display : Label

var button_data : ButtonData
@export var slot_count : int
@export var slot_radius : float
var tower := "tower_base"
var button_slots : Array :
	get:
		var children : Array = []
		for slot in get_children():
			if slot is ButtonModSlot:
				children.append(slot)
		return children

## Gametime
var build_cost : int : 
	set(value): 
		build_cost = 1 + value * 3 #value should always be slot count
		build_cost_label.text = "$" + str(build_cost)
var tower_data : Dictionary : get = get_tower_mods

## Setup
func _ready() -> void:
	for i in slot_count:
		new_mod_slot()
	update_mod_slots()
	$PowerIcon.modulate.a = 0.5

func new_mod_slot() -> void:
	var new_mod = mod_slot_scene.instantiate()
	add_child(new_mod)
	new_mod.mod_updated.connect(on_mod_update)

func update_mod_slots() -> void:
	var slot_num := 0
	for slot in button_slots:
		var angle = 0
		if slot_count > 4:
			angle = -PI/2 + slot_num * (TAU / (slot_count))
		else:
			angle = -(slot_num * (PI / (slot_count-1)))
		slot.position.x = slot_radius * cos(angle) + size.x/2
		slot.position.y = slot_radius * sin(angle) + size.y/2
		slot_num += 1
	build_cost = slot_count

## In-Game
func slot_added() -> void:
	slot_count += 1
	new_mod_slot()
	update_mod_slots()

func slot_removed() -> void:
	slot_count -= 1
	update_mod_slots()

func get_tower_mods() -> Dictionary:
	var mod_dict : Dictionary
	var power_surplus_buffs : Dictionary
	var has_wep := false
	var has_aura := false
	var aura_tower := false
	
	for child in button_slots: #adds mods to data Dictionary and checks if it is an aura tower
		mod_dict[child] = child.data
		if not has_wep and mod_dict[child] != null:
			if child.data.mod_class == child.data.ModClass.WEAPON:
				has_wep = true
			elif child.data.mod_class == child.data.ModClass.AURA:
				has_aura = true
		if child.data is PowerMod:
			var stat_name : String = ""
			for stat in GlobalEnums.BuffableStats.keys():
				for i in child.data.power_surplus_buffable_stats:
					if i & GlobalEnums.BuffableStats[stat]:
						stat_name = stat.to_lower()
						if not power_surplus_buffs.has(stat_name):
							power_surplus_buffs[stat_name] = 0
						power_surplus_buffs[stat_name] += 1
	
	if has_aura and not has_wep:
		aura_tower = true
	
	return {
		"aura_tower": aura_tower,
		"mods": mod_dict,
		"power_buffs": power_surplus_buffs,
		}

func on_mod_update(slot_ref : ButtonModSlot, data : PrototypeMod) -> void:
	var net_power := 0
	var power_surplus_buffs : Dictionary = {}
	var has_wep := false
	var has_aura := false
	var aura_status := false
	
	for child in button_slots:
		if child.data != null:
			net_power += child.data.base_power_levels[0]
			if child.data is PowerMod: #power updates
				var stat_name : String = ""
				for stat in GlobalEnums.BuffableStats.keys():
					for i in child.data.power_surplus_buffable_stats:
						if i & GlobalEnums.BuffableStats[stat]:
							stat_name = stat.to_lower()
							if not power_surplus_buffs.has(stat_name):
								power_surplus_buffs[stat_name] = 0
							power_surplus_buffs[stat_name] += 1
			else: #aura updates
				if not has_wep:
					if child.data.mod_class == child.data.ModClass.WEAPON:
						has_wep = true
					elif child.data.mod_class == child.data.ModClass.AURA:
						has_aura = true
	if has_aura and not has_wep:
		aura_status = true
	update_towers.emit(aura_status, power_surplus_buffs, slot_ref, data)
	
	if net_power > 0: #set color for power states
		#net_power_display.add_theme_color_override("font_color", GameData.positive_color)
		pass
	else: 
		#net_power_display.add_theme_color_override("font_color", GameData.negative_color)
		pass
	net_power_display.text = str(net_power)
