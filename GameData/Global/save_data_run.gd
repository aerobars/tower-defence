class_name SaveDataRun extends Resource

## Run Data

var new_game : bool = true
var init_btn_count : int = 2
var init_tower_shapes : Array[Array] = [[Vector2i(0, -1), Vector2i(0, 0)] , [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]]
var init_inventory = load("res://GameData/UIScenes/Inventory/player_inventory.tres")


## Act Related

@export var current_act : int = 0
@export var current_wave : int = 0
@export var previous_wave : Array = []
@export var wave_reward_total : int = 2

## Player Related

@export var character : String = "Builder"
##Initial value is starting cash for new games
@export var current_cash : int = 50
@export var current_player_health : int = 100

## Mod / Tower Related

##Mods in Inventory
@export var inventory_data : InventoryData 
##Mods in tower button slots
@export var button_data : Array[TowerButtonData] = []
@export var button_count : int 
@export var tower_data : Array[TowerBaseData] = []
@export var tower_shapes : Array[Array]

#currently unused
@export var run_data : Resource #run seed, wave/level count
@export var player_data : Resource #cash, health, 
