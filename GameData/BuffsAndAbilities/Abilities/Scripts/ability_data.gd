##Contains data specific around constructing and executing ability functions
class_name AbilityData extends Resource

@export_group("Ability Info", "info_")
@export var info_name : String
@export var info_texture : Texture2D
@export_multiline() var info_description : String

##data for buff that is applied
@export var buff_data: Buff

@export var cooldown : float = 6.0
##Success chance for onhit abilities
@export_range(0.0, 1.0, 0.01) var onhit_success_chance : float = 0.0
##AoE of Aura abilities
@export var aura_aoe : Array[float] 
