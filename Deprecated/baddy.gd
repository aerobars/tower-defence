extends CharacterBody2D


func _physics_process(_delta):
	var speed = 300
	var direction = Vector2(1,0)
	velocity = direction * speed
	move_and_slide()
