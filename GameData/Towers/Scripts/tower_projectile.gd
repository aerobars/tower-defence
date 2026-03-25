class_name TowerProjectile extends Node2D

##Projectile Stats
var speed : float = 700
var direction : Vector2
var lifetime_total : float = 3.0
var lifetime_cur : float = 0.0
var destination : Vector2

##Weapon Stats
var pierce_count : int
var pierce_total : int
var damage : Array
var aoe : float
var on_hit_effects : Array[Buff]


func _process(delta: float) -> void:
	position += direction * speed * delta
	lifetime_cur += delta
	if lifetime_cur >= lifetime_total:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("baddies"):
		pierce_count += 1
		if aoe > 0:
			var baddies = await AOESetup.setup_aoe(self, body.global_position, "baddies", aoe)
			for baddy in baddies:
				baddy.on_hit(damage, on_hit_effects)
		else:
			body.get_parent().on_hit(damage, on_hit_effects)
		if pierce_count == pierce_total:
			queue_free()
