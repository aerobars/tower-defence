class_name PowerMod extends TowerMod

enum PowerBuffableStats {
	POWER
}

func buff_check(buff_stat) -> bool:
	return AllBuffableStats.AllBuffableStats.keys()[buff_stat] in PowerBuffableStats.keys()

func recalculate_stats(stat_addends, stat_multipliers) -> void:
	current_power = base_power_levels[level]
	
	#addends first so it benefits from multipliers
	for stat_name in stat_addends:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])

	for stat_name in stat_multipliers:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])
