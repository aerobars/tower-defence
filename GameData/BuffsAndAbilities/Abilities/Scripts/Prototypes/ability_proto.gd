##Prototype for Ability scene, contains functions for execution of ability during runtime
##Contains data specific around constructing and executing ability functions
@abstract class_name AbilityPrototype extends Resource


var ability_owner : CollisionObject2D

@export_group("Ability Info", "info_")
@export var info_name : String
@export var info_texture : Texture2D
@export_multiline() var info_description : String

##data for buff that is applied
@export var buff_data: Buff

var cooldown_timer : float  
@export var cooldown : float = 6.0
##Success chance for onhit abilities
@export_range(0.0, 1.0, 0.01) var onhit_success_chance : float = 0.0
##AoE of ability effect, such as aura
@export var ability_aoe : Array[float] 

##ability_owner set in ability_proto, use super to expand for specific ability needs
func ability_setup(_ability_owner: CollisionObject2D) -> void:
	ability_owner = _ability_owner

func process(_delta: float) -> void:
	pass
