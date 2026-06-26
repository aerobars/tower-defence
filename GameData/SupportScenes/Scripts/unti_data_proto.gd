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

func recalculate_stats() -> void:
	pass
