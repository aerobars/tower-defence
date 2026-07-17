class_name BuffInstance extends Resource

var buff : Buff
var buff_owner : Node2D 
var buff_source : Array[Node2D]
var stacks : int = 0
var dot_timer : float
var time_remaining : float
var last_position : Vector2
var level : int = 0

## Knockback runtime data (only used when buff is BuffKnockback)
var kb_target : Vector2
var kb_start : Vector2
var kb_initialized : bool = false
var cell_size : int 
var step : float 

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
	if buff is BuffKnockback:
		cell_size = buff_owner.path_map.CELL_SIZE
		step = cell_size / 4.0  # Quarter-tile precision for smooth collision

func update(delta: float, position: Vector2 = Vector2(0,0)) -> void:
	if buff is BuffDot:
		match buff.process_type:
			GlobalEnums.ProcessingMethods.TIME:
				dot_timer += delta
			GlobalEnums.ProcessingMethods.POSITION:
				dot_timer += position.distance_to(last_position)
				last_position = position
		if dot_timer >= buff.dot_interval[level]:
			_effect_trigger()
			dot_timer = 0.0
	if buff is BuffKnockback:
		_apply_knockback(delta)
	if buff.buff_persistent_effect: #prevents aura buffs from expiring while active 
		return
	time_remaining -= delta
	if time_remaining <= 0.0:
		buff_owner.data.remove_buff(buff, buff_source[0], stacks)
#buff_source shouldn't matter in above call, since it's only checked for persistent effects

## On Hit

func on_hit_check(_damage_tags : int, _pending_buffs) -> void:
	if randf() <= float(buff.success_chance_per_stack[level] * stacks):
		_effect_trigger()
		if buff.buff_persistent_effect == false:
			buff_owner.data.remove_buff(buff)

## Effect Triggers

func _effect_trigger() -> void:
	
	var onhit_targets = _determine_targets()
	
	if buff.damage_tag > 0:
		for target in onhit_targets:
			target.calculate_damage([buff.buff_effect_amount[level] * stacks, buff.damage_tag, false])
	
	if buff is BuffOnHit and buff.buff_to_apply != null:
		for target in onhit_targets:
			target.data.add_buff(buff.buff_to_apply, buff_owner, level)

func _determine_targets() -> Array[Node2D]:
	var targets : Array[Node2D] = []
	if buff.buff_targets == GlobalEnums.Targets.BADDIES or buff.buff_targets == GlobalEnums.Targets.TOWERS:
		targets = StaticFunctions.setup_aoe(
			buff_owner, 
			buff_owner.global_position,
			GlobalEnums.Targets.keys()[buff.buff_targets].to_lower(), 
			buff.buff_effect_aoe[level])
	elif buff.buff_targets == GlobalEnums.Targets.SELF:
		targets = [buff_owner]
	else:
		print("no buff targets")
	return targets

## Knockback

func _apply_knockback(_delta: float) -> void:
	if not kb_initialized:
		kb_initialized = true
		var kb : BuffKnockback = buff
#		var kb := buff as BuffKnockback
		kb_start = buff_owner.global_position
		
		var dir: Vector2
		if kb.knockback_type == BuffKnockback.KnockbackType.PUSH:
			dir = (buff_owner.global_position - buff_source[0].global_position).normalized()
		else: # PULL
			dir = (buff_source[0].global_position - buff_owner.global_position).normalized()
		
		if dir == Vector2.ZERO:
			dir = Vector2.RIGHT  # Fallback direction if they're on top of each other
		
		kb_target = _calculate_clamped_target(kb_start, dir, kb.knockback_strength[level])
	
	var total_duration: float = buff.buff_duration[level]
	if total_duration <= 0.0:
		return
	var elapsed: float = total_duration - time_remaining
	var progress: float = clampf(elapsed / total_duration, 0.0, 1.0)
	buff_owner.global_position = kb_start.lerp(kb_target, progress)

func _calculate_clamped_target(origin: Vector2, direction: Vector2, max_dist: float) -> Vector2:
	if not buff_owner is Baddy:
		return origin + direction * max_dist
	
	if not is_instance_valid(buff_owner.path_map):
		return origin + direction * max_dist
	
	var astar: AStarGrid2D = buff_owner.path_map.astar_pathing
	var current_pos := origin
	
	var steps: int = int(max_dist / step)
	for i in range(1, steps + 1):
		var next_pos : Vector2 = origin + direction * (step * i)
		var tile: Vector2i = buff_owner.path_map.get_current_tile(next_pos)
		if astar.is_point_solid(tile):
			return current_pos  # Stop at last valid position
		current_pos = next_pos
	
	return origin + direction * max_dist  # No obstacle hit, use full distance
