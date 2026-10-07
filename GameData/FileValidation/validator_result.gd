class_name ValidatorResult extends RefCounted

var errors : Array[String] = []
var warnings : Array[String] =[]

func is_valid() -> bool:
	return errors.is_empty()

func errors_update(message: String) -> void:
	errors.append(message)

func warnings_update(message: String) -> void:
	warnings.append(message)
