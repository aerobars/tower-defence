class_name StatModifier extends Resource

enum BuffModificationType {
	ADD, ##0
	MULTIPLY, ##1
	ABS ##2
	}

@export var stat : GlobalEnums.BuffableStats
@export var modification_type : BuffModificationType
##Behaves as either flat amount for ADD, or percentage increase for MULTIPLY
@export var modification_amount : Array[float] = [0, 0, 0, 0, 0]
