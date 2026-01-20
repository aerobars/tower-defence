class_name BuffInstance extends Resource

var buff : Buff
var buff_owner : Node2D
var stacks : int = 0
var dot_timer : float
var time_remaining : float

func _init(_buff: Buff, _buff_owner) -> void:
	buff = _buff
	buff_owner = _buff_owner
	time_remaining = buff.buff_duration

func update(delta: float) -> void:
	time_remaining -= delta
	if buff is DotBuff:
		dot_timer += delta
		if dot_timer >= buff.dot_interval:
			buff_owner.calculate_damage([buff.damage_amount * stacks, buff.damage_tag, false])
			dot_timer = 0.0
	if time_remaining <= 0:
		buff_owner.data.remove_buff(buff)

func on_hit_check() -> void:
	if randi() % 100 > buff.success_chance_per_stack * stacks:
		match buff.name.to_pascal_case():
			"shock":
				shock()

func stun() -> void:
	var current_stat : float
	if buff_owner is Baddy:
			current_stat = buff_owner.data.current_move_speed
			buff_owner.data.current_move_speed = 0.0
	elif buff_owner is TowerBase:
			pass#set attack_speed to 0
	await buff_owner.get_tree().create_timer(buff.effect_duration, false).timeout
	if buff_owner is Baddy:
			buff_owner.data.current_move_speed = current_stat
	elif buff_owner is TowerBase:
			pass#set attack_speed to 0

func shock() -> void:
	var aoe = setup_aoe()
	aoe.global_position = buff_owner.position
	await buff_owner.get_tree().physics_frame
	for body in aoe.get_overlapping_bodies():
		if body.is_in_group("baddies"):
			body.get_parent().on_hit(buff_owner.calculate_damage([buff.damage_amount * stacks, buff.damage_tag, false]))
	stun()
	buff_owner.data.remove_buff(buff)


func setup_aoe() -> Area2D:
	var aoe = Area2D.new()
	var aoe_range = CollisionShape2D.new()
	aoe_range.shape = CircleShape2D.new()
	aoe_range.get_shape().radius = buff.damage_aoe
	aoe.add_child(aoe_range)
	buff_owner.add_child(aoe)
	return aoe
