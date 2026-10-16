class_name AttackInfo extends RefCounted

var damage_amount : float
var damage_tags : int
var crit_status : bool
var onhit_effects : Array[Buff]
var mod_level : int

func _init(_dmg_calc: Array, _onhits: Array[Buff] = [], _level: int = 0) -> void:
	damage_amount = _dmg_calc[0]
	damage_tags = _dmg_calc[1]
	crit_status = _dmg_calc[2]
	onhit_effects = _onhits
	mod_level = _level
