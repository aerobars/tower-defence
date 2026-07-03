class_name BaddyStats extends UnitDataPrototype

signal health_depleted
signal health_changed(current_health: float, max_health: float)


@export_group("Spawn Data", "spawn_")
@export var spawn_per_wave : int = 1
@export var spawn_interval : float = 0.5
@export var spawn_summon : bool = false

##Baddy Stats

##values to line up with BuffableStats enum values
const BUFFABLE_STATS = [ 
	GlobalEnums.BuffableStats.DAMAGE,
	GlobalEnums.BuffableStats.DEFENCE,
	GlobalEnums.BuffableStats.MAX_HEALTH,
	GlobalEnums.BuffableStats.MOVE_SPEED
]
const BASE_LEVEL_XP : float = 100.0

@export_group("Base Stats", "base_")
@export var base_max_health : float = 75
@export var base_damage : float = 1
@export var base_defence : float = 5
@export var base_move_speed : float = 150
@export var base_defence_tag : GlobalEnums.BaddyArmorTags = GlobalEnums.BaddyArmorTags.UNARMORED

var wave_ratio : float :
	get:
		return 1 + (SaveManager.save_data_run.current_wave - 1)/10.0
var current_max_health : float
var current_damage : float :
	set(value):
		current_damage = max(value, 1)
var current_defence : float
var current_move_speed : float

var health : float = 0 : set = _on_health_set

##Buffs and Auras
@export_group("In Game Effects")
@export var innate_abilities : Array[AbilityPrototype]
var active_abilities: Array[AbilityPrototype]

##currently unused
@export var experience : int = 0: set = _on_experience_set
#var level : int = 0 :
#	get(): return floor(max(1.0, sqrt(experience/BASE_LEVEL_XP) + 0.5))

##Stats Setup and Adjustment

func setup_stats(_level: int = 0) -> void:
	super(_level)
	health = current_max_health

##Runtime

#add_buff and remove_buff functions in unit_data_proto
func get_buffable_stats() -> Array[GlobalEnums.BuffableStats]:
	return BUFFABLE_STATS

func defunct_recalculate_stats() -> void:
	var stat_multipliers: Dictionary = {} #Amt to multiply stats by
	var stat_addends: Dictionary = {} #Amt to add to stats
	for buff in active_buffs.keys():
		if buff is BuffStat:
			var inst = active_buffs[buff]
			var stat_name : String = ""
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
							stat_multipliers[stat_name] = max(stat_multipliers[stat_name], 0)
	
	#var stat_sample_pos: float = level
	current_max_health = base_max_health * wave_ratio
	current_damage = base_damage #don't scale base damage
	current_defence = base_defence * wave_ratio
	current_move_speed = base_move_speed * wave_ratio
	
	#addends first so it benefits from multipliers
	for stat_name in stat_addends:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])
	
	for stat_name in stat_multipliers:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])
	current_move_speed = clamp(current_move_speed, 75, 500) #don't use setter for this for stun MS
	
	for buff in active_buffs.keys():
		if buff is BuffStat and buff.buff_type == BuffStat.BuffType.ABS:
			var stat_name: String = GlobalEnums.BuffableStats.keys()[buff.stat].to_lower()
			var cur_property_name: String = str("current_" + stat_name)
			set(cur_property_name, buff.effect_amount)
	
	stats_updated.emit()

func set_current_stats() -> void:
	current_max_health = base_max_health * wave_ratio
	current_damage = base_damage #don't scale base damage
	current_defence = base_defence * wave_ratio
	current_move_speed = base_move_speed * wave_ratio

func _on_health_set(new_value: float) -> void:
	health = clamp(new_value, 0, current_max_health)
	health_changed.emit(health, current_max_health)
	if health == 0:
		health_depleted.emit()

func _on_experience_set(new_value: int) -> void:
	var old_level : int = level
	experience = new_value
	if not old_level == level:
		recalculate_stats()
