class_name ModAura extends PrototypeMod

const BUFFABLE_STATS = [
	GlobalEnums.BuffableStats.RANGE,
#	GlobalEnums.BuffableStats.POWER,
	GlobalEnums.BuffableStats.ATTACK_SPEED,
]

@export_group("Aura Stats")
##How many times per second this tower activates
@export var base_activation_speed_levels : Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0] #cd between attacks in seconds
@export var buff_data : Buff 
var current_activation_speed : float

var activation_cooldown : float

func setup_stats(_level : int = 0) -> void:
	super(_level)
	stats_updated.connect(set_activation_cooldown)

func get_buffable_stats() -> Array[GlobalEnums.BuffableStats]:
	return BUFFABLE_STATS

func set_current_stats() -> void:
	current_power = base_power_levels[level]
	current_range = base_range_levels[level]
	current_activation_speed = base_activation_speed_levels[level]

func set_activation_cooldown() -> void:
	activation_cooldown = 1 / current_activation_speed
