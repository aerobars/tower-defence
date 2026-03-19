extends Node

var save_data_profile : SaveDataProfile
var save_data_run : SaveDataRun
const SAVE_PATH_PROFILE = "user://profile_save.tres"
const SAVE_PATH_RUN = "user://run_save.tres"

func _ready() -> void:
	if existing_save(SAVE_PATH_PROFILE, "SaveDataProfile"):
		save_data_profile = ResourceLoader.load(SAVE_PATH_PROFILE, "SaveDataProfile", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		save_data_profile = SaveDataProfile.new()
	if existing_save():
		save_data_run = ResourceLoader.load(SAVE_PATH_RUN, "SaveDataRun", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		new_game()

func new_game():
	save_data_run = SaveDataRun.new()

func save_run():
	ResourceSaver.save(save_data_run, SAVE_PATH_RUN)

func existing_save(save_path : String = "user://run_save.tres", save_type : String = "SaveDataRun") -> bool:
	return ResourceLoader.exists(save_path, save_type)
