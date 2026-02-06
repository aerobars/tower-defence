extends Node

signal mod_update_check(mod: StaticBody2D)

# Game Colours
var positive_colour : Color = Color(0.25, 0.39, 0.92, 1.0)
var negative_colour : Color = Color(0.8, 0.19, 0.1, 1.0)
var critical_colour : Color = Color.html("#B22")
var poison_colour : Color = Color.html("#235417")
var shock_colour : Color = Color.GOLD
var burn_colour : Color = Color.html("#f26d07")

var is_dragging = false

const BADDY_FILEPATH = "res://GameData/Baddies/"
const CHAR_FILEPATH = "res://GameData/TowerMods/CharacterMods/"
const TOTAL_ACTS = 1
const BOSS_WAVES := [5, 10, 15, 20]
var character_mods : Dictionary = {}
var act_baddies : Dictionary = {}
var act_bosses : Dictionary ={}
var previous_wave : Array = []
var current_wave : int = 0
var current_act : int = 0

func _ready() -> void:
	get_act_data(BADDY_FILEPATH + "Act")
	get_mod_data(CHAR_FILEPATH, "Generic")

func get_act_data(filepath: String) -> void:
	for i in TOTAL_ACTS:
		var dir := DirAccess.open(filepath + str(i+1))
		var boss_dir := DirAccess.open(filepath + str(i+1) + "Bosses")
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
			print("An error occurred when trying to access the baddy path.")
		if boss_dir:
			act_bosses[i] = []
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					continue
				else:
					act_bosses[i].append(file_name)
				file_name = dir.get_next()
		else:
			print("An error occurred when trying to access the boss path.")

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

func get_wave_data() -> Dictionary:
	var wave_data : Dictionary = {"wave_baddies" : [], "wave_total" : 0}
	var act_size : int = act_baddies[current_act].size()
	if BOSS_WAVES.has(current_wave):
		wave_data["wave_baddies"] = [act_bosses[current_act][randi() % act_size]]
		wave_data["wave_total"] = 1
	else:
		wave_data["wave_baddies"] = [act_baddies[current_act][randi() % act_size], act_baddies[current_act][randi() % act_size]]
		while previous_wave.has(wave_data["wave_baddies"][0]) and previous_wave.has(wave_data["wave_baddies"][1]): #prevents same wave back to back
			wave_data["wave_baddies"] = [act_baddies[current_act][randi() % act_size], act_baddies[current_act][randi() % act_size]]
		for i in wave_data["wave_baddies"]:
			var spawn_data = load("res://GameData/Baddies/Act" + str(current_act + 1) + "/" + i)
			wave_data["wave_total"] += spawn_data.spawn_per_wave
		previous_wave = wave_data["wave_baddies"]
	return wave_data

func mod_updated(mod: StaticBody2D) -> void:
	mod_update_check.emit(mod)
