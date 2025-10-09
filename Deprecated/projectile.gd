extends Area2D

var distance_travelled = 0

func _process(delta):
	var speed = 1200
	var max_range = 2000
	
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	
	distance_travelled += speed * delta
	if distance_travelled > max_range:
		queue_free()

func _on_body_entered(_body):
	queue_free()
	#if body.has_method("take_damage"):
	#	body.take_damage
