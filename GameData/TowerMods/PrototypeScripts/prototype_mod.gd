@abstract
class_name PrototypeMod extends Resource

enum ModClass { AURA, POWER, WEAPON }

#stats for all mod types
var level : int #first level will be 0 after setup_stats to line up with arrays
@export var base_power_levels : Array[int] = [0, 0, 0, 0, 0]
@export var base_range_levels : Array[float] = [26, 26, 26, 26, 26] #range is radius of range circle #default is 1/2 turret base
var current_power : int
var current_range : float
@export var mod_class : ModClass

@export var name : String
@export_multiline var description : String
@export var texture : Texture2D
var class_string : String: 
	get: 
		return ModClass.keys()[ModClass.values().find(mod_class)]


var stat_buffs : Array[StatBuff]
var dot_buffs : Array[DotBuff]

func _init() -> void:
	setup_stats.call_deferred()

func setup_stats(new_level : int = 0) -> void:
	level = new_level
	recalculate_buffs()

func add_buff(buff: Buff, _buff_owner) -> void:
	if buff is DotBuff:
		dot_buffs.append(buff)
	if buff is StatBuff:
		stat_buffs.append(buff)
		recalculate_buffs.call_deferred()

func remove_buff(buff: Buff) -> void:
	if buff is DotBuff:
		dot_buffs.erase(buff)
	if buff is StatBuff:
		stat_buffs.erase(buff)
		recalculate_stats.call_deferred()

func recalculate_buffs() -> void:
	var stat_multipliers: Dictionary = {} #Amt to multiply stats by
	var stat_addends: Dictionary = {} #Amt to add to stats
	for buff in stat_buffs:
		if buff_check(buff.stat):
			var stat_name: String = AllBuffableStats.BuffableStats.keys()[buff.stat].to_lower()
			match buff.buff_type:
				StatBuff.BuffType.ADD:
					if not stat_addends.has(stat_name):
						stat_addends[stat_name] = 0.0
					stat_addends[stat_name] += buff.buff_amount
				StatBuff.BuffType.MULTIPLY:
					if not stat_multipliers.has(stat_name):
						stat_multipliers[stat_name] = 1.0
					stat_multipliers[stat_name] += buff.buff_amount
	recalculate_stats(stat_addends, stat_multipliers)

@abstract
func buff_check(buff_stat) -> bool

@abstract
func recalculate_stats(_thing1, _thing2) -> void
