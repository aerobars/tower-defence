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
##Array of cells currently containing baddies, to prevent building on top of them.
var occupied_cells : Array[Vector2i]

## Build Mode

var previous_tiles : Array[Vector2i]
var path_baddy_container : Node2D

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
			all_waypoints.append(get_current_tile(child.global_position))

##Updates the pathfinding line
func pathing_visual_update() -> void:
	path_pathfinding_visual.clear_points()
	for cell in update_preview():
		path_pathfinding_visual.add_point(cell)

##Returns pathing based on position of tower preview and exclusion layer
func update_preview() -> PackedVector2Array:
	var path : PackedVector2Array
	
	for i in all_waypoints.size() - 1:
		var segment : PackedVector2Array = astar_preview.get_point_path(all_waypoints[i], all_waypoints[i+1])
		if segment.is_empty():
			return segment
		if i > 0:
			segment.remove_at(0) #removes duplicate point
		path.append_array(segment)
	return path

func get_current_tile(current_global_position: Vector2) -> Vector2i:
	return path_ground_layer.local_to_map(path_ground_layer.to_local(current_global_position))

func reset_previous_tiles() -> void:
	previous_tiles = [Vector2(0, 0)]

func update_build_status(tower_preview: TowerBase) -> void:
	var centre_tile : Vector2i = get_current_tile(get_global_mouse_position())
	var centre_tile_pos : Vector2 = path_ground_layer.map_to_local(centre_tile)
	var all_tiles : Array[Vector2i] = []
	var baddy_occupied_tiles : Array[Vector2i] =[]
	
	tower_preview.build_data.build_position = centre_tile_pos
	tower_preview.build_data.build_valid = true
	
	for baddy in path_baddy_container.living_baddies:
		if not is_instance_valid(baddy):
			continue
		var occupied_tile = get_current_tile(baddy.global_position)
		if not baddy_occupied_tiles.has(occupied_tile):
			baddy_occupied_tiles.append(occupied_tile)
	
	#determines if tower can be built at current position
	for child in tower_preview.tower_children:
		var current_tile : Vector2i = get_current_tile(child.global_position)
		all_tiles.append(current_tile)
		path_pathfinding_layer.set_cell(current_tile, 0, Vector2i(0,0), 0)
		astar_preview.set_point_solid(current_tile, true)
		if baddy_occupied_tiles.has(current_tile) or path_exclusion_layer.get_cell_source_id(current_tile) != -1 or update_preview().is_empty():
			tower_preview.build_data.build_valid = false
	
	update_preview_layers(all_tiles)
	
	pathing_visual_update()

##Checks if the cells in previous_tiles are still being occupied. 
##If not, cleans up pathfinding_layer and removes the tile from astar_preview 
func update_preview_layers(all_tiles: Array[Vector2i]) -> void:
	for tile in previous_tiles:
		if all_tiles.has(tile):
			continue
		if path_exclusion_layer.get_cell_source_id(tile) == -1:
			astar_preview.set_point_solid(tile, false)
		path_pathfinding_layer.set_cell(tile) #erases cells not in current position
	previous_tiles = all_tiles

func build_mode_cleanup() -> void:
	path_pathfinding_layer.clear()
	pathing_visual_update()

func on_tower_built(new_tower: TowerBase) -> void:
	for child in new_tower.tower_children:
		var child_tile = get_current_tile(child.global_position)
		path_exclusion_layer.set_cell(child_tile, 5, Vector2i(1,0), 0)
		astar_pathing.set_point_solid(child_tile, true)
		astar_preview.set_point_solid(child_tile, true)
	pathing_visual_update()
	pathing_updated.emit()

func on_tower_sold(_sell_value: int, tower: TowerBase) -> void:
	for child in tower.tower_children:
		var child_tile: Vector2i = get_current_tile(child.global_position)
		path_exclusion_layer.set_cell(child_tile)
		astar_pathing.set_point_solid(child_tile, false)
	pathing_visual_update()
	pathing_updated.emit()

func update_baddy_pathing(current_tile: Vector2i, waypoint_index: int) -> PackedVector2Array:
	if waypoint_index >= all_waypoints.size():
		return PackedVector2Array([Vector2(-1000,-1000)])
	return astar_pathing.get_point_path(current_tile, all_waypoints[waypoint_index])
