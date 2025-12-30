class_name DotBuff extends Buff


@export var damage_tag : AllDamageTags.DamageTag
@export var damage_amount : float
@export var damage_interval : float
@export var dot_duration : float
var is_active: bool = true

func _init(_damage_tag: AllDamageTags.DamageTag = AllDamageTags.DamageTag.POISON, _damage_amount: float = 1.0, 
  _damage_interval: float = 1.0, _dot_duration: float = 1.0) -> void:
	damage_tag = _damage_tag
	damage_amount = _damage_amount
	damage_interval = _damage_interval
	dot_duration = _dot_duration
