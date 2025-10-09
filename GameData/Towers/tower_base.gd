class_name TowerBase extends StaticBody2D

#level 0 to line up with arrays
var level := 0
var marker_count : int = 0
var all_marker_pos : Dictionary[Marker2D,Vector2]
var marker_pos_radius : float = 20

var is_built := false

func _ready() -> void:
	#set non-mod children to internal, so that they won't be called in future get_children calls
	for child in get_children():
		child.INTERNAL_MODE_FRONT
		if child.get_class() == "Marker2D":
			child.add_to_group("marker")
			all_marker_pos.set(child, child.position)
			marker_count += 1
	marker_position()


func level_up() -> void:
	for child in get_children():
		child.level_up()
		pass

func marker_position() -> void:
	var count : int = 0
	for marker in all_marker_pos:
		var angle = (TAU * count) / marker_count
		marker.position.x = marker_pos_radius * cos(angle)
		marker.position.y = marker_pos_radius * sin(angle)
		all_marker_pos[marker] = marker.position
		count += 1

##called if # of markers gets updated
func update_markers() -> void:
	all_marker_pos = {}
	for node in get_tree().get_nodes_in_group("marker"):
		if self.is_ancestor_of(node):
			all_marker_pos.set(node, node.position)
	marker_position()
