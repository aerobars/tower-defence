class_name SaveDataRun extends Resource

##Run Data
@export var previous_wave : Array = []
@export var current_wave : int = 0
@export var current_act : int = 0

@export var current_player_health : int
@export var character : String = "Tester"

@export var run_data : Resource #run seed, wave/level count
@export var inventory_data : Resource #mods in inventory
@export var button_data : Resource #mods in tower button slots
@export var player_data : Resource #cash, health, 
