extends Control

@onready var intro : TextureRect = $Intro
@onready var game_obj : TextureRect = $GameObj
@onready var tower_building : TextureRect = $TowerBuilding
@onready var mods_intro : TextureRect = $ModsIntro
@onready var powering_mods : TextureRect = $PoweringMods
@onready var end : TextureRect = $End

func _ready() -> void:
	if SaveManager.save_data_profile.show_tutorial == false:
		queue_free()

func _on_skip_tutorial_button_up() -> void:
	SaveManager.save_data_profile.show_tutorial = false
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
