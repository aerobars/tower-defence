class_name TowerProjectile extends Node2D

var speed : float
var direction : Vector2
var lifetime_total : float
var lifetime_cur : float
var destination : Vector2

var pierce_count : int
var pierce_total : int

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("baddies"):
		pierce_count += 1
		if get_parent().data.current_aoe > 0:
			var baddies = await get_parent().setup_aoe(body.global_position)
			for baddy in baddies:
				baddy.on_hit(get_parent().data.calculate_damage(), get_parent().data.on_hit_effects)
		else:
			body.on_hit(get_parent().data.calculate_damage(), get_parent().data.on_hit_effects)
		if pierce_count == pierce_total:
			queue_free()
