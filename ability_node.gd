
@abstract
class_name AbilityScene extends Node2D

@export var data : Ability

func _process(delta: float) -> void:
	data.cooldown_timer += delta
	if data.cooldown_timer >= data.cooldown:
		pass
