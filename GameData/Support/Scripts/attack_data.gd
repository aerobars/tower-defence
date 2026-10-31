class_name AttackData extends RefCounted

var damage_amount: float
var damage_tags: int
var crit_multi: float
var crit_status: bool
var mod_level: int

func _init(
	_dmg: float, 
	_dmg_tags: int, 
	_level: int = 0, 
	_crit_chance: float = 0.0, 
	_crit_multi: float = 0.0, 
	) -> void:
	
	damage_tags = _dmg_tags
	mod_level = _level
	crit_multi = _crit_multi
	
	if _crit_chance > randf():
		damage_amount = _dmg * _crit_multi
		crit_status = true
	else:
		damage_amount = _dmg
		crit_status = false
