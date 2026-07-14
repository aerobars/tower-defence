##Data Stored for Saved Game that is specific to each tower,
##i.e. can't be retrieved from connected Button/TowerBuildData
class_name TowerBaseData extends Resource

var position : Vector2
var rotation : float
var connected_button_id : int
var level : int = 0
var tower_shape : Array = []
#var build_data : Dictionary = {
#		"aura_tower": false,
#		"mods": {},
#		"power_buffs": {},
#		}

func _init(
	_tower_shape: Array,
	_connected_button_id: int
) -> void:
	tower_shape = _tower_shape
	connected_button_id = _connected_button_id
