class_name OnHitBuff extends Buff

enum AffectedStat {
	HEALTH,
	MAX_HEALTH,
	MOVE_SPEED,
	DAMAGE,
	ATTACK_SPEED,
	DEFENCE,
}

@export_range(0.0, 1.0, 0.1, "suffix: %") var success_chance_per_stack : Array[float]
@export var buff_to_apply : Buff
@warning_ignore("enum_variable_without_default")
@export var damage_tag : GlobalEnums.DamageTag
@export var effect_aoe : Array[float] = [0, 0, 0, 0, 0]
@export var effect_amount : Array[float] = [1, 1, 1, 1, 1]
##Refers to duration of effects produced by on hit success (ex. Burst speed MS buff or stun duration)
@export var effect_duration : Array[float] = [1, 1, 1, 1, 1]
var stat_buff


func _init(
	_damage_tag : GlobalEnums.DamageTag = 0,
	#_affected_stats : AffectedStat = AffectedStat.DAMAGE,
	_stat: GlobalEnums.BuffableStats = GlobalEnums.BuffableStats.MAX_HEALTH, 
	_buff_duration: Array[float] = [1.0],
	_buff_amount: Array[float] = [1.0],
	_effect_amount: Array[float] = [1.0],
	_targets: GlobalEnums.Targets = GlobalEnums.Targets.NONE,
	_success_chance_per_stack : Array[float] = [0.1],
	_effect_aoe : Array[float] = [1.0],
	_effect_duration : Array[float] = [1.0],
) -> void:
	success_chance_per_stack = _success_chance_per_stack
	effect_aoe = _effect_aoe
	effect_duration = _effect_duration
	damage_tag = _damage_tag


func effect_trigger() -> void:
	pass
