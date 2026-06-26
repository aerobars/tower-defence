##Contains functions for abilities that trigger on a timer at regular intervals
class_name AbilityPeriodic extends AbilityTriggeredPrototype

enum ProcessingMethod {
	TIME, ##0
	POSITION ##1
}

@export var process_type : ProcessingMethod
var last_position : Vector2

func process(delta: float, position: Vector2) -> void:
	match process_type:
		ProcessingMethod.TIME:
			cooldown_timer += delta
		ProcessingMethod.POSITION:
			cooldown_timer += position.distance_to(last_position)
			last_position = position
	if cooldown_timer >= cooldown[owner_level]:
		triggered_effect()
		cooldown_timer = 0.0
