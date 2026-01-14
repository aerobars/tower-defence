class_name BuffInstance extends Resource

var buff: Buff
var stacks : int = 0
var dot_timer : float
var time_remaining : float

func _init(_buff: Buff) -> void:
	buff = _buff
	time_remaining = buff.buff_duration

func update(delta: float) -> void:
	time_remaining -= delta
	if buff is DotBuff:
		dot_timer += delta

func on_hit_check() -> bool:
	var hit_check = randi() % 100 > buff.success_chance_per_stack * stacks
	return hit_check 
