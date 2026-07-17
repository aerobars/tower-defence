class_name ProjectileScene extends Node2D

signal hit_detected

##Projectile Stats

var data : ProjectileData
var direction : Vector2

var lifetime_cur : float = 0.0
var pierce_count : int = 0

func _process(delta: float) -> void:
	position += direction * data.speed * delta
	lifetime_cur += delta
	if lifetime_cur >= data.lifetime_total:
		queue_free()

func _on_area_2d_body_entered(body: UnitScenePrototype) -> void:
	#don't need to check body type because of collision layers 
	pierce_count += 1
	if data.aoe > 0:
		var baddies = StaticFunctions.setup_aoe(
			self, 
			body.global_position, 
			"baddies", 
			data.aoe)
		for baddy in baddies:
			baddy.on_hit(data.damage.duplicate(), data.on_hit_effects)
			hit_detected.emit(baddy.global_position)
	else:
		body.on_hit(data.damage.duplicate(), data.on_hit_effects)
		hit_detected.emit(body.global_position)
	if pierce_count == data.pierce_total:
		queue_free()
