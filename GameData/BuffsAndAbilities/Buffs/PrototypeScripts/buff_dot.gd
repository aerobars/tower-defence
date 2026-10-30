class_name BuffDot extends Buff

enum ProcessingMethod {
	TIME, ##0
	POSITION ##1
}

@export_group("DoT Buff Data")
@warning_ignore("enum_variable_without_default")
@export var damage_tag : GlobalEnums.DamageTag
@export var dot_interval : Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0]
@export var buff_process_type : GlobalEnums.ProcessingMethods
