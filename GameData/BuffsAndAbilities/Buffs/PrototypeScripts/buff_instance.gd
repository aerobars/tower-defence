class_name BuffInstance extends Resource

var buff : Buff
var buff_owner : Node2D 
var buff_source : Array[Node2D]
var stacks : int = 0
var dot_timer : float
var time_remaining : float
var last_position : Vector2
var level : int = 0
var process_type : GlobalEnums.ProcessingMethods

## Setup and Updates

func _init(_buff: Buff, _buff_owner: Node2D, _buff_source: Node2D, _buff_level: int = 0) -> void:
	buff = _buff
	buff_owner = _buff_owner
	level = _buff_level
	time_remaining = buff.buff_duration[level]
	last_position = Vector2(0,0)
	buff_owner.process_update.connect(update)
	buff_source.append(_buff_source)
		#get unit emitting aura and add to aura_source
	if buff is BuffDot:
		process_type = buff.buff_process_type

func update(delta: float, position: Vector2 = Vector2(0,0)) -> void:
	if buff is BuffDot:
		match process_type:
			GlobalEnums.ProcessingMethods.TIME:
				dot_timer += delta
			GlobalEnums.ProcessingMethods.POSITION:
				dot_timer += position.distance_to(last_position)
				last_position = position
		if dot_timer >= buff.dot_interval[level]:
			effect_trigger()
		#	buff_owner.calculate_damage([buff.damage_amount[level] * stacks, buff.damage_tag, false])
			dot_timer = 0.0
	if buff.buff_persistent_effect: #prevents aura buffs from expiring while active 
		return
	time_remaining -= delta
	if time_remaining <= 0.0:
		buff_owner.data.remove_buff(buff, buff_source[0], stacks)
#buff_source shouldn't matter in above call, since it's only checked for persistent effects

## On Hit

func on_hit_check(_damage_tags : int, _pending_buffs) -> void:
	if randf() <= float(buff.success_chance_per_stack[level] * stacks):
		print('on hit success')
		effect_trigger()
		if buff.buff_persistent_effect == false:
			buff_owner.data.remove_buff(buff)
	print("on hit check completed")

## Periodic Triggers

func effect_trigger() -> void:
	var onhit_targets := []
	if buff.buff_targets == GlobalEnums.Targets.BADDIES or buff.buff_targets == GlobalEnums.Targets.TOWERS:
		onhit_targets = StaticFunctions.setup_aoe(
			buff_owner, 
			buff_owner.global_position,
			GlobalEnums.Targets.keys()[buff.buff_targets].to_lower(), 
			buff.buff_effect_aoe[level])
	elif buff.buff_targets == GlobalEnums.Targets.SELF:
		onhit_targets = [buff_owner]
	else:
		print("no buff targets")
		return
#	print("targets for ", buff_owner.data.info_name, ": ", onhit_targets)
	if buff.damage_tag > 0:
		for target in onhit_targets:
			target.calculate_damage([buff.buff_effect_amount[level] * stacks, buff.damage_tag, false])
	else:
		print("no dmg tag")
	if buff is BuffOnHit and buff.buff_to_apply != null:
		for target in onhit_targets:
			target.data.add_buff(buff.buff_to_apply, buff_owner, level)
		
	else:
		print("no buff to apply")
	#call(buff.name.to_snake_case(), damage_tags, pending_buffs)
