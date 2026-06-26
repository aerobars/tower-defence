class_name BuffStat extends Buff

enum BuffType {
	NONE, ##0 
	ADD, ##1
	MULTIPLY, ##2
	ABS ##3
	}

##AOE = 1, ATTACK_SPEED = 2, CRIT_CHANCE = 4, DAMAGE = 8, DEFENCE = 16, MAX_HEALTH = 32, MOVE_SPEED = 64
@export var stat: GlobalEnums.BuffableStats
##None = 0, Add = 1, Multiply = 2, Absolute = 3
@export var buff_type: BuffType

func _init() -> void:
	var texture : Texture2D
	match stat:
		GlobalEnums.BuffableStats.DAMAGE:
			texture = set_image(GameData.ICON_DAMAGE_COORDS)
		GlobalEnums.BuffableStats.DEFENCE:
			texture = set_image(GameData.ICON_DEFENCE_COORDS)
		GlobalEnums.BuffableStats.MAX_HEALTH:
			texture = set_image(GameData.ICON_HEALTH_COORDS)
		GlobalEnums.BuffableStats.MOVE_SPEED:
			texture = set_image(GameData.ICON_MOVE_SPEED_COORDS)
	if texture != null:
		info_display_icon = texture

func set_image(atlas_region: Rect2) -> Texture2D:
	var new_atlas = AtlasTexture.new()
	new_atlas.atlas = GameData.ICON_ATLAS
	new_atlas.region = atlas_region
	return new_atlas
	
