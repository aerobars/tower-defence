class_name AuraMod extends PrototypeMod

enum AuraBuffableStats{
	RANGE,
	POWER,
	ATTACK_SPEED
}

@export var base_attack_speed_levels : Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0] #cd between attacks in seconds
@export var buff_data : Buff 
var current_attack_speed : float


var is_aura : bool = false
@export var offensive_aura : bool = false

func buff_check(buff_stat) -> bool:
	if buff_stat is int:
		buff_stat = AllBuffableStats.BuffableStats.keys()[buff_stat]
	return AuraBuffableStats.keys().has(buff_stat.to_upper())

func set_current_stats() -> void:
	current_power = base_power_levels[level]
	current_range = base_range_levels[level]
	current_attack_speed = base_attack_speed_levels[level]
