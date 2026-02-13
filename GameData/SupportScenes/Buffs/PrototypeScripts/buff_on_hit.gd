class_name OnHitBuff extends Buff

enum AffectedStat {
	HEALTH,
	MAX_HEALTH,
	MOVE_SPEED,
	DAMAGE,
	ATTACK_SPEED,
	DEFENCE,
}

@export_range(0.0, 1.0, 0.1, "suffix: %") var success_chance_per_stack : float
@export var affected_stats : Array[AffectedStat]
@warning_ignore("enum_variable_without_default")
@export var damage_tag : GlobalEnums.DamageTag
@export var effect_amount : float
@export var effect_aoe : float
@export var effect_duration : float


func _init(
	_damage_tag : GlobalEnums.DamageTag = GlobalEnums.DamageTag.BLEED,
	_affected_stats : AffectedStat = AffectedStat.DAMAGE,
	_success_chance_per_stack : float = 0.1,
	_effect_amount : float = 1.0,
	_effect_aoe : float = 1.0,
	_effect_duration : float = 1.0,
	_buff_targets: GlobalEnums.AuraTargets = GlobalEnums.AuraTargets.NONE,
) -> void:
	affected_stats = [_affected_stats]
	success_chance_per_stack = _success_chance_per_stack
	effect_amount = _effect_amount
	effect_aoe = _effect_aoe
	damage_tag = _damage_tag
	effect_duration = _effect_duration
	buff_targets = _buff_targets
