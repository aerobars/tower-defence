extends Node2D

signal pathing_updated(new_path: PackedVector2Array)

@export_group("Node Paths", "path_")
@export var path_tower_container : Node2D
@export var path_baddy_container : Node2D
@export var path_start_point : Marker2D
@export var path_end_point : Marker2D
@export var path_ground_layer : TileMapLayer
@export var path_exclusion_layer : TileMapLayer
@export var path_pathfinding_layer : TileMapLayer

##Pathfinding
var astar_pathing : AStarGrid2D = AStarGrid2D.new()
#var astar_preview : AStarGrid2D
#const WALL_TILE_COORD := Vector2i(0,0)
#const FLOOR_TILE_COORD := Vector2i(0,0)
const CELL_SIZE : int = 64
const CELL := Vector2(CELL_SIZE, CELL_SIZE)
@warning_ignore("integer_division")
const CELL_CENTRE := Vector2(CELL_SIZE/2, CELL_SIZE/2)

func _ready() -> void:
	astar_pathing.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	#astar_pathing.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	#astar_pathing.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_pathing.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	astar_pathing.region = path_ground_layer.get_used_rect()
	astar_pathing.offset = CELL_CENTRE
	astar_pathing.update()
	for tile in path_exclusion_layer.get_used_cells():
		#pathing_layer.set_cell(tile, 0, Vector2i(0,0), 0)
		astar_pathing.set_point_solid(tile, true)
	#astar_preview = astar_pathing.duplicate(true)

func update_pathing(initial_position: Vector2) -> PackedVector2Array:
	var local_pos := path_ground_layer.to_local(initial_position)
	var current_tile : Vector2i = path_ground_layer.local_to_map(local_pos)
	return astar_pathing.get_point_path(current_tile, path_ground_layer.local_to_map(path_end_point.global_position))
