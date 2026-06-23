@abstract
class_name Buff extends Resource

@export var info_name : String
@export var info_display_icon : Texture2D
@export_range(1, 99) var stack_limit: Array[int] = [99, 99, 99, 99, 99]
##For OnHit Buffs, this refers to the buff applied 
##(ex. shock: buff duration is for the shock buff, effect duration is for the stun)
@export var buff_duration : Array[float] = [1, 1, 1, 1, 1]
## No Target = 0, Towers = 1, Baddies = 2, Self = 3
@export var buff_targets : GlobalEnums.Targets
@export var buff_effect_aoe : Array[float] = [0, 0, 0, 0, 0]
##Amount of damage for damaging buffs such as periodic effects or on hit effects like shock, 
##strength of effect for stat/other effects
@export var effect_amount : Array[float] = [1, 1, 1, 1, 1]
##Does not have a duration and will not be removed.
@export var persistent_effect : bool = false
