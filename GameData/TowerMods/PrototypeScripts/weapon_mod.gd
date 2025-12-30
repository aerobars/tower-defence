class_name WeaponMod extends TowerMod

enum WeaponBuffableStats {
	DAMAGE,
	ATTACK_SPEED,
	AOE,
	CRIT_CHANCE,
	RANGE,
	POWER
}

enum ProjectileTag { INSTANT, PROJECTILE }
@export var projectile_tag: ProjectileTag
@export var damage_tag : AllDamageTags.DamageTag = AllDamageTags.DamageTag.PIERCE
#@export var attack_tags: Array = [attack_type]

#level based variables
@export var base_aoe_levels : Array[float]
@export var base_attack_speed_levels : Array[float] ##measured in attacks per second
@export var base_crit_chance_levels : Array[int]
@export var base_crit_multiplier_levels: Array[float]
@export var base_damage_levels : Array[float]
@export var base_multitarget_levels : Array [int] = [1]
@export var base_range_levels : Array[float] #range value is radius of range circle
var current_aoe : float
var current_attack_speed : float
var current_crit_chance : int
var current_crit_multiplier: float
var current_damage : float
var current_multitarget : int
var current_range : float

func buff_check(buff_stat) -> bool:
	return AllBuffableStats.BuffableStats.keys()[buff_stat] in WeaponBuffableStats.keys()

func recalculate_stats(stat_addends, stat_multipliers) -> void:
	current_aoe = base_aoe_levels[level]
	current_attack_speed = base_attack_speed_levels[level]
	current_crit_chance = base_crit_chance_levels[level]
	current_crit_multiplier = base_crit_multiplier_levels[level]
	current_damage = base_damage_levels[level]
	current_multitarget = base_multitarget_levels[level]
	current_power = base_power_levels[level]
	current_range = base_range_levels[level]
	
	#addends first so it benefits from multipliers
	for stat_name in stat_addends:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])

	for stat_name in stat_multipliers:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])

func calculate_damage() -> Array: #returns [total attack damage, did the attack crit]
	if current_crit_chance > randi() % 100:
		return [current_damage * current_crit_multiplier, true]
	else:
		return [current_damage, false]
