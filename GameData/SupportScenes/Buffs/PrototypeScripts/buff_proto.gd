@abstract
class_name Buff extends Resource

@export var name : String
@export var stack_limit: int = 99
@export var buff_duration : float
@export var buff_targets : GlobalEnums.AuraTargets

@abstract func _init() -> void
