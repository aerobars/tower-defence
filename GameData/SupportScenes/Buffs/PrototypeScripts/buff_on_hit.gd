class_name OnHitBuff extends Buff

@export_range(0.0, 1.0, 0.1, "suffix: %") var success_chance_per_stack : float
@export var damage_tag : AllDamageTags.DamageTag
@export var damage_amount : float
@export var damage_aoe : float
@export var effect_duration : float


func _init(
	_success_chance_per_stack : float = 0.1,
	_damage_amount : float = 1.0,
	_damage_aoe : float = 1.0,
	_damage_tag : AllDamageTags.DamageTag = AllDamageTags.DamageTag.SHOCK,
	_effect_duration : float = 1.0
) -> void:
	success_chance_per_stack = _success_chance_per_stack
	damage_amount = _damage_amount
	damage_aoe = _damage_aoe
	damage_tag = _damage_tag
	effect_duration = _effect_duration
