##Contains functions for abilities that trigger on a timer at regular intervals
class_name AbilityPeriodic extends AbilityTriggeredPrototype

func ability_setup() -> void:
	pass

func _process(delta: float) -> void:
	cooldown_timer += delta
	if cooldown_timer >= data.cooldown:
		triggered_effect()
		cooldown_timer = 0.0

func triggered_effect() -> void:
	pass
	
	
