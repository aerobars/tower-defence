extends Camera2D

const EDGE_SIZE := 20
const CAMERA_SPEED := 600
const ZOOM_IN_LIMIT := 3.0
const ZOOM_OUT_LIMIT := 0.5

@export var zoom_disabled := false
var camera_dragging := false

func _ready() -> void:
	update_limits(get_viewport_rect())

func update_limits(size: Rect2) -> void:
	@warning_ignore("narrowing_conversion")
	limit_left = size.position.x
	@warning_ignore("narrowing_conversion")
	limit_top = size.position.y
	@warning_ignore("narrowing_conversion")
	limit_right = size.end.x
	@warning_ignore("narrowing_conversion")
	limit_bottom = size.end.y

func _process(delta: float) -> void:
	var mouse_movement = _mouse_movement()
	
	var key_movement := Input.get_vector("ui_left","ui_right", "ui_up", "ui_down")
	
	position += (mouse_movement + key_movement).normalized() * CAMERA_SPEED * delta

func _mouse_movement() -> Vector2:
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport_rect().size
	var mouse_movement = Vector2.ZERO
	
	if mouse_pos.x < EDGE_SIZE:
		mouse_movement.x -= 1
	elif mouse_pos.x > viewport_size.x - EDGE_SIZE:
		mouse_movement.x += 1
	
	if mouse_pos.y < EDGE_SIZE:
		mouse_movement.y -= 1
	elif mouse_pos.y > viewport_size.y - EDGE_SIZE:
		mouse_movement.y += 1
	
	return mouse_movement

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		camera_dragging = event.is_pressed()
	elif event is InputEventMouseMotion and camera_dragging:
		position -= event.relative / zoom.x
	
	if zoom_disabled:
		return
	if event.is_action_pressed("zoom_in"):
		zoom *= 1.1
	elif event.is_action_pressed("zoom_out"):
		zoom *= 0.9
	zoom.x = clamp(zoom.x, ZOOM_OUT_LIMIT, ZOOM_IN_LIMIT)
	zoom.y = zoom.x
