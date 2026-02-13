extends Node

var save_data_profile : SaveDataProfile = null
var save_data_run : SaveDataRun = null
const SAVE_PATH = "user://save.tres"

func _ready() -> void:
	if existing_save():
		save_data_run = ResourceLoader.load(SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		new_game()

func new_game():
	save_data_run = SaveDataRun.new()

func save_run():
	ResourceSaver.save(save_data_run, SAVE_PATH)

func existing_save() -> bool:
	return ResourceLoader.exists(SAVE_PATH)
