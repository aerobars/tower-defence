class_name AbsoluteBuff extends StatBuff


func set_stat(buff_owner) -> void:
	if buff_owner.is_in_group("baddies"):
		stat = GlobalEnums.BuffableStats.MOVE_SPEED
	elif buff_owner.is_in_group("towers"):
		stat = GlobalEnums.BuffableStats.ATTACK_SPEED
