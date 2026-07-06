class_name TankBoss extends BaddyBossProto


##Thresholds must be ordered from lowest to highest
@export var health_thresholds : Array[float]
##Used for visual display of current health threshold
@export var threshold_display : Array[Buff]
var current_threshold : Buff


func _on_health_set(new_value: float) -> void:
	super(new_value)
	for threshold in health_thresholds:
		if health / current_max_health <= threshold:
			boss_effect()
			health_thresholds.erase(threshold)
			return
	current_threshold = threshold_display[base_defence_tag]
	add_buff(current_threshold, data_owner, level)

##change boss effect to ability
func boss_effect() -> void:
	base_defence_tag = max(base_defence_tag - 1, 0)
	base_move_speed += 50
	base_defence -= 2
	remove_buff(current_threshold, data_owner)
	current_threshold = threshold_display[base_defence_tag]
	add_buff(current_threshold, data_owner, level)
