class_name TravelBuff extends Buff

@export var damage_tag = AllDamageTags.DamageTag
@export var damage_amount : float
@export var damage_interval : float

func _init(
	_damage_tag : AllDamageTags.DamageTag = AllDamageTags.DamageTag.BLEED,
	_damage_amount : float = 1.0,
	_damage_interval : float = 100,
	_duration : float = 2.0,
	) -> void:
	damage_tag = _damage_tag
	damage_amount = _damage_amount
	damage_interval = _damage_interval
	buff_duration = _duration
