extends Node

var save_data_profile
var save_data_run: SaveDataRun
const SAVE_PATH = "user://save.tres"

func new_game():
	save_data_run = SaveDataRun.new()

func save_game():
	ResourceSaver.save(save_data_run, SAVE_PATH)

func load_game():
	if ResourceLoader.exists(SAVE_PATH):
		save_data_run = ResourceLoader.load(SAVE_PATH)
	else:
		new_game()
