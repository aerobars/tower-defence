##Contains functions for abilities that trigger on a timer at regular intervals
class_name AbilityPeriodic extends AbilityTriggeredPrototype

func ability_setup(_ability_owner) -> void:
	super(ability_owner)

func process(delta: float) -> void:
	cooldown_timer += delta
	if cooldown_timer >= cooldown:
		triggered_effect()

func triggered_effect() -> void:
	cooldown_timer = 0.0
	
	
