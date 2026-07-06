class_name ModPower extends PrototypeMod

const BUFFABLE_STATS = [
	GlobalEnums.BuffableStats.POWER
]

@export var power_surplus_buffable_stats : Array[GlobalEnums.BuffableStats] = [GlobalEnums.BuffableStats.DAMAGE]

func get_buffable_stats() -> Array[GlobalEnums.BuffableStats]:

	return BUFFABLE_STATS

func set_current_stats() -> void:
	current_power = base_power_levels[level]

func update_surplus_buffable_stats() -> void:
	#add additional stats to buffables array
	pass
