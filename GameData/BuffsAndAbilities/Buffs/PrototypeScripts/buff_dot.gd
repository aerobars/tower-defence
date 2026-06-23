class_name DotBuff extends Buff


@export var damage_tag : GlobalEnums.DamageTag
@export var dot_interval : Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0]

func _init(
	_damage_tag: GlobalEnums.DamageTag = GlobalEnums.DamageTag.BURN, 
	_dot_interval: Array[float] = [1.0],
	_dot_duration: Array[float] = [1.0],
	_targets: GlobalEnums.Targets = GlobalEnums.Targets.BADDIES,
	) -> void:
	damage_tag = _damage_tag
	dot_interval = _dot_interval
	buff_duration = _dot_duration
	buff_targets = _targets
