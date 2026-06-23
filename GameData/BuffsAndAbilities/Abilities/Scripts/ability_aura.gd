class_name AbilityAura extends AbilityPrototype


func ability_setup() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	var buff_targets = data.buff_data.buff_targets
	if buff_targets == GlobalEnums.Targets.NONE:
		return
	if body.is_in_group("baddies") and buff_targets == GlobalEnums.Targets.BADDIES:
		ability_owner.add_buff(data.buff_data, body)
	elif body.is_in_group("towers") and buff_targets == GlobalEnums.Targets.TOWERS:
		ability_owner.add_buff(data.buff_data, body)



func _on_body_exited(body: Node2D) -> void:
	for buff in data.initial_buffs:
		var buff_targets = buff.buff_targets
		if buff_targets == GlobalEnums.Targets.NONE:
			continue
		if body.is_in_group("baddies") and buff_targets == GlobalEnums.Targets.BADDIES:
			ability_owner.remove_buff(data.buff_data, body)
		elif body.is_in_group("towers") and buff_targets == GlobalEnums.Targets.TOWERS:
			ability_owner.remove_buff(data.buff_data, body)
