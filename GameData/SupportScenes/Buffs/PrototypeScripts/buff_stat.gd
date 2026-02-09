class_name StatBuff extends Buff

enum BuffType {ADD, MULTIPLY}

@export var stat: GlobalEnums.BuffableStats
@export var buff_amount: float
@export var buff_type: BuffType

func _init(
	_stat: GlobalEnums.BuffableStats = GlobalEnums.BuffableStats.MAX_HEALTH, 
	_buff_targets: GlobalEnums.AuraTargets = GlobalEnums.AuraTargets.NONE,
	_buff_type: StatBuff.BuffType = BuffType.MULTIPLY, 
	_buff_amount: float = 1.0,
	_buff_duration: float = 1.0
	) -> void:
	stat = _stat
	buff_targets = _buff_targets
	buff_type = _buff_type
	buff_amount = _buff_amount
	buff_duration = _buff_duration
