@abstract
class_name PrototypeMod extends Resource

enum ModClass { AURA, POWER, WEAPON }

#stats for all mod types
var level : int #first level will be 0 after setup_stats to line up with arrays
@export var base_power_levels : Array[int] = [-1, -1, -1, -1, -1]
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

var buff_owner
var active_buffs: Dictionary[Buff, BuffInstance] = {}
@export var on_hit_effects : Array[Buff]
var net_power : int = 0
var power_surplus_buffs : Dictionary = {"damage" : 1}

func _init() -> void:
	setup_stats.call_deferred()

func setup_stats(new_level : int = 0) -> void:
	level = new_level
	recalculate_stats()

func add_buff(buff: Buff, duration : float = buff.buff_duration, amt : int = 1) -> void:
	if buff is StatBuff:
		for i in amt: #amt allows to apply multiple stacks from a single source
			if not active_buffs.has(buff):
				var new_inst = BuffInstance.new(buff, buff_owner, duration)
				active_buffs[buff] = new_inst
			var inst = active_buffs[buff]
			inst.stacks = min(inst.stacks + amt, buff.stack_limit)
			inst.time_remaining = buff.buff_duration
			recalculate_stats.call_deferred()
	else:
		on_hit_effects.append(buff)

func remove_buff(buff: Buff) -> void:
	if buff is DotBuff:
		on_hit_effects.erase(buff)
	if buff is StatBuff:
		active_buffs.erase(buff)
		recalculate_stats.call_deferred()

func recalculate_stats() -> void:
	var stat_multipliers: Dictionary = {} #Amt to multiply stats by
	var stat_addends: Dictionary = {} #Amt to add to stats
	for buff in active_buffs:
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
	set_current_stats()
	
	#addends first so it benefits from multipliers
	for stat_name in stat_addends:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])
	
	for stat_name in stat_multipliers:
		var cur_property_name: String = str("current_" + stat_name)
	
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])
	for stat_name in power_surplus_buffs.keys():
		if buff_check(stat_name):
			var cur_property_name: String = str("current_" + stat_name)
			set(cur_property_name, get(cur_property_name) * (1 + float(net_power) * float(power_surplus_buffs[stat_name])/10))
	
	for buff in active_buffs.keys():
		if buff is AbsoluteBuff:
			var stat_name: String = AllBuffableStats.BuffableStats.keys()[buff.stat].to_lower()
			var cur_property_name: String = str("current_" + stat_name)
			set(cur_property_name, buff.buff_amount)

@abstract
func buff_check(buff_stat) -> bool

@abstract
func set_current_stats() -> void
