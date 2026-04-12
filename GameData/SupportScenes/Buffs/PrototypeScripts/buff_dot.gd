class_name DotBuff extends Buff


@export var damage_tag : GlobalEnums.DamageTag
@export var damage_amount : Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0]
@export var dot_interval : Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0]

func _init(
	_damage_tag: GlobalEnums.DamageTag = GlobalEnums.DamageTag.BURN, 
	_damage_amount: Array[float] = [1.0],
	_dot_interval: Array[float] = [1.0],
	_dot_duration: Array[float] = [1.0],
	_targets: GlobalEnums.Targets = GlobalEnums.Targets.BADDIES,
	) -> void:
	damage_tag = _damage_tag
	damage_amount = _damage_amount
	dot_interval = _dot_interval
	buff_duration = _dot_duration
	targets = _targets
	
