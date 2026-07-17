##Abstract Ability class for abilities that trigger under certain conditions, such as on hit or a periodic timer.
@abstract class_name AbilityTriggeredPrototype extends AbilityPrototype

func triggered_effect(triggering_pos: Vector2) -> void:
	if ability_targets == GlobalEnums.Targets.NONE:
		no_target_trigger()
		return
	
	var onhit_targets = _determine_targets(triggering_pos)
	
	if ability_damage_tag > 0:
		for target in onhit_targets:
			ability_owner.calculate_damage([ability_effect_amount[owner_level], ability_damage_tag, false])
	
	if buff_data != null:
		for target in onhit_targets:
			target.data.add_buff(buff_data, ability_owner, owner_level)

func no_target_trigger() -> void:
	pass

##Determine ability targets
func _determine_targets(triggering_pos: Vector2) -> Array[Node2D]:
	var targets : Array[Node2D] = []
	if ability_targets == GlobalEnums.Targets.BADDIES or ability_targets == GlobalEnums.Targets.TOWERS:
		targets = StaticFunctions.setup_aoe(
			ability_owner, 
			triggering_pos,
			GlobalEnums.Targets.keys()[ability_targets].to_lower(), 
			ability_aoe[owner_level])
	elif ability_targets == GlobalEnums.Targets.SELF:
		targets =  [ability_owner]
	return targets
