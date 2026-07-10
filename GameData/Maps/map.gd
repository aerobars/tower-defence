extends Node2D

signal pathing_updated()

## Node Paths

@export_group("Node Paths", "path_")
@export var path_start_point : Marker2D
@export var path_end_point : Marker2D
##Layer of terrain, does not interact with baddies or towers
@export var path_ground_layer : TileMapLayer
##Layer of terrain that prevents movement and building, as well as built towers and (maybe soon) baddies
@export var path_exclusion_layer : TileMapLayer
##Layer to showing cells covered by tower preview
@export var path_pathfinding_layer : TileMapLayer
@export var path_pathfinding_visual : Line2D

## Pathfinding

const CELL_SIZE : int = 64
const CELL := Vector2(CELL_SIZE, CELL_SIZE)
@warning_ignore("integer_division")
const CELL_CENTRE := Vector2(CELL_SIZE/2, CELL_SIZE/2)
##AStar Grid used to update baddy pathing
var astar_pathing : AStarGrid2D = AStarGrid2D.new()
##Astar Grid used to show general baddy path and visual possible updates while in build mode
var astar_preview : AStarGrid2D = AStarGrid2D.new()
##Used to set up both Astar Grids without repeating code
var astar_array : Array[AStarGrid2D] = [astar_pathing, astar_preview]
var all_waypoints : Array[Vector2] = []
#const WALL_TILE_COORD := Vector2i(0,0)
#const FLOOR_TILE_COORD := Vector2i(0,0)

## Build Mode

var previous_tiles

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
	
	pathing_visual_update()

func _get_all_waypoints() -> void:
	all_waypoints = []
	for child in get_children():
		if child is Marker2D:
			all_waypoints.append(child.global_position)

func pathing_visual_update() -> void:
	path_pathfinding_visual.clear_points()
	for cell in update_preview():
		path_pathfinding_visual.add_point(cell)

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

func _get_current_tile(current_position: Vector2) -> Vector2i:
	return path_ground_layer.local_to_map(path_ground_layer.to_local(current_position))

func reset_previous_tiles() -> void:
	previous_tiles = [Vector2(0, 0)]

func build_status(tower_preview: TowerBase) -> void:
	var mouse_pos : Vector2 = get_global_mouse_position()
	var centre_tile : Vector2i = path_exclusion_layer.local_to_map(mouse_pos)
	var centre_tile_pos : Vector2 = path_exclusion_layer.map_to_local(centre_tile)
	var all_cells : Array[Vector2i] = []
	
	tower_preview.build_data.build_position = centre_tile_pos
	tower_preview.build_data.build_valid = true
	
	#for each cell in tower shape, do below code
	for child in tower_preview.tower_children:
		var current_cell : Vector2i = path_exclusion_layer.local_to_map(child.global_position)
		all_cells.append(current_cell)
		path_pathfinding_layer.set_cell(current_cell, 0, Vector2i(0,0), 0)
		astar_preview.set_point_solid(current_cell, true)
		if path_exclusion_layer.get_cell_source_id(current_cell) != -1 or update_preview().is_empty():
			tower_preview.build_data.build_valid = false
	
	for tile in previous_tiles:
		if all_cells.has(tile):
			continue
		if path_exclusion_layer.get_cell_source_id(tile) == -1:
			astar_preview.set_point_solid(tile, false)
		path_pathfinding_layer.clear()
	previous_tiles = all_cells
	
	pathing_visual_update()

func build_mode_cleanup() -> void:
	path_pathfinding_layer.clear()
	for tile in previous_tiles:
		astar_preview.set_point_solid(tile, false)
	pathing_visual_update()

func on_tower_built(new_tower: TowerBase) -> void:
	for child in new_tower.tower_children:
		var child_tile = path_exclusion_layer.local_to_map(child.global_position)
		path_exclusion_layer.set_cell(child_tile, 5, Vector2i(1,0), 0)
		astar_pathing.set_point_solid(child_tile, true)
		astar_preview.set_point_solid(child_tile, true)
	pathing_visual_update()
	pathing_updated.emit()

func on_tower_sold(_sell_value: int, tower: TowerBase) -> void:
	for child in tower.tower_children:
		var tile_pos: Vector2i = path_exclusion_layer.local_to_map(child.global_position)
		path_exclusion_layer.set_cell(tile_pos)
		astar_pathing.set_point_solid(tile_pos, false)
	pathing_visual_update()
	pathing_updated.emit()

func update_baddy_pathing(current_position: Vector2, waypoint_index: int) -> PackedVector2Array:
	if waypoint_index >= all_waypoints.size():
		return PackedVector2Array([Vector2(-1000,-1000)])
	return astar_pathing.get_point_path(_get_current_tile(current_position), _get_current_tile(all_waypoints[waypoint_index]))
