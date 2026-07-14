class_name TowerBuildData extends RefCounted

var aura_tower : bool
var mods : Dictionary[int, ModPrototype]
var power_buffs : Dictionary
var shape : Array
var build_valid : bool = false
var build_position : Vector2
var cell_size : int


func _init(
	_aura_tower: bool, 
	_mods: Dictionary[int, ModPrototype], 
	_power_buffs : Dictionary, 
	_shape : Array
	) -> void:
	
	aura_tower = _aura_tower
	mods = _mods
	power_buffs = _power_buffs
	shape = _shape
