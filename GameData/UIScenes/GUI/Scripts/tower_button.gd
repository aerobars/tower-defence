class_name BuildTowerButton extends TextureButton

## Signals
signal update_towers(
	aura_status: bool, 
	power_surplus_buffs : Dictionary,
	mod_slot_ref: StaticBody2D, 
	slot_data: PrototypeMod,
	) 
signal create_draggable()

## Setup
@onready var mod_slot_scene := preload("res://GameData/UIScenes/GUI/tower_button_mod_slot.tscn")
@export var build_cost_label : Label
@export var net_power_display : Label

@export var button_data : TowerButtonData #contains mod slot data, slot count, and id
@export var slot_radius : float
var slot_data_ref : Dictionary
var button_slots : Array :
	get:
		var children : Array = []
		for slot in get_children():
			if slot is TowerButtonModSlot:
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
	for i in button_data.slot_count:
		new_mod_slot(i)
	$PowerIcon.modulate.a = 0.5

func new_mod_slot(slot_num: int) -> void:
	var new_slot = mod_slot_scene.instantiate()
	new_slot.slot_id = button_data.button_id * 10 + slot_num
	add_child(new_slot)
	new_slot.mod_updated.connect(on_mod_update)
	var angle : float
	if button_data.slot_count > 4:
		angle = -PI/2 + slot_num * (TAU / (button_data.slot_count))
	else:
		angle = -(slot_num * (PI / (button_data.slot_count-1)))
	new_slot.position.x = slot_radius * cos(angle) + size.x/2
	new_slot.position.y = slot_radius * sin(angle) + size.y/2
	if button_data.mod_data == null:
		return
	if button_data.mod_data.size() >=1 and button_data.mod_data[slot_num] != null:
		var data = button_data.mod_data[slot_num]
		create_draggable.emit(data, new_slot.global_position, new_slot)

func update_mod_slots() -> void:
	var slot_num := 0
	for slot in button_slots:
		var angle = 0
		if button_data.slot_count > 4:
			angle = -PI/2 + slot_num * (TAU / (button_data.slot_count))
		else:
			angle = -(slot_num * (PI / (button_data.slot_count-1)))
		slot.position.x = slot_radius * cos(angle) + size.x/2
		slot.position.y = slot_radius * sin(angle) + size.y/2
		slot_num += 1
	build_cost = button_data.slot_count

## In-Game
func slot_added() -> void:
	button_data.slot_count += 1
	new_mod_slot(button_data.slot_count)
	update_mod_slots()

func slot_removed() -> void:
	button_data.slot_count -= 1
	update_mod_slots()

func get_tower_mods() -> Dictionary:
	var mod_dict : Dictionary
	var power_surplus_buffs : Dictionary
	var has_wep := false
	var has_aura := false
	
	for child in button_slots: #adds mods to data Dictionary and checks if it is an aura tower
		mod_dict[child.slot_id] = child.data
		if not has_wep and mod_dict[child.slot_id] != null:
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
	
	return {
		"aura_tower": has_aura and not has_wep,
		"mods": mod_dict,
		"power_buffs": power_surplus_buffs,
		}

func on_mod_update(slot_id : int, data : PrototypeMod) -> void:
	var net_power := 0
	var power_surplus_buffs : Dictionary = {}
	var has_wep := false
	var has_aura := false
	
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
	update_towers.emit(has_aura and not has_wep, power_surplus_buffs, slot_id, data)
	
	if net_power > 0: #set color for power states
		#net_power_display.add_theme_color_override("font_color", GameData.positive_color)
		pass
	else: 
		#net_power_display.add_theme_color_override("font_color", GameData.negative_color)
		pass
	net_power_display.text = str(net_power)
