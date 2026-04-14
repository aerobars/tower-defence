class_name BuffInstance extends Resource

const BURST_SPEED = preload("res://GameData/SupportScenes/Buffs/BaddyBuffs/onhit_burst_speed.tres")
#var poison_stat = preload("res://GameData/SupportScenes/Buffs/TowerBuffs/test_poison_sb.tres")

var buff : Buff
var buff_owner : Node2D 
var stacks : int = 0
var dot_timer : float
var time_remaining : float
var last_progress: float = 0.0
var stat_buff : StatBuff
var level : int = 0
#var affected_stats : Array[GlobalEnums.BuffableStats]

##Setup and Updates
func _init(_buff: Buff, _buff_owner, _buff_level : int = 0) -> void:
	buff = _buff
	buff_owner = _buff_owner
	level = _buff_level
	time_remaining = buff.buff_duration[level]
	

func update(delta: float, progress: float = 0.0) -> void:
	if buff is DotBuff:
		call(buff.name.to_snake_case(), delta, progress)
		if dot_timer >= buff.dot_interval[level]:
			buff_owner.calculate_damage([buff.damage_amount[level] * stacks, buff.damage_tag, false])
			dot_timer = 0.0
	if buff.aura_effect: #prevents aura buffs from expiring while active 
		return
	time_remaining -= delta
	if time_remaining <= 0.0:
		buff_owner.data.remove_buff(buff)

##Function names = buff names, if updating buff names, update func names too!!

##DoT
func bleed(_delta : float, progress : float) -> void:
	dot_timer += abs(progress - last_progress)
	last_progress = progress

func burn(delta : float, _progress : float) -> void:
	dot_timer += delta

##On Hit
func on_hit_check(_damage_tags : int, _pending_buffs) -> void:
	if randf() <= float(buff.success_chance_per_stack[level] * stacks):
		var targets
		if buff_owner.data.aura_aoe > 1:
			targets = await AOESetup.setup_aoe(
				buff_owner, 
				buff_owner.global_position,
				GlobalEnums.Targets.keys()[buff.targets].to_lower(), 
				buff_owner.data.aura_aoe)
		else:
			targets = buff_owner
		if buff.damage_tag > 0:
			for target in targets:
				if buff.damage_tag != GlobalEnums.DamageTag.HEAL:
					buff_owner.calculate_damage([buff.effect_amount[level] * stacks, buff.damage_tag, false])
				else:
					target.data.health += buff.effect_amount[level]
		if buff.buff_to_apply != null:
			for target in targets:
				target.data.add_buff(buff.buff_to_apply)
	print('on hit triggered')
		#call(buff.name.to_snake_case(), damage_tags, pending_buffs)

func burst_speed(_damage_tags, _pending_buffs) -> void:
	buff_owner.data.add_buff(BURST_SPEED)

func heal(_damage_tags, _pending_buffs) -> void:
	var baddies = await AOESetup.setup_aoe(
		buff_owner, 
		buff_owner.global_position,
		GlobalEnums.Targets.keys()[buff.buff_targets].to_lower(), 
		buff_owner.data.aura_aoe)
	for baddy in baddies:
		baddy.data.health += buff.damage_amount[level]

func poison(damage_tags : int, pending_buffs) -> void:
	if not damage_tags & GlobalEnums.DamageTag.POISON:
		return
	buff_owner.calculate_damage([buff.effect_amount[level] * stacks, buff.damage_tag, false])

	#below code for stat modification if I choose to go that route
	#for enum_stat in GlobalEnums.BuffableStats.keys():
	#	if OnHitBuff.AffectedStat.has(enum_stat) and buff.affected_stats.has(OnHitBuff.AffectedStat[enum_stat]):
	#		poison_stat.stat |= GlobalEnums.BuffableStats[enum_stat]
	#		pending_buffs.append(poison_stat)

func shock(_damage_tags, _pending_buffs) -> void:
	var baddies = await AOESetup.setup_aoe(
		buff_owner, 
		buff_owner.global_position,
		GlobalEnums.Targets.keys()[buff.buff_targets].to_lower(), 
		buff_owner.data.aura_aoe)
	for baddy in baddies:
		baddy.calculate_damage([buff.effect_amount[level], buff.damage_tag, false])
		stun()

func stun() -> void:
	var stat_ref
	if buff_owner.is_in_group("baddies"):
		stat_ref = GlobalEnums.BuffableStats.MOVE_SPEED
	elif buff_owner.is_in_group("towers"):
		stat_ref = GlobalEnums.BuffableStats.ATTACK_SPEED
	buff_owner.data.add_buff(AbsoluteBuff.new(
		stat_ref, 
		StatBuff.BuffType.MULTIPLY, 
		[0.0], 
		buff.effect_duration[level])) 
