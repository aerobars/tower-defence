##Prototype for Ability scene, contains functions for execution of ability during runtime
##Contains data specific around constructing and executing ability functions
@abstract class_name Ability extends Effect


var ability_owner: CollisionObject2D
var ability_source: CollisionObject2D

@export_group("Ability Info", "info_")
#@export var info_name: String
#@export var info_display_icon: Texture2D
@export_multiline() var info_description: String

##data for buff that is applied
@export var buff_data: Buff

var owner_level: int :
	get:
		return ability_owner.get_level()

@export_group("Universal Ability Data", "ability_")
@export var ability_targets: GlobalEnums.Targets
##Damage or heal amount
@export var ability_effect_amount: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
##Damage Tag = 0 is no effect
@warning_ignore("enum_variable_without_default")
@export var ability_damage_tag: GlobalEnums.DamageTag

var cooldown_timer: float  
@export var ability_cooldown: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
##AoE of ability effect. Aura range for auras, aoe of triggered abiliites, etc.
@export var ability_aoe: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]

##ability_owner set in ability_proto, use super to expand for specific ability needs
func ability_setup(_ability_owner: UnitScenePrototype, _ability_source: UnitScenePrototype) -> void:
	ability_owner = _ability_owner
	ability_source = _ability_source
	if ability_cooldown[owner_level] > 0.0:
		ability_owner.process_update.connect(process)

##Dummy function to allow process signal setup
func process(_delta: float, _position: Vector2) -> void:
	pass
