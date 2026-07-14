class_name ProjectileData extends RefCounted

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
	_speed: float, 
	_damage: Array, 
	_pierce: int, 
	_aoe: float, 
	_on_hit_effects: Array[Buff],
	_init_pos: Vector2,
	_target_pos: Vector2
	) -> void:
	
	speed = _speed
	pierce_total = _pierce
	damage = _damage
	aoe = _aoe
	on_hit_effects = _on_hit_effects
	init_pos = _init_pos
	target_pos = _target_pos
