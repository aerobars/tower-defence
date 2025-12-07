class_name WeaponMod extends TowerMod

enum WeaponBuffableStats {
	DAMAGE,
	ATTACK_SPEED,
	AOE,
	CRIT_CHANCE,
	RANGE,
	POWER
}

enum ProjectileType { INSTANT, PROJECTILE }
enum AttackType { PIERCE, BLUNT, EXPLOSION }
@export var projectile_tag: ProjectileType
@export var attack_type : AttackType
@export var attack_tags: Array = [attack_type]

#level based variables
@export var base_range_levels : Array[float]
@export var base_damage_levels : Array[float]
@export var base_attack_speed_levels : Array[float] ##measured in attacks per second
@export var base_aoe_levels : Array[float]
@export var base_crit_chance : Array[float]
var current_range : float
var current_damage : float
var current_attack_speed : float
var current_aoe : float
var current_crit_chance : float

func buff_check(buff_stat) -> bool:
	return AllBuffableStats.AllBuffableStats.keys()[buff_stat] in WeaponBuffableStats.keys()

func recalculate_stats(stat_addends, stat_multipliers) -> void:
	current_power = base_power_levels[level]
	current_range = base_range_levels[level]
	current_damage = base_damage_levels[level]
	current_attack_speed = base_attack_speed_levels[level]
	current_crit_chance = base_crit_chance[level]
	current_aoe = base_aoe_levels[level]
	
	#addends first so it benefits from multipliers
	for stat_name in stat_addends:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])

	for stat_name in stat_multipliers:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])
