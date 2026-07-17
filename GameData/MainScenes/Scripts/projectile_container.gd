extends Node2D

const PROJECTILE_SCENE := preload("res://GameData/SupportScenes/Scenes/projectile.tscn")

##Creates projectile, sets projectile data, initial position, and projectile direction
func create_projectile(data: ProjectileData) -> void:
	var new_projectile = PROJECTILE_SCENE.instantiate()
	new_projectile.data = data
	new_projectile.hit_detected.connect(data.projectile_owner.projectile_contact)
	add_child(new_projectile)
	new_projectile.position = data.init_pos
	new_projectile.look_at(data.target_pos)
	new_projectile.direction = Vector2.RIGHT.rotated(new_projectile.rotation)
