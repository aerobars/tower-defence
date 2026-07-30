extends Node

signal tutorial_completed
signal setup_new_run
signal start_new_run
signal setup_saved_run

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
		new_game()
		save_data_run = ResourceLoader.load(SAVE_PATH_RUN, "SaveDataRun", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		new_game()

func new_game():
	save_data_run = SaveDataRun.new()

func check_save_status() -> void:
	GameData.sort_mod_data() #move to new_game_setup once GameData is saved in save_data_run
	
	if save_data_run.new_game : #rest of func only needs to run to load saved towers
		new_game_setup()
	else:
		setup_saved_run.emit()
		start_new_run.emit()

func new_game_setup() -> void:
	save_data_run.button_count = save_data_run.init_btn_count
	save_data_run.tower_shapes = save_data_run.init_tower_shapes
	save_data_run.inventory_data = save_data_run.init_inventory
	for i in save_data_run.init_btn_count:
		var new_button = TowerButtonData.new()
		new_button.button_id = i + 1
		new_button.tower_shape = SaveManager.save_data_run.init_tower_shapes[i] as Array[Vector2i]
		save_data_run.button_data.append(new_button)
	setup_new_run.emit()
	await tutorial_completed
	save_data_run.new_game = false
	start_new_run.emit()


func save_run():
	ResourceSaver.save(save_data_run, SAVE_PATH_RUN)

func existing_save(save_path : String = "user://run_save.tres", save_type : String = "SaveDataRun") -> bool:
	return ResourceLoader.exists(save_path, save_type)

func complete_tutorial() -> void:
	save_data_profile.tutorial_completed = true
	tutorial_completed.emit()
