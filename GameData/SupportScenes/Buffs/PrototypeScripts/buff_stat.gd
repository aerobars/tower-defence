class_name StatBuff extends Buff

enum BuffType {NONE, ADD, MULTIPLY, ABS}

##AOE = 1, ATTACK_SPEED = 2, CRIT_CHANCE = 4, DAMAGE = 8, DEFENCE = 16, MAX_HEALTH = 32, MOVE_SPEED = 64
@export var stat: GlobalEnums.BuffableStats
@export var buff_amount: Array[float]
##None = 0, Add = 1, Multiply = 2, Absolute = 3
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
