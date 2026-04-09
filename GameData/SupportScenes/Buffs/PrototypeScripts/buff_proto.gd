@abstract
class_name Buff extends Resource

@export var name : String
@export var stack_limit: Array[int] = [99, 99, 99, 99, 99]
##For OnHit Buffs, this refers to the buff applied (ex. shock: buff duration is for the shock buff, effect duration is for the stun)
@export var buff_duration : Array[float] = [1, 1, 1, 1, 1]
@export var targets : GlobalEnums.Targets
@export var aura_effect : bool = false

@abstract func _init() -> void
