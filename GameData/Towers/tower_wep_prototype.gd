class_name TowerWeaponPrototype extends Node2D

#attack types
var type
#category for projectiles
var category
var enemy_array: Array
#var is_built := false
var enemy
var reloaded := true


func _ready():
	#if is_built:
	self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.tower_data[type]["range"]
		


##Mod Updates

func update_mod() -> void:
	$Turret.texture = 


##In Game Function

func _physics_process(_delta: float) -> void:
	if enemy_array.size() != 0 and is_built:
		select_enemy()
		if not $AnimationPlayer.is_playing():
			turn()
		if reloaded:
			fire()
	else:
		enemy = null

func turn():
	get_node("Turret").look_at(enemy.position)

func select_enemy():
	var enemy_progress_array := []
	for i in enemy_array:
		enemy_progress_array.append(i.progress)
	var max_progress = enemy_progress_array.max()
	var enemy_index = enemy_progress_array.find(max_progress)
	enemy = enemy_array[enemy_index]

func fire():
	reloaded = false
	if category == "projectile":
		fire_projectile()
	elif category == "instant":
		fire_gun()
	enemy.on_hit(GameData.tower_data[type]["damage"])
	await(get_tree().create_timer(GameData.tower_data[type]["rof/s"]).timeout)
	reloaded = true

func fire_gun():
	get_node("AnimationPlayer").play("fire")

func fire_projectile():
	pass

func _on_range_body_entered(body: Node2D) -> void:
	enemy_array.append(body.get_parent())
	print(enemy_array)
	print(self.get_name())

func _on_range_body_exited(body: Node2D) -> void:
	enemy_array.erase(body.get_parent())
