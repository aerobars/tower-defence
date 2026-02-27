extends Node

var save_data_profile : SaveDataProfile
var save_data_run : SaveDataRun
const SAVE_PATH = "user://save.tres"

func _ready() -> void:
	if existing_save("SaveDataProfile"):
		save_data_profile = ResourceLoader.load(SAVE_PATH, "SaveDataProfile", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		save_data_profile = SaveDataProfile.new()
	if existing_save():
		save_data_run = ResourceLoader.load(SAVE_PATH, "SaveDataRun", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		new_game()

func new_game():
	save_data_run = SaveDataRun.new()

func save_run():
	ResourceSaver.save(save_data_run, SAVE_PATH)

func existing_save(save_type : String = "SaveDataRun") -> bool:
	return ResourceLoader.exists(SAVE_PATH, save_type)
