class_name AuraMod extends PrototypeMod

enum AuraBuffableStats{
	RANGE,
	POWER,
	ATTACK_SPEED
}

@export var base_attack_speed_levels : Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0] #cd between attacks in seconds
@export var buff_data : Buff 
var current_attack_speed : float


#var is_aura : bool = false
#@export var offensive_aura : bool = false

func buff_check(buff_stat) -> bool:
	var stat_name : String = ""
	if buff_stat is int:
		for stat in GlobalEnums.BuffableStats.keys():
			if buff_stat & GlobalEnums.BuffableStats[stat]:
				stat_name = stat.to_upper()
	else:
		stat_name = buff_stat.to_upper()
	return AuraBuffableStats.keys().has(stat_name)

func set_current_stats() -> void:
	current_power = base_power_levels[level]
	current_range = base_range_levels[level]
	current_attack_speed = base_attack_speed_levels[level]
