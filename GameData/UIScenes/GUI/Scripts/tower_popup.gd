class_name TowerPopup extends Node2D

signal upgrade_check(upgrade_cost : int, popup_owner : TowerBase, self_ref : TowerPopup) 
signal upgrade
signal sell

var data : Array #contains all towermod data of tower's mods, last array entry is level name
@export var container : VBoxContainer
@export var tower_name : Label
@export var upgrade_button : Button
@export var sell_button : Button
#@onready var mod_class : Label = $Background/VBoxContainer/Class
#@onready var power : Label = $Background/VBoxContainer/Power
#@onready var description : Label = $Background/VBoxContainer/Description
var popup_owner : TowerBase
var level_names := ["Basic", "Advanced", "Expert", "Master", "Grandmaster"]
var current_level_name : String: 
	get:
		return level_names[popup_owner.level]
var upgrade_cost : int = 0: 
	set(value): #value should always be total mod slots of associated tower
		upgrade_cost = (1 + value * 3) * 2 ** (popup_owner.level + 1)
		upgrade_button.text = "-$" + str(upgrade_cost) + ": Upgrade"
var sell_value : int = 0: 
	set(value): #value should always be total mod slots of associated tower
		sell_value = roundi(((1 + float(value) * 3) * 2 ** float(popup_owner.level))/2)
		sell_button.text = "Sell: +$" + str(sell_value)

func _ready() -> void:
	stats_setup()
	for i in data:
		pass

func stats_setup() -> void:
	tower_name.text = current_level_name + " Tower"
	upgrade_cost = popup_owner.mod_slot_count
	sell_value = popup_owner.mod_slot_count

func _on_sell_button_pressed() -> void:
	sell.emit(sell_value, popup_owner) #connected to GameScene
	queue_free()


func _on_upgrade_button_pressed() -> void:
	upgrade_check.emit(upgrade_cost, popup_owner, self) #connected to GameScene
