class_name PowerMod extends PrototypeMod

enum PowerBuffableStats {
	POWER
}

@export var power_surplus_buffable_stats : Array[GlobalEnums.BuffableStats] = [GlobalEnums.BuffableStats.DAMAGE]

func buff_check(buff_stat) -> bool:
	var stat_name : String = ""
	if buff_stat is int:
		for stat in GlobalEnums.BuffableStats.keys():
			if buff_stat & GlobalEnums.BuffableStats[stat]:
				stat_name = stat.to_upper()
	else:
		stat_name = buff_stat.to_upper()
	return PowerBuffableStats.keys().has(stat_name)

func set_current_stats() -> void:
	current_power = base_power_levels[level]

func update_surplus_buffable_stats() -> void:
	#add additional stats to buffables array
	pass
