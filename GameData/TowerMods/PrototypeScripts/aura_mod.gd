class_name AuraMod extends TowerMod

enum AuraBuffableStats{
	RANGE,
	POWER,
	ATTACK_SPEED
}

@export var base_range_levels : Array[float]
var current_range : float

#enum DamageType {NONE, FIRE, COLD, POISON, PHYSICAL}
#@export var damage_type : DamageType = DamageType.NONE
@export var buff_data : Buff 
#@export var range_mod : Array[float]
@export var base_attack_speed_levels : Array[float]
var current_attack_speed : float

var is_aura : bool = false
@export var offensive_aura : bool = false

func buff_check(buff_stat) -> bool:
	return AllBuffableStats.AllBuffableStats.keys()[buff_stat] in AuraBuffableStats.keys()

func recalculate_stats(stat_addends, stat_multipliers) -> void:
	current_power = base_power_levels[level]
	current_range = base_range_levels[level]
	current_attack_speed = base_attack_speed_levels[level]
	
	#addends first so it benefits from multipliers
	for stat_name in stat_addends:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])

	for stat_name in stat_multipliers:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])
