extends Control

@onready var intro : TextureRect = $Intro
@onready var game_obj : TextureRect = $GameObj
@onready var tower_building : TextureRect = $TowerBuilding
@onready var mods_intro : TextureRect = $ModsIntro
@onready var powering_mods : TextureRect = $PoweringMods
@onready var end : TextureRect = $End

var game_over := false


func _on_button_button_up() -> void:
	if not game_over:
		visible = false
	else:
		OS.shell_open("https://forms.gle/1gdVhHvJ8LJ4wVLX9")
		get_parent().get_parent().get_parent().game_finished.emit(false)



func _on_skip_tutorial_button_up() -> void:
	SaveManager.save_data_profile.show_tutorial = true
	queue_free()

func _on_intro_button_button_up() -> void:
	game_obj.visible = true
	intro.queue_free()

func _on_obj_button_button_up() -> void:
	tower_building.visible = true
	game_obj.queue_free()

func _on_tower_building_button_button_up() -> void:
	mods_intro.visible = true
	tower_building.queue_free()

func _on_mods_intro_button_button_up() -> void:
	powering_mods.visible = true
	mods_intro.queue_free()

func _on_powering_mods_button_button_up() -> void:
	end.visible = true
	powering_mods.queue_free()

func _on_end_button_button_up() -> void:
	end.queue_free()
