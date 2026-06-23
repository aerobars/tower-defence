class_name BuffPeriodic extends Buff

@export var buff_to_apply : Buff
@warning_ignore("int_as_enum_without_cast")
@warning_ignore("int_as_enum_without_match")
##BLEED = 1, BLUNT = 2, BURN = 4, HEAL = 8, PIERCE = 16, POISON = 32, SHOCK = 64, Damage Tag = 0 is no effect
@export var damage_tag : GlobalEnums.DamageTag = 0
@export var effect_interval : Array[float] = [6.0, 6.0, 6.0, 6.0, 6.0]
