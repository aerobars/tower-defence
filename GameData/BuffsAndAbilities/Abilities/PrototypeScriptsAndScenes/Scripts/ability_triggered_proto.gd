##Abstract Ability class for abilities that trigger under certain conditions, such as on hit or a periodic timer.
@abstract class_name AbilityTriggeredPrototype extends AbilityPrototype

func triggered_effect(_baddy: UnitScenePrototype = ability_owner) -> void:
	var onhit_targets := []
	
	#Determine ability targets
	if ability_targets == GlobalEnums.Targets.BADDIES or ability_targets == GlobalEnums.Targets.TOWERS:
		onhit_targets = StaticFunctions.setup_aoe(
			ability_owner, 
			ability_owner.global_position,
			GlobalEnums.Targets.keys()[ability_targets].to_lower(), 
			ability_aoe[owner_level])
	elif ability_targets == GlobalEnums.Targets.SELF:
		onhit_targets = [ability_owner]
	else:
		print("no ability targets")
		return
	
	if ability_damage_tag > 0:
		for target in onhit_targets:
			ability_owner.calculate_damage([ability_effect_amount[owner_level], ability_damage_tag, false])
	
	if buff_data != null:
		for target in onhit_targets:
			target.data.add_buff(buff_data, ability_owner, owner_level)
