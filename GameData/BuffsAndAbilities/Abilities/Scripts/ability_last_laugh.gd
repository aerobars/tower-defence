class_name AbilityLastLaugh extends AbilityTriggeredPrototype

func ability_setup() -> void:
	ability_owner.baddy_death.connect(triggered_effect)

func triggered_effect() -> void:
	pass
