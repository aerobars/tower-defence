class_name OnHitBuff extends Buff

@export_range(0.0, 100.0, 1.0, "suffix: %") var success_chance_per_stack : float
@export var damage_tag : AllDamageTags.DamageTag
@export var damage_amount : float
@export var effect_duration : float

func _init(
	_success_chance_per_stack : float = 10.0,
	_damage_amount : float = 1.0,
	_damage_tag : AllDamageTags.DamageTag = AllDamageTags.DamageTag.SHOCK,
	_effect_duration : float = 1.0
) -> void:
	success_chance_per_stack = _success_chance_per_stack
	damage_amount = _damage_amount
	damage_tag = _damage_tag
	effect_duration = _effect_duration
