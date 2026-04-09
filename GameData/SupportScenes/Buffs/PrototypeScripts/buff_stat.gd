class_name StatBuff extends Buff

enum BuffType {NONE, ADD, MULTIPLY, ABS}

@export var stat: GlobalEnums.BuffableStats
@export var buff_amount: Array[float]
@export var buff_type: BuffType

func _init(
	_stat: GlobalEnums.BuffableStats = GlobalEnums.BuffableStats.MAX_HEALTH, 
	_buff_type: StatBuff.BuffType = BuffType.MULTIPLY, 
	_buff_amount: Array[float] = [1.0],
	_buff_duration: Array[float] = [1.0],
	_targets: GlobalEnums.Targets = GlobalEnums.Targets.NONE,
	) -> void:
	stat = _stat
	buff_type = _buff_type
	buff_amount = _buff_amount
	buff_duration = _buff_duration
	targets = _targets
