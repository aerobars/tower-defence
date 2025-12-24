extends Control

signal connect_reward_card(reward_card: Control)

@onready var reward_card := preload("res://GameData/UIScenes/GUI/RewardSelection/reward_card.tscn")
@export var reward_container : Control
var total_rewards : int = 2
var character = "Tester"
var filepath = GameData.CHAR_FILEPATH + character + "/"
var inventory_ui


func _ready() -> void:
	var reward_options = get_rewards()
	for i in total_rewards:
		var new_card = reward_card.instantiate()
		new_card.data = reward_options[i]
		reward_container.add_child(new_card)
		new_card.reward_selected.connect(_on_reward_selected)
		connect_reward_card.emit(new_card)

func get_rewards() -> Array[TowerMod]:
	var rewards : Array[TowerMod] = []
	for i in total_rewards:
		var mod = load(filepath + GameData.character_mods[character][randi() % GameData.character_mods[character].size()])
		while rewards.has(mod): #duplicate prevention
			mod = load(filepath + GameData.character_mods[character][randi() % GameData.character_mods[character].size()])
		rewards.append(mod)
		#code to account for weighted randomness
	return rewards

func _on_reward_selected(_data) -> void:
	if get_tree().is_paused():
		get_tree().paused = false
	queue_free()
