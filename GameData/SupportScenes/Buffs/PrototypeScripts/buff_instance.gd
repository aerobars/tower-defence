class_name BuffInstance extends Resource

var buff : Buff
var buff_owner : Node2D
var stacks : int = 0
var dot_timer : float
var time_remaining : float
var last_progress: float = 0.0
var aura_effect : bool = false

func _init(_buff: Buff, _buff_owner, _buff_duration : float = _buff.buff_duration) -> void:
	buff = _buff
	buff_owner = _buff_owner
	time_remaining = _buff_duration
	if time_remaining == -1.0: #-1 = persistent/aura effect
		aura_effect = true

func update(delta: float, progress: float = 0.0) -> void:
	if buff is DotBuff:
		match AllDamageTags.DamageTag.keys()[buff.damage_tag]:
			"BLEED":
				dot_timer += abs(progress - last_progress)
				last_progress = progress
			"BURN":
				dot_timer += delta
		if dot_timer >= buff.dot_interval:
			buff_owner.calculate_damage([buff.damage_amount * stacks, buff.damage_tag, false])
			dot_timer = 0.0
	if aura_effect: #prevents aura buffs from expiring while 
		return
	time_remaining -= delta
	if time_remaining <= 0:
		buff_owner.data.remove_buff(buff)

func on_hit_check() -> void:
	if randf() <= float(buff.success_chance_per_stack * stacks):
		call(buff.name.to_snake_case())

func heal() -> void:
	var baddies = await setup_aoe()
	for baddy in baddies:
		baddy.data.health += buff.damage_amount

func shock() -> void:
	var baddies = await setup_aoe()
	for baddy in baddies:
		baddy.calculate_damage([buff.damage_amount, buff.damage_tag, false])
		stun()

func setup_aoe() -> Array[Node2D]:
	var baddies : Array[Node2D]
	var aoe = Area2D.new()
	var aoe_range = CollisionShape2D.new()
	aoe_range.shape = CircleShape2D.new()
	aoe_range.get_shape().radius = buff.damage_aoe
	aoe.add_child(aoe_range)
	buff_owner.add_child(aoe)
	aoe.global_position = buff_owner.position
	await buff_owner.get_tree().process_frame
	await buff_owner.get_tree().physics_frame
	for body in aoe.get_overlapping_bodies():
		if body.is_in_group("baddies"):
			baddies.append(body.get_parent())
	aoe.queue_free()
	return baddies

func stun() -> void:
	var stat_ref
	if buff_owner is Baddy:
		stat_ref = AllBuffableStats.BuffableStats.MOVE_SPEED
	elif buff_owner is TowerBase:
		stat_ref = AllBuffableStats.BuffableStats.ATTACK_SPEED
	buff_owner.data.add_buff(AbsoluteBuff.new(stat_ref, StatBuff.BuffType.MULTIPLY, 0.0, buff.effect_duration)) 
