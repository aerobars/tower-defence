extends Node2D

@onready var camera := $Camera2D

const GRID_SIZE = 64

#var grid_coord = (world_pos/GRID_SIZE).floor()
#var world_pos = grid_coord * GRID_SIZE

func snap_to_grid(pos: Vector2) -> Vector2:
	return pos.snapped(Vector2(GRID_SIZE, GRID_SIZE))

#var mouse_world_pos = camera.to_global(get_viewport().get_mouse_position())
