class_name AbilityHPThreshold extends AbilityTriggeredPrototype

##Order threshold levels from lowest > highest
@export var threshold_levels : Dictionary[float, bool] 

func ability_setup(_ability_owner: CollisionObject2D) -> void:
	super(_ability_owner)
	ability_owner.data.health_changed.connect(threshold_check)

func threshold_check(current_health: float, max_health: float) -> void:
	var hp_ratio = current_health / max_health
	var thresholds = threshold_levels.keys()
	thresholds.sort()
	for threshold in thresholds:
		if hp_ratio <= threshold and threshold_levels[threshold] == false:
			threshold_levels[threshold] = true
			triggered_effect()
		elif hp_ratio >= threshold:
			threshold_levels[threshold] = false
