class_name PowerMod extends TowerMod

@export var power_supply : Array[int]
var power_supply_lvl : int#= power_supply[level]

func _init() -> void:
	mod_class = ModType.POWER

func level_up()-> void:
	super.level_up()
	power_supply_lvl = power_supply[level]
