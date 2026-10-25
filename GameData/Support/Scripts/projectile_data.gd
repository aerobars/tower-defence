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
var damage : float
var damage_tags : int
var crit_chance : float
var crit_multi : float
var aoe : float
var level : int

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
	aoe = projectile_owner.data.current_aoe
	damage_tags = projectile_owner.data.damage_tags
	
	damage = projectile_owner.data.current_damage
	level = projectile_owner.level
	crit_chance = projectile_owner.data.current_crit_chance
	crit_multi = projectile_owner.data.current_crit_multiplier
