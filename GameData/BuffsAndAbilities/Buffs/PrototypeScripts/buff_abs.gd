class_name BuffAbsolute extends BuffStat

var stat : GlobalEnums.BuffableStats : get = get_stat

func get_stat() -> GlobalEnums.BuffableStats:
	if buff_targets == GlobalEnums.Targets.BADDIES:
		return GlobalEnums.BuffableStats.MOVE_SPEED
	elif buff_targets == GlobalEnums.Targets.TOWERS:
		return GlobalEnums.BuffableStats.ATTACK_SPEED
	else:
		print("no target declared for Absolute Buff:", info_name)
		return 0
