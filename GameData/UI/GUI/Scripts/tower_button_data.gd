class_name TowerButtonData extends Resource

@export var slot_count : int : 
	get():
		return tower_shape.size()
##used as tower name for now
var button_id : int 
##slot id: mod data, button data taken from SaveManager
var mod_data : Dictionary[int, ModPrototype] = {} 
##shape coords read from L to R, Top to Bottom in 3x3 grid with 0,0 at the centre cell (-1,-1 to 1,1)
@export var tower_shape : Array = [] 
#include variables for tower shape and/or name once different tower types are implemented
