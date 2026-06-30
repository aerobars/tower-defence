##Contains Data needed during runtime and gamewide standards,
##such as standard colours and icons
extends Node

signal mod_update_check(mod: StaticBody2D)

## Script Preloading

const BUFF = preload("res://GameData/BuffsAndAbilities/Buffs/PrototypeScripts/buff_proto.gd")
const STAT_BUFF = preload("res://GameData/BuffsAndAbilities/Buffs/PrototypeScripts/buff_stat.gd")
const ONHIT_BUFF = preload("res://GameData/BuffsAndAbilities/Buffs/PrototypeScripts/buff_onhit.gd")
const ABSOLUTE_BUFF = preload("res://GameData/BuffsAndAbilities/Buffs/PrototypeScripts/buff_abs.gd")
const DOT_BUFF = preload("res://GameData/BuffsAndAbilities/Buffs/PrototypeScripts/buff_dot.gd")

const ABILITY = preload("res://GameData/BuffsAndAbilities/Abilities/PrototypeScriptsAndScenes/Scripts/ability_proto.gd")
const TRIGGERED_ABILITY = preload("res://GameData/BuffsAndAbilities/Abilities/PrototypeScriptsAndScenes/Scripts/ability_triggered_proto.gd")
const AURA_ABILITY = preload("res://GameData/BuffsAndAbilities/Abilities/PrototypeScriptsAndScenes/Scripts/ability_aura_scene.gd")
const LAST_LAUGH_ABILITY = preload("res://GameData/BuffsAndAbilities/Abilities/PrototypeScriptsAndScenes/Scripts/ability_last_laugh.gd")
const ONHIT_ABILITY = preload("res://GameData/BuffsAndAbilities/Abilities/PrototypeScriptsAndScenes/Scripts/ability_onhit.gd")
const PERIODIC_ABILITY = preload("res://GameData/BuffsAndAbilities/Abilities/PrototypeScriptsAndScenes/Scripts/ability_periodic.gd")

## Game Colours

var positive_colour : Color = Color(0.25, 0.39, 0.92, 1.0)
var negative_colour : Color = Color(0.8, 0.19, 0.1, 1.0)
var critical_colour : Color = Color.html("#B22")
var poison_colour : Color = Color.html("#235417")
var shock_colour : Color = Color.GOLD
var burn_colour : Color = Color.html("#f26d07")

## Image Paths

const ICON_ATLAS := preload("res://Assets/Environment/Tilesets/colored_packed.png")
const ICON_DAMAGE_COORDS = Rect2(544.0, 96.0, 16.0, 16.0)
const ICON_DEFENCE_COORDS = Rect2(640.0, 48.0, 16.0, 16.0)
const ICON_HEALTH_COORDS = Rect2(624.0, 48.0, 16.0, 16.0)
const ICON_MOVE_SPEED_COORDS = Rect2(384.0, 336.0, 16.0, 16.0)

var is_dragging = false

const BADDY_FILEPATH = "res://GameData/Baddies/"
const CHAR_FILEPATH = "res://GameData/TowerMods/CharacterMods/"
const TOTAL_ACTS = 1
const BOSS_WAVES := [2]

var character_mods : Dictionary = {}
var act_baddies : Dictionary = {}
var act_bosses : Dictionary = {}

func _ready() -> void:
	get_act_data(BADDY_FILEPATH + "Act")
	get_mod_data(CHAR_FILEPATH, "Generic")

func get_act_data(filepath: String) -> void:
	for i in TOTAL_ACTS:
		var dir := ResourceLoader.list_directory(filepath + str(i+1))
		
		if dir == null:
			print("BADDY DIRETORY FAILED TO OPEN")
		var boss_dir := ResourceLoader.list_directory(filepath + str(i+1) + "Bosses/")
		
		act_baddies[i] = []
		for file in dir:
			if file.ends_with(".tres"):
				act_baddies[i].append(file)
		
		act_bosses[i] = []
		for file in boss_dir:
			if file.ends_with(".tres"):
				act_bosses[i].append(file)

func get_mod_data(filepath: String, dir_name) -> void:
	var dir := ResourceLoader.list_directory(filepath)
	
	if dir == null:
		print("MOD DIRECTORY FAILED TO OPEN")
	
	for file in dir:
		if file.ends_with("/"):
			var subdir = file.left(-1)
			character_mods[subdir] = []
			get_mod_data(filepath + "/" + subdir, subdir)
		elif file.ends_with(".tres"):
			character_mods[dir_name].append(file)
		else:
			print("Invalid filetype found in CharacterMods")

func get_wave_data() -> Dictionary:
	var wave_data : Dictionary = {
		"wave_baddies" : [], 
		"wave_total" : 0
		}
	var current_act = SaveManager.save_data_run.current_act
	var act_size : int = act_baddies[current_act].size()
	
	if BOSS_WAVES.has(SaveManager.save_data_run.current_wave):
		wave_data["wave_baddies"] = [act_bosses[current_act][randi() % act_bosses[current_act].size()]]
		wave_data["wave_total"] = 1
	else:
		wave_data["wave_baddies"] = [act_baddies[current_act][randi() % act_size], act_baddies[current_act][randi() % act_size]]
		while SaveManager.save_data_run.previous_wave.has(wave_data["wave_baddies"][0]) and SaveManager.save_data_run.previous_wave.has(wave_data["wave_baddies"][1]): 
		#prevents same wave back to back
			wave_data["wave_baddies"] = [act_baddies[current_act][randi() % act_size], act_baddies[current_act][randi() % act_size]]
		for i in wave_data["wave_baddies"]:
			var spawn_data = load("res://GameData/Baddies/Act" + str(current_act + 1) + "/" + i)
			wave_data["wave_total"] += spawn_data.spawn_per_wave
		SaveManager.save_data_run.previous_wave = wave_data["wave_baddies"]
	
	return wave_data

func get_baddy_filepath(baddy_file: String) -> BaddyStats:
	if BOSS_WAVES.has(SaveManager.save_data_run.current_wave):
		return load("res://GameData/Baddies/Act" + str(SaveManager.save_data_run.current_act + 1) + "Bosses/" + baddy_file)
	return load("res://GameData/Baddies/Act" + str(SaveManager.save_data_run.current_act + 1) + "/" + baddy_file)

func mod_updated(mod: StaticBody2D) -> void:
	mod_update_check.emit(mod)
