class_name AbilityLastLaugh extends AbilityTriggeredPrototype

func ability_setup(_ability_owner, _ability_source: UnitScenePrototype) -> void:
	super(_ability_owner, _ability_source)
	ability_owner.baddy_death.connect(triggered_effect)
