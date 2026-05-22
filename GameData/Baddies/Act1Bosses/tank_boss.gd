class_name TankBoss extends BaddyBossProto


##Thresholds must be ordered from lowest to highest
@export var health_thresholds : Array[float]
##Used for visual display of current health threshold
@export var threshold_display : Array[Buff]
var current_threshold : Buff


func _on_health_set(new_value: float) -> void:
	super(new_value)
	for threshold in health_thresholds:
		if health <= threshold:
			boss_effect()
			break

func boss_effect() -> void:
	base_defence_tag = max(base_defence_tag - 1, 0)
	base_move_speed += 50
	base_defence -= 2
	remove_buff(current_threshold)
	current_threshold = threshold_display[base_defence_tag]
	add_buff(current_threshold)
