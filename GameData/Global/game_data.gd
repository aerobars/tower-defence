extends Node

var is_dragging = false

var act_baddies = {1 : ["blue_tank", "blue_tank", "blue_tank"], 2 : [], 3 : [], 4 : [], 5 : []}
var previous_wave : Array


func get_wave_data(cur_act) -> Array:
	var wave_baddies : Array
	var act_size : int = act_baddies[cur_act].size()
	wave_baddies = [act_baddies[cur_act][randi() % act_size], act_baddies[cur_act][randi() % act_size]]
	if wave_baddies != previous_wave:
		return wave_baddies
	else:
		return get_wave_data(cur_act)
