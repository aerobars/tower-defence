class_name BaddyStats extends Resource

signal health_depleted
signal health_changed(current_health: int, max_health: int)

enum BaddyBuffableStats {
	MAX_HEALTH,
	DAMAGE,
	DEFENCE,
	MOVE_SPEED
}

const BASE_LEVEL_XP : float = 100.0

@export var base_max_health : float
@export var base_damage : float
@export var base_defence : float
@export var base_move_speed : float
@export var experience : int = 0: set = _on_experience_set

var level : int:
	get(): return floor(max(1.0, sqrt(experience/BASE_LEVEL_XP) + 0.5))
var current_max_health : float
var current_damage : float
var current_defence : float
var current_move_speed : float

var health : float = 0 : set = _on_health_set

var stat_buffs: Array[StatBuff]

func _init() -> void:
	setup_stats.call_deferred()

func setup_stats() -> void:
	recalculate_stats()
	health = current_max_health

func add_buff(buff: StatBuff) -> void:
	stat_buffs.append(buff)
	recalculate_stats.call_deferred()

func remove_buff(buff: StatBuff) -> void:
	stat_buffs.erase(buff)
	recalculate_stats.call_deferred()

func recalculate_stats() -> void:
	var stat_multipliers: Dictionary = {} #Amt to multiply stats by
	var stat_addends: Dictionary = {} #Amt to add to stats
	for buff in stat_buffs:
		var stat_name: String = BaddyBuffableStats.keys()[buff.stat].to_lower()
		match buff.buff_type:
			StatBuff.BuffType.ADD:
				if not stat_addends.has(stat_name):
					stat_addends[stat_name] = 0.0
				stat_addends[stat_name] += buff.buff_amount
			StatBuff.BuffType.MULTIPLY:
				if not stat_multipliers.has(stat_name):
					stat_multipliers[stat_name] = 1.0
				stat_multipliers[stat_name] += buff.buff_amount
	
	#var stat_sample_pos: float = level
	current_max_health = base_max_health
	current_damage = base_damage 
	current_defence = base_defence
	current_move_speed = base_move_speed
	
	#addends first so it benefits from multipliers
	for stat_name in stat_addends:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])

	for stat_name in stat_multipliers:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])

func _on_health_set(new_value: float) -> void:
	health = clamp(new_value, 0, current_max_health)
	health_changed.emit(health, current_max_health)
	if health <= 0:
		health_depleted.emit()

func _on_experience_set(new_value: int) -> void:
	var old_level : int = level
	experience = new_value
	if not old_level == level:
		recalculate_stats()
