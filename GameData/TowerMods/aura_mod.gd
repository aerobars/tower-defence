class_name AuraMod extends TowerMod

enum DamageType {FIRE, COLD, POISON, PHYSICAL}
@export var damage_type : DamageType
@export var damage_mod : Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0]
@export var attack_speed_mod : Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0]
@export var move_speed_mod : Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0]
@export var debuff_proc_rate : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
@export var range_mod : Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0]
@export var is_aura : bool = false

func _init() -> void:
	mod_class = ModType.AURA

func level_up() -> void:
	super.level_up()
	pass
