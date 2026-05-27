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
var astar_preview : AStarGrid2D = AStarGrid2D.new()
var astar_array : Array[AStarGrid2D] = [astar_pathing, astar_preview]
#const WALL_TILE_COORD := Vector2i(0,0)
#const FLOOR_TILE_COORD := Vector2i(0,0)
const CELL_SIZE : int = 64
const CELL := Vector2(CELL_SIZE, CELL_SIZE)
@warning_ignore("integer_division")
const CELL_CENTRE := Vector2(CELL_SIZE/2, CELL_SIZE/2)

func _ready() -> void:
	for astar in astar_array:
		astar.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
		#astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
		#astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
		astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
		astar.region = path_ground_layer.get_used_rect()
		astar.offset = CELL_CENTRE
		astar.update()
		for tile in path_exclusion_layer.get_used_cells():
			#pathing_layer.set_cell(tile, 0, Vector2i(0,0), 0)
			astar.set_point_solid(tile, true)

func update_pathing(astar_grid: String, initial_position: Vector2 = path_start_point.global_position) -> PackedVector2Array:
	var astar = get("astar_" + astar_grid)
	var local_pos := path_ground_layer.to_local(initial_position)
	var current_tile : Vector2i = path_ground_layer.local_to_map(local_pos)
	return astar.get_point_path(current_tile, path_ground_layer.local_to_map(path_end_point.global_position))
