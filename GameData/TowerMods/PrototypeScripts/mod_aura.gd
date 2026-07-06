class_name ModAura extends PrototypeMod

const BUFFABLE_STATS = [
	GlobalEnums.BuffableStats.RANGE,
#	GlobalEnums.BuffableStats.POWER,
	GlobalEnums.BuffableStats.ATTACK_SPEED,
]

@export_group("Aura Stats")
@export var base_attack_speed_levels : Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0] #cd between attacks in seconds
@export var buff_data : Buff 
var current_attack_speed : float

func get_buffable_stats() -> Array[GlobalEnums.BuffableStats]:
	return BUFFABLE_STATS

func set_current_stats() -> void:
	current_power = base_power_levels[level]
	current_range = base_range_levels[level]
	current_attack_speed = base_attack_speed_levels[level]
