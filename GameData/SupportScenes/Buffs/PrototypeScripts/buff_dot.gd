class_name DotBuff extends Buff


@export var damage_tag : GlobalEnums.DamageTag = 0
@export var damage_amount : float
@export var dot_interval : float

func _init(
	_damage_tag: GlobalEnums.DamageTag = GlobalEnums.DamageTag.BURN, 
	_buff_targets: GlobalEnums.AuraTargets = GlobalEnums.AuraTargets.BADDIES,
	_damage_amount: float = 1.0,
	_dot_interval: float = 1.0,
	_dot_duration: float = 1.0
	) -> void:
	damage_tag = _damage_tag
	damage_amount = _damage_amount
	dot_interval = _dot_interval
	buff_duration = _dot_duration
