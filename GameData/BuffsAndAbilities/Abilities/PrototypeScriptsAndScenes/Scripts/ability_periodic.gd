##Contains functions for abilities that trigger on a timer at regular intervals
class_name AbilityPeriodic extends AbilityTriggeredPrototype

@export var ability_process_type : GlobalEnums.ProcessingMethods
var last_position : Vector2

func process(delta: float, position: Vector2) -> void:
	match ability_process_type:
		GlobalEnums.ProcessingMethods.TIME:
			cooldown_timer += delta
		GlobalEnums.ProcessingMethods.POSITION:
			cooldown_timer += position.distance_to(last_position)
			last_position = position
	if cooldown_timer >= ability_cooldown[owner_level]:
		triggered_effect()
		cooldown_timer = 0.0
