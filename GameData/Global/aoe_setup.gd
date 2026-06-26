class_name AOESetup extends Node

static func setup_aoe(
		aoe_owner : Node2D, 
		target_position : Vector2, 
		target_group : String, 
		radius : float
		) -> Array[Node2D]:
			
	var targets : Array[Node2D] = []
	
	var aoe_radius = CircleShape2D.new()
	aoe_radius.radius = radius
	
	var aoe = PhysicsShapeQueryParameters2D.new()
	aoe.shape = aoe_radius
	aoe.transform = Transform2D(0.0, target_position)
	aoe.collide_with_bodies = true
	
	for body in aoe_owner.get_world_2d().direct_space_state.intersect_shape(aoe):
		#print(body)
		if body.collider.is_in_group(target_group):
			targets.append(body.collider)

	return targets
