##Prototype class for Buffs and Abilities
@abstract class_name EffectPrototype extends Resource


@export_group("Effect Info", "info_")
@export var info_name : String
@export var info_display_icon : Texture2D

@export var effect_amount : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
@export var targets : GlobalEnums.Targets
@export var aoe : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
