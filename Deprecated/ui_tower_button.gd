extends TextureButton


const tower := preload("res://tower.tscn")
var new_tower: Node2D
var following: bool

@onready var game_node := get_node("/root/Game")
@onready var hud_node := get_parent()
@onready var camera := get_node("root/Game/Camera2d")

func _on_pressed():
	if not following:
		following = true
		new_tower = tower.instantiate()
		new_tower.collision_layer = 0
		hud_node.add_child(new_tower)

func _process(_delta):
	if following and new_tower:
		new_tower.position = get_viewport().get_mouse_position()

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and following:
		print("check")
		following = false
		hud_node.remove_child(new_tower)
		new_tower.collision_layer = 1 << 0
		#convert towers/cursors local(UI) coordinates to global(map) coords
		new_tower.position = camera.to_global(get_viewport().get_mouse_position())
		game_node.add_child(new_tower)
		new_tower = null
