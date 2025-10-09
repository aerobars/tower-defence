class_name WeaponMod extends TowerMod

@export var damage : Array[float]
@export var rate_of_fire : Array[float] ##measured in attacks per second
enum AttackType { PIERCE, BLUNT, EXPLOSION }
@export var attack_type : AttackType
@export var power_cost : Array[int]

@export var attack_tags: Array = [attack_type]

enum ProjectileType { INSTANT, PROJECTILE }
@export var projectile_tag: ProjectileType

func _init() -> void:
	mod_class = ModType.WEAPON

func level_up() -> void:
	super.level_up()
	pass
