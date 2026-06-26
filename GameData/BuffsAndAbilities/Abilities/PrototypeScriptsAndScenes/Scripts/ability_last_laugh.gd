class_name AbilityLastLaugh extends AbilityTriggeredPrototype

func ability_setup(_ability_owner) -> void:
	super(_ability_owner)
	ability_owner.baddy_death.connect(triggered_effect)
