class_name StatBuff extends Resource

enum BuffType {ADD, MULTIPLY}

@export var stat: AllBuffableStats.AllBuffableStats
@export var buff_amount: float
@export var buff_type: BuffType

func _init(_stat: AllBuffableStats.AllBuffableStats = AllBuffableStats.AllBuffableStats.MAX_HEALTH, _buff_type: StatBuff.BuffType = BuffType.MULTIPLY, 
  _buff_amount: float = 1.0) -> void:
	stat = _stat
	buff_type = _buff_type
	buff_amount = _buff_amount
	print(stat, buff_type, buff_amount)
