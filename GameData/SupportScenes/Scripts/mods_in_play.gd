##Resource class for sto
class_name ModsInPlay extends Resource

var data : ModPrototype
var levels : Array[int]

func _init(_data : ModPrototype) -> void:
	data = _data

func append_level(_level : int) -> void:
	levels.append(_level) 

func sort_levels() -> void:
	levels.sort_custom(func(a, b): return a > b)
