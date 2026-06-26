@abstract
class_name UnitDataPrototype extends Resource

signal update_buff_display(buff: Buff, stacks: int)
signal remove_buff_display(buff: Buff)

@export_group("Unit Info", "info_")
@export var info_name : String
@export_multiline var info_description : String
@export var info_texture : Texture2D

##first level will be 0 after setup_stats to line up with arrays
var level : int = 0 
var buff_owner : UnitScenePrototype
var active_buffs: Dictionary[Buff, BuffInstance] = {}

func _init() -> void:
	setup_stats.call_deferred()

func setup_stats(_level: int = 0) -> void:
	level = _level
	recalculate_stats()

func add_buff(buff: Buff, buff_level : int, amt : int = 1, _buff_source : CollisionObject2D = null) -> void:
	if not active_buffs.has(buff):
		var new_inst = BuffInstance.new(buff, buff_owner, buff_level)
		active_buffs[buff] = new_inst
	var inst = active_buffs[buff]
	inst.stacks = min(inst.stacks + amt, buff.stack_limit[buff_level])
	inst.time_remaining = buff.buff_duration[buff_level]
	update_buff_display.emit(buff, inst.stacks)
	recalculate_stats()

func remove_buff(buff: Buff, _amt = 1) -> void:
	active_buffs.erase(buff)
	remove_buff_display.emit(buff)
	recalculate_stats()

func get_buffable_stats() -> Array[GlobalEnums.BuffableStats]:
	return []

func buff_check(buff_stat) -> bool:
	if buff_stat is String:
		buff_stat = buff_stat.to_upper()
		if not GlobalEnums.BuffableStats.keys().has(buff_stat):
			return false
		buff_stat = GlobalEnums.BuffableStats[buff_stat]
	return get_buffable_stats().has(buff_stat)

func recalculate_stats() -> void:
	var stat_multipliers: Dictionary = {} #Amt to multiply stats by
	var stat_addends: Dictionary = {} #Amt to add to stats
	for buff in active_buffs.keys():
		if buff_check(buff.stat):
			var stat_name : String = ""
			var inst = active_buffs[buff]
			for stat in GlobalEnums.BuffableStats.keys():
				if buff.stat & GlobalEnums.BuffableStats[stat]:
					stat_name = stat.to_lower()
					match buff.buff_type:
						BuffStat.BuffType.ADD:
							if not stat_addends.has(stat_name):
								stat_addends[stat_name] = 0.0
							stat_addends[stat_name] += buff.effect_amount[inst.level] * inst.stacks
						BuffStat.BuffType.MULTIPLY:
							if not stat_multipliers.has(stat_name):
								stat_multipliers[stat_name] = 1.0
							stat_multipliers[stat_name] += buff.effect_amount[inst.level] * inst.stacks
	
	set_current_stats()
	
	#addends first so it benefits from multipliers
	for stat_name in stat_addends:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])
	
	for stat_name in stat_multipliers:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])
	
	if self is PrototypeMod:
		power_buff()
	
	for buff in active_buffs.keys():
		if buff is BuffAbsolute:
			var stat_name: String = GlobalEnums.BuffableStats.keys()[buff.stat].to_lower()
			var cur_property_name: String = str("current_" + stat_name)
			set(cur_property_name, buff.effect_amount[active_buffs[buff].level])

func power_buff() -> void:
	pass

@abstract
func set_current_stats() -> void
