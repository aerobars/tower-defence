extends Control

@onready var reward_card := preload("res://GameData/UIScenes/GUI/RewardSelection/reward_card.tscn")
@onready var reward_container := $TextureRect/HBoxContainer
var total_rewards : int = 2
var character = "Tester"
var filepath = GameData.CHAR_FILEPATH + character + "/"

func _ready() -> void:
	var reward_options = get_rewards()
	for i in total_rewards:
		var new_card = reward_card.instantiate()
		new_card.data = reward_options[i]
		reward_container.add_child(new_card)
		new_card.position = Vector2(0,0)


func get_rewards() -> Array[TowerMod]:
	var rewards : Array[TowerMod] = []
	for i in total_rewards:
		var mod = load(filepath + GameData.character_mods[character][randi() % GameData.character_mods[character].size()])
		rewards.append(mod)
		#code to account for weighted randomness
		#code to avoid duplicate rewards
	return rewards
