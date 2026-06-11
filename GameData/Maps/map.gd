extends Node2D

#signal pathing_updated(new_path: PackedVector2Array)

@export_group("Node Paths", "path_")
@export var path_tower_container : Node2D
@export var path_baddy_container : Node2D
@export var path_start_point : Marker2D
@export var path_end_point : Marker2D
@export var path_ground_layer : TileMapLayer
@export var path_exclusion_layer : TileMapLayer
@export var path_pathfinding_layer : TileMapLayer

##Pathfinding
const CELL_SIZE : int = 64
const CELL := Vector2(CELL_SIZE, CELL_SIZE)
@warning_ignore("integer_division")
const CELL_CENTRE := Vector2(CELL_SIZE/2, CELL_SIZE/2)
var astar_pathing : AStarGrid2D = AStarGrid2D.new()
var astar_preview : AStarGrid2D = AStarGrid2D.new()
var astar_array : Array[AStarGrid2D] = [astar_pathing, astar_preview]
var all_waypoints : Array[Vector2] = []
#const WALL_TILE_COORD := Vector2i(0,0)
#const FLOOR_TILE_COORD := Vector2i(0,0)

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
	_get_all_waypoints()

func _get_all_waypoints() -> void:
	all_waypoints = []
	for child in get_children():
		if child is Marker2D:
			all_waypoints.append(child.global_position)

func update_preview() -> PackedVector2Array:
	var path : PackedVector2Array
	
	for i in all_waypoints.size() - 1:
		var segment : PackedVector2Array = astar_preview.get_point_path(_get_current_tile(all_waypoints[i]), _get_current_tile(all_waypoints[i+1]))
		if segment.is_empty():
			return segment
		if i > 0:
			segment.remove_at(0) #removes duplicate point
		path.append_array(segment)
	return path

func update_pathing(current_position: Vector2, waypoint_index: int) -> PackedVector2Array:
	if waypoint_index >= all_waypoints.size():
		return PackedVector2Array([Vector2(-1000,-1000)])
	return astar_pathing.get_point_path(_get_current_tile(current_position), _get_current_tile(all_waypoints[waypoint_index]))

func _get_current_tile(current_position: Vector2) -> Vector2i:
	return path_ground_layer.local_to_map(path_ground_layer.to_local(current_position))
