@abstract
class_name Buff extends Resource

@export var name : String
@export var stack_limit: int = 99
@export var buff_duration : float
var is_active: bool = true

@abstract func _init() -> void
