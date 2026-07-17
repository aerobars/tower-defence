class_name ProjectileData extends RefCounted

var projectile_owner : UnitScenePrototype

## Initial Settings

var init_pos : Vector2
var target_pos : Vector2

## Projectile Stats

var speed : float
var lifetime_total : float = 3.0

## Weapon Stats

var pierce_total : int
var damage : Array
var aoe : float
var on_hit_effects : Array[Buff]

func _init(
	_projectile_owner: UnitScenePrototype,
	_init_pos: Vector2,
	_target_pos: Vector2
	) -> void:
	
	projectile_owner = _projectile_owner
	init_pos = _init_pos
	target_pos = _target_pos
	
	speed = projectile_owner.data.projectile_speed
	pierce_total = projectile_owner.data.current_pierce
	damage = projectile_owner.data.calculate_damage()
	aoe = projectile_owner.data.current_aoe
	on_hit_effects = projectile_owner.data.on_hit_effects
