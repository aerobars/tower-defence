class_name AOESetup extends Node

static func setup_aoe(
		aoe_owner : Node2D, 
		target_position : Vector2, 
		target_group : String, 
		radius : float
		) -> Array[Node2D]:
	var targets : Array[Node2D] = []
	var aoe = Area2D.new()
	var aoe_radius = CollisionShape2D.new()
	aoe_radius.shape = CircleShape2D.new()
	aoe_radius.get_shape().radius = radius
	aoe.add_child(aoe_radius)
	aoe_owner.add_child(aoe)
	aoe.global_position = target_position
	await aoe_owner.get_tree().process_frame #commented out to see if await physics frame is enough
	await aoe_owner.get_tree().physics_frame
	for body in aoe.get_overlapping_bodies():
		if body.is_in_group(target_group):
			if body.get_parent() == null:
				targets.append(body)
			else:
				targets.append(body.get_parent())
	aoe.queue_free()
	return targets
