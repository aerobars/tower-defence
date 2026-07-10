@abstract
class_name Buff extends Resource

@export_group("Buff Info", "info_")
@export var info_name : String
@export var info_display_icon : Texture2D

@export_group("Universal Buff Data", "buff_")
@export_range(1, 99) var buff_stack_limit: Array[int] = [99, 99, 99, 99, 99]
##For OnHit Buffs, this refers to the buff applied 
##(ex. shock: buff duration is for the shock buff, effect duration is for the stun)
@export var buff_duration : Array[float] = [1, 1, 1, 1, 1]
@export var buff_targets : GlobalEnums.Targets
@export var buff_effect_aoe : Array[float] = [0, 0, 0, 0, 0]
##Amount of damage for damaging buffs such as periodic effects or on hit effects like shock, 
##does not effect Stat Buffs
@export var buff_effect_amount : Array[float] = [1, 1, 1, 1, 1]
##Does not have a duration and will not be removed.
@export var buff_persistent_effect : bool = false
