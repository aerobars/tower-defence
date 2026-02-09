class_name WeaponMod extends PrototypeMod

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
@export var damage_tags : int = GlobalEnums.DamageTag.PIERCE

##level based variables
@export var base_aoe_levels : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
@export var base_attack_speed_levels : Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0] #cd between attacks in seconds
@export var base_crit_chance_levels : Array[int] = [0, 0, 0, 0, 0]
@export var base_crit_multiplier_levels: Array[float] = [1.5, 1.5, 1.5, 1.5, 1.5]
@export var base_damage_levels : Array[float] = [10.0, 10.0, 10.0, 10.0, 10.0]
@export var base_multitarget_levels : Array [int] = [1, 1, 1, 1, 1]
var current_aoe : float
var current_attack_speed : float
var current_crit_chance : int
var current_crit_multiplier: float
var current_damage : float
var current_multitarget : int

func buff_check(buff_stat) -> bool:
	var str_buff_stat : String
	if buff_stat is int:
		str_buff_stat = GlobalEnums.BuffableStats.keys()[buff_stat].to_upper()
	else:
		str_buff_stat = buff_stat.to_upper()
	return WeaponBuffableStats.keys().has(str_buff_stat.to_upper())

func set_current_stats() -> void:
	current_aoe = base_aoe_levels[level]
	current_attack_speed = base_attack_speed_levels[level]
	current_crit_chance = base_crit_chance_levels[level]
	current_crit_multiplier = base_crit_multiplier_levels[level]
	current_damage = base_damage_levels[level]
	current_multitarget = base_multitarget_levels[level]
	current_power = base_power_levels[level]
	current_range = base_range_levels[level]

func calculate_damage() -> Array: #returns [total attack damage, damage tags, did the attack crit]
	if current_crit_chance > randi() % 100:
		return [current_damage * current_crit_multiplier, damage_tags, true]
	else:
		return [current_damage, damage_tags, false]

func add_on_hit_effect(buff : Buff) -> void:
	if buff.damage_tag > 0:
		damage_tags |= buff.damage_tag
	on_hit_effects.append(buff)

func remove_on_hit_effect(buff : Buff) -> void:
	if buff.damage_tag > 0:
		damage_tags &= ~buff.damage_tag
	on_hit_effects.erase(buff)
