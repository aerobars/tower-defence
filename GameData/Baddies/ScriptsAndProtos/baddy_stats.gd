class_name BaddyStats extends Resource

signal health_depleted
signal health_changed(current_health: int, max_health: int)

@export_group("Baddy Info")
@export var name : String
@export_multiline var description : String
@export var texture : Texture2D

@export_group("Spawn Data", "spawn")
@export var spawn_per_wave: int = 1
@export var spawn_interval: float = 0.5

##Baddy Stats
const BADDY_BUFFABLE_STATS = [ #values to line up with AllBuffableStats enum values
	AllBuffableStats.BuffableStats.DAMAGE,
	AllBuffableStats.BuffableStats.DEFENCE,
	AllBuffableStats.BuffableStats.MAX_HEALTH,
	AllBuffableStats.BuffableStats.MOVE_SPEED
]


const BASE_LEVEL_XP : float = 100.0

@export_group("Base Stats", "base")
@export var base_max_health : float = 50
@export var base_damage : float = 1
@export var base_defence : float = 5
@export var base_move_speed : float = 150
@export var base_aura_aoe : float = 0.0
@export var defence_tag : AllDamageTags.BaddyArmorTags = AllDamageTags.BaddyArmorTags.UNARMORED

@export var experience : int = 0: set = _on_experience_set
var level_ratio : float :
	get:
		return 1 + (GameData.current_wave - 1)/10.0

var level : int:
	get(): return floor(max(1.0, sqrt(experience/BASE_LEVEL_XP) + 0.5))
var current_max_health : float
var current_damage : float :
	set(value):
		current_damage = max(value, 1)
var current_defence : float
var current_move_speed : float

var health : float = 0 : set = _on_health_set

@export var initial_buffs : Array[Buff]
var active_buffs: Dictionary[Buff, BuffInstance]
var buff_owner : Node2D

##Stats Setup and Adjustment
func _init() -> void:
	setup_stats.call_deferred()

func setup_stats() -> void:
	recalculate_stats()
	health = current_max_health

func add_buff(buff: Buff, duration : float = buff.buff_duration, amt : int = 1) -> void:
	for i in amt: #amt allows to apply multiple stacks from a single source
		if not active_buffs.has(buff):
			var new_inst = BuffInstance.new(buff, buff_owner, duration)
			active_buffs[buff] = new_inst
		var inst = active_buffs[buff]
		inst.stacks = min(inst.stacks + amt, buff.stack_limit)
		inst.time_remaining = buff.buff_duration
		recalculate_stats()

func remove_buff(buff: Buff, _amt = 1) -> void:
	active_buffs.erase(buff)
	recalculate_stats()

func recalculate_stats() -> void:
	var stat_multipliers: Dictionary = {} #Amt to multiply stats by
	var stat_addends: Dictionary = {} #Amt to add to stats
	for buff in active_buffs.keys():
		if buff is StatBuff:
			var inst = active_buffs[buff]
			var stat_name: String = AllBuffableStats.BuffableStats.keys()[buff.stat].to_lower()
			match buff.buff_type:
				StatBuff.BuffType.ADD:
					if not stat_addends.has(stat_name):
						stat_addends[stat_name] = 0.0
					stat_addends[stat_name] += buff.buff_amount * inst.stacks
				StatBuff.BuffType.MULTIPLY:
					if not stat_multipliers.has(stat_name):
						stat_multipliers[stat_name] = 1.0
					stat_multipliers[stat_name] += buff.buff_amount * inst.stacks
					stat_multipliers[stat_name] = max(stat_multipliers[stat_name], 0)
	
	#var stat_sample_pos: float = level
	current_max_health = base_max_health * level_ratio
	current_damage = base_damage #don't scale base damage
	current_defence = base_defence * level_ratio
	current_move_speed = base_move_speed * level_ratio
	
	#addends first so it benefits from multipliers
	for stat_name in stat_addends:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])
	
	for stat_name in stat_multipliers:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])
	current_move_speed = clamp(current_move_speed, 50, 500) #don't use setter for this for stun MS
	
	for buff in active_buffs.keys():
		if buff is AbsoluteBuff:
			var stat_name: String = AllBuffableStats.BuffableStats.keys()[buff.stat].to_lower()
			var cur_property_name: String = str("current_" + stat_name)
			set(cur_property_name, buff.buff_amount)

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
