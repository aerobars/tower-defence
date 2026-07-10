##Parent script for BaddyStats and PrototypeMod
@abstract class_name UnitDataPrototype extends Resource

signal update_buff_display(buff: Buff, stacks: int)
signal remove_buff_display(buff: Buff)
signal stats_updated

@export_group("Unit Info", "info_")
@export var info_name : String
@export_multiline var info_description : String
@export var info_texture : Texture2D

##first level will be 0 after setup_stats to line up with arrays
var level : int = 0 
##buff_owner is the unit affected by the buff
var data_owner : UnitScenePrototype
var active_buffs : Dictionary[Buff, BuffInstance] = {}

func setup_stats(_level : int = 0) -> void:
	level = _level
	recalculate_stats()

##buff/data_owner is the unit affected by the buff, buff_source is the unit providing the buff being added
func add_buff(buff : Buff, buff_source : CollisionObject2D, buff_level : int, amt : int = 1) -> void:
	if not active_buffs.has(buff):
		var new_inst = BuffInstance.new(buff, data_owner, buff_source, buff_level)
		active_buffs[buff] = new_inst
	
	var inst = active_buffs[buff]
	
	if not inst.buff_source.has(buff_source):
		inst.buff_source.append(buff_source)
	inst.stacks = min(inst.stacks + amt, buff.buff_stack_limit[buff_level])
	inst.time_remaining = buff.buff_duration[buff_level]
	update_buff_display.emit(buff, inst.stacks)
	recalculate_stats()

func remove_buff(buff : Buff, buff_source : CollisionObject2D, amt : int = 1) -> void:
	var inst = active_buffs[buff]
	
	if buff.buff_persistent_effect: #check whether buff is an aura/persistent effect
		inst.buff_source.erase(buff_source)
	else:
		inst.stacks = max(inst.stacks - amt, 0)
	
	if inst.buff_source.size() == 0 or inst.stacks == 0:
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
		if buff is BuffStat:
			for buff_stat in buff.modifying_stats:
				if buff_check(buff_stat):
					var stat_name : String = ""
					var inst = active_buffs[buff]
					for stat in GlobalEnums.BuffableStats.keys():
						if buff_stat.stat & GlobalEnums.BuffableStats[stat]:
							stat_name = stat.to_lower()
							match buff_stat.modification_type:
								StatModifier.BuffModificationType.ADD:
									if not stat_addends.has(stat_name):
										stat_addends[stat_name] = 0.0
									stat_addends[stat_name] += buff_stat.modification_amount[inst.level] * inst.stacks
								StatModifier.BuffModificationType.MULTIPLY:
									if not stat_multipliers.has(stat_name):
										stat_multipliers[stat_name] = 1.0
									stat_multipliers[stat_name] += buff_stat.modification_amount[inst.level] * inst.stacks
	
	set_current_stats()
	
	#addends first so it benefits from multipliers
	for stat_name in stat_addends:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])
	
	for stat_name in stat_multipliers:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])
	
	if self is BaddyStats:
		clamp_move_speed()
	elif self is ModPrototype:
		power_buff()
	
	for buff in active_buffs.keys():
		if buff is BuffAbsolute:
			var stat_name: String = GlobalEnums.BuffableStats.keys()[buff.stat].to_lower()
			var cur_property_name: String = str("current_" + stat_name)
			set(cur_property_name, buff.effect_amount[active_buffs[buff].level])
	
	stats_updated.emit()

func power_buff() -> void:
	pass

func clamp_move_speed() -> void:
	pass

@abstract
func set_current_stats() -> void
