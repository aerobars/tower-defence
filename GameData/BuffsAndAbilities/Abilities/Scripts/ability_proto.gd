@abstract
##Prototype for Ability scene, contains functions for execution of ability during runtime
class_name AbilityPrototype extends Node2D

@export var data : AbilityData

var cooldown_timer : float 

var ability_owner : CollisionObject2D

@abstract func ability_setup() -> void
