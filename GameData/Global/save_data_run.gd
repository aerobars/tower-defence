class_name SaveDataRun extends Resource

##Run Data
@export var previous_wave : Array = []
@export var current_wave : int = 0
@export var current_act : int = 0

@export var current_player_health : int = 100
@export var character : String = "Tester"

@export var run_data : Resource #run seed, wave/level count
@export var player_data : Resource #cash, health, 
@export var inventory_data : Resource #mods in inventory
@export var button_data : Array[TowerButtonData]  = [null] #mods in tower button slots
@export var tower_data : Array[TowerBaseData] = [null]
