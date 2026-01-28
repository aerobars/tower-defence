class_name PowerMod extends PrototypeMod

enum PowerBuffableStats {
	POWER
}

@export var power_surplus_buffable_stats : Array[AllBuffableStats.BuffableStats] = [AllBuffableStats.BuffableStats.DAMAGE]

func buff_check(buff_stat) -> bool:
	if buff_stat is int:
		buff_stat = AllBuffableStats.BuffableStats.keys()[buff_stat]
	return PowerBuffableStats.keys().has(buff_stat.to_upper())

func set_current_stats() -> void:
	current_power = base_power_levels[level]

func update_surplus_buffable_stats() -> void:
	#add additional stats to buffables array
	pass
