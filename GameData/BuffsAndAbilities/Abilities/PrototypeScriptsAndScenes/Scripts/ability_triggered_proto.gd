##Abstract Ability class for abilities that trigger under certain conditions, such as on hit or a periodic timer.
@abstract class_name AbilityTriggeredPrototype extends Ability

func triggered_effect(trigger_source: Node2D = ability_owner) -> void:
	if ability_targets == GlobalEnums.Targets.NONE:
		no_target_trigger()
		return
	
	var onhit_targets = _determine_targets(trigger_source)
	
	if ability_damage_tag > 0:
		for target in onhit_targets:
			target.calculate_damage(AttackData.new(
				ability_effect_amount[owner_level],
				ability_damage_tag,
				owner_level,
				))
	
	if buff_data != null:
		for target in onhit_targets:
			target.data.add_buff(buff_data, ability_owner, owner_level)

func no_target_trigger() -> void:
	pass

##Determine ability targets
func _determine_targets(trigger_source: UnitScenePrototype) -> Array[Node2D]:
	var targets: Array[Node2D] = []
	if ability_targets == GlobalEnums.Targets.SELF:
		targets = [ability_owner]
	elif ability_targets == GlobalEnums.Targets.BADDIES or ability_targets == GlobalEnums.Targets.TOWERS:
		if ability_aoe[owner_level] > 0.0:
			targets = StaticFunctions.setup_aoe(
				ability_owner, 
				trigger_source.global_position,
				GlobalEnums.Targets.keys()[ability_targets].to_lower(), 
				ability_aoe[owner_level])
		else:
			targets = [trigger_source]
	return targets
