class_name StatBuff extends Buff

enum BuffType {ADD, MULTIPLY}

@export var stat: AllBuffableStats.BuffableStats
@export var buff_amount: float
@export var buff_type: BuffType

func _init(
	_stat: AllBuffableStats.BuffableStats = AllBuffableStats.BuffableStats.MAX_HEALTH, 
	_buff_type: StatBuff.BuffType = BuffType.MULTIPLY, 
	_buff_amount: float = 1.0
	) -> void:
	stat = _stat
	buff_type = _buff_type
	buff_amount = _buff_amount
