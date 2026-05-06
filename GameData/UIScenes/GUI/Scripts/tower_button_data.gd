class_name TowerButtonData extends Resource

@export var slot_count : int : 
	get():
		return tower_shape.size()
var button_id : int #used as tower name for now
var mod_data : Dictionary[int, PrototypeMod] = {} #slot id: mod data, button data taken from SaveManager
@export var tower_shape : Array = []
#include variables for tower shape and/or name once different tower types are implemented
