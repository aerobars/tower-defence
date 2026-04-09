class_name SaveDataRun extends Resource

##Run Data
var new_game : bool
var init_btn_count : int = 2
var init_slot_counts : Array = [3 , 4]

##Act Related
@export var current_act : int = 0
@export var current_wave : int = 0
@export var previous_wave : Array = []
@export var wave_reward_total : int = 2

##Player Related
@export var character : String = "Builder"
@export var current_cash : int = 50
@export var current_player_health : int = 100

##Mod Related
@export var inventory_data : InventoryData #mods in inventory
@export var button_data : Array[TowerButtonData] = [] #mods in tower button slots
@export var tower_data : Array[TowerBaseData] = []

#currently unused
@export var run_data : Resource #run seed, wave/level count
@export var player_data : Resource #cash, health, 
