extends Camera2D

@export var pan_speed := 1000
@export var edge_size := 30.0

var is_panning := false

#camera zooming variables
#const ZOOM_MAX := Vector2(0.5,0.5)
#const ZOOM_MIN := Vector2(2,2)
#const ZOOM_SPEED := 1
#var zoom_factor := Vector2(0.05,0.05)
#var is_zooming := false

func _physics_process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size
	var direction := Vector2.ZERO
	
	if mouse_pos.x <= edge_size:
		direction.x = -1
		is_panning = true
	elif mouse_pos.x >= screen_size.x - edge_size:
		direction.x = 1
		is_panning = true
	
	if mouse_pos.y <= edge_size:
		direction.y = -1
		is_panning = true
	elif mouse_pos.y >= screen_size.y - edge_size:
		direction.y = 1
		is_panning = true
	
	#check if camera is panning with mouse
	if direction == Vector2.ZERO:
		is_panning = false
	
	if is_panning == false:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += direction.normalized() * pan_speed * delta
	
	#camera zooming code
	#if Input.is_action_just_pressed("zoom_in") and zoom > ZOOM_MAX:
		#zoom_factor = Vector2(0.05,0.05)
		#is_zooming = true
	#elif Input.is_action_just_pressed("zoom_out") and zoom < ZOOM_MIN:
		#zoom_factor = Vector2(-0.05,-0.05)
		#is_zooming = true
	
	#if is_zooming == true:
		#zoom = lerp(zoom, zoom + zoom_factor, ZOOM_SPEED)
		#await get_tree().create_timer(0.10).timeout
		#is_zooming = false
