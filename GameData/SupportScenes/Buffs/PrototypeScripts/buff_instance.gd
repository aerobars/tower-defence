class_name BuffInstance extends Resource

const BURST_SPEED = preload("res://GameData/SupportScenes/Buffs/Baddy Buffs/burst_speed.tres")
var poison_stat = preload("res://GameData/SupportScenes/Buffs/Tower Buffs/test_poison_sb.tres")

var buff : Buff
var buff_owner : Node2D 
var stacks : int = 0
var dot_timer : float
var time_remaining : float
var last_progress: float = 0.0
var aura_effect : bool = false
var affected_stats : Array[GlobalEnums.BuffableStats]

##Setup and Updates
func _init(_buff: Buff, _buff_owner, _buff_duration : float = _buff.buff_duration) -> void:
	buff = _buff
	buff_owner = _buff_owner
	time_remaining = _buff_duration
	if time_remaining == -1.0: #-1 = persistent/aura effect
		aura_effect = true

func update(delta: float, progress: float = 0.0) -> void:
	if buff is DotBuff:
		call(buff.name.to_snake_case(), delta, progress)
		if dot_timer >= buff.dot_interval:
			buff_owner.calculate_damage([buff.damage_amount * stacks, buff.damage_tag, false])
			dot_timer = 0.0
	if aura_effect: #prevents aura buffs from expiring while 
		return
	time_remaining -= delta
	if time_remaining <= 0:
		buff_owner.data.remove_buff(buff)

func setup_aoe(_aoe_radius : float = 100.0) -> Array[Node2D]:
	var baddies : Array[Node2D] = []
	var aoe = Area2D.new()
	var aoe_radius = CollisionShape2D.new()
	aoe_radius.shape = CircleShape2D.new()
	aoe_radius.get_shape().radius = _aoe_radius
	aoe.add_child(aoe_radius)
	buff_owner.add_child(aoe)
	aoe.global_position = buff_owner.global_position
	await buff_owner.get_tree().process_frame #commented out to see if await physics frame is enough
	await buff_owner.get_tree().physics_frame
	for body in aoe.get_overlapping_bodies():
		if body.is_in_group("baddies"):
			baddies.append(body.get_parent())
	aoe.queue_free()
	return baddies

##Function names = buff names, if updating buff names, update func names too!!

##DoT
func bleed(_delta : float, progress : float) -> void:
	dot_timer += abs(progress - last_progress)
	last_progress = progress

func burn(delta : float, _progress : float) -> void:
	dot_timer += delta

##On Hit
func on_hit_check(damage_tags : int, pending_buffs) -> void:
	if randf() <= float(buff.success_chance_per_stack * stacks):
		call(buff.name.to_snake_case(), damage_tags, pending_buffs)

func burst_speed(_damage_tags, _pending_buffs) -> void:
	buff_owner.data.add_buff(BURST_SPEED)

func heal(_damage_tags, _pending_buffs) -> void:
	var baddies = await setup_aoe(buff.damage_aoe)
	for baddy in baddies:
		baddy.data.health += buff.damage_amount

func poison(damage_tags : int, pending_buffs) -> void:
	if not damage_tags & GlobalEnums.DamageTag.POISON:
		return
	buff_owner.calculate_damage([buff.effect_amount * stacks, buff.damage_tag, false])

	return #below code for stat modification if I choose to go that route
	for enum_stat in GlobalEnums.BuffableStats.keys():
		if OnHitBuff.AffectedStat.has(enum_stat) and buff.affected_stats.has(OnHitBuff.AffectedStat[enum_stat]):
			poison_stat.stat |= GlobalEnums.BuffableStats[enum_stat]
			pending_buffs.append(poison_stat)

func shock(_damage_tags, _pending_buffs) -> void:
	var baddies = await setup_aoe(buff.effect_aoe)
	for baddy in baddies:
		baddy.calculate_damage([buff.effect_amount, buff.damage_tag, false])
		stun()

func stun() -> void:
	var stat_ref
	if buff_owner.is_in_group("baddies"):
		stat_ref = GlobalEnums.BuffableStats.MOVE_SPEED
	elif buff_owner.is_in_group("turret"):
		stat_ref = GlobalEnums.BuffableStats.ATTACK_SPEED
	buff_owner.data.add_buff(AbsoluteBuff.new(
		stat_ref, 
		StatBuff.BuffType.MULTIPLY, 
		0.0, 
		buff.effect_duration)) 

##On Death
func on_death_trigger() -> void:
	await call(buff.name.to_snake_case())

func damage_boost() -> void:
	var baddies = await setup_aoe(buff_owner.data.aura_aoe)
	for baddy in baddies:
		baddy.data.add_buff(buff, -1.0)
