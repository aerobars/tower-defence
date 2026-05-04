@tool
class_name TowerFrameGenerator extends Node2D

const COLUMNS : int = 3
const ROWS : int = 3
const CELL_SIZE : int = 64

var grid_size : int : 
	get():
		return CELL_SIZE * COLUMNS

var frame_coords : Array

const TOWER_MOD_PROTO : PackedScene = preload("res://GameData/Towers/Scenes/frame_cell.tscn")

##Editor Functions
@export_tool_button("Generate Vectors") var vector = get_vectors_from_nodes
func get_vectors_from_nodes() -> void:
	frame_coords = []
	for child in get_children():
		if child is Node2D and child.visible:
			frame_coords.append(Vector2i(child.position.x, child.position.y) / CELL_SIZE)
	
	if Engine.is_editor_hint():
		var parts := []
		for coord in frame_coords:
			parts.append("Vector2i(%d, %d)" % [coord.x, coord.y])
		print("[" + ", ".join(parts) + "]")

@export_tool_button("Rotate Shape") var rotate_shape = tower_rotation
func tower_rotation() -> void:
	rotation_degrees += 90 

func _ready() -> void:
	get_nodes_from_vectors()

func get_nodes_from_vectors() -> void:
	for cell in frame_coords:
		var new_tower = TOWER_MOD_PROTO.instantiate()
		new_tower.position = Vector2i(cell.x * CELL_SIZE - grid_size/2, cell.y * CELL_SIZE - grid_size/2)
		add_child(new_tower)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate_counterclockwise"):
		var tween = get_tree().create_tween()
		tween.tween_property(self, "rotation", rotation - PI/2, 0.1)
		#counter rotate mod image
		return
	if event.is_action_pressed("rotate_clockwise"):
		var tween = get_tree().create_tween()
		tween.tween_property(self, "rotation", rotation + PI/2, 0.1)
		#counter rotate mod image
		return
