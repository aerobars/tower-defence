extends Node

var is_dragging = false

const BADDY_FILEPATH = "res://GameData/Baddies/"
const CHAR_FILEPATH = "res://GameData/TowerMods/CharacterMods/"
const TOTAL_ACTS = 1
var character_mods : Dictionary = {}
var act_baddies : Dictionary = {}
var previous_wave : Array = []

func _ready() -> void:
	get_act_data(BADDY_FILEPATH + "Act")
	get_mod_data(CHAR_FILEPATH, "Generic")

func get_act_data(filepath: String) -> void:
	for i in TOTAL_ACTS:
		var dir := DirAccess.open(filepath + str(i+1))
		if dir:
			act_baddies[i] = []
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					continue
				else:
					act_baddies[i].append(file_name)
				file_name = dir.get_next()
		else:
			print("An error occurred when trying to access the path.")

func get_mod_data(filepath: String, dir_name) -> void:
	var dir := DirAccess.open(filepath)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				character_mods[file_name] = []
				get_mod_data(filepath + "/" + file_name, file_name)
			else:
				character_mods[dir_name].append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func get_wave_data(cur_act) -> Array:
	var wave_baddies : Array
	var act_size : int = act_baddies[cur_act].size()
	wave_baddies = [act_baddies[cur_act][randi() % act_size], act_baddies[cur_act][randi() % act_size]]
	if previous_wave.has(wave_baddies[0]) and previous_wave.has(wave_baddies[1]): #prevents same wave back to back
		return get_wave_data(cur_act)
	else:
		previous_wave = wave_baddies
		return wave_baddies
