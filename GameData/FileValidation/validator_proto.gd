@abstract
class_name ValidatorProto extends RefCounted

var validation_results : ValidatorResult
var data_name : String

#errors, check if name is filled out, name prefix and class mismatch, aura mod with no buff

#warnings, power mod with 0 or negative power value, missing icon or description, 
#weapon mod with 0 dmg attack

func validate(data: UnitDataPrototype) -> ValidatorResult:
	data_name = data.resource_path.get_file()
	validation_results = ValidatorResult.new()
	if data.info_name == "":
		validation_results.errors_update("Missing info_name for " + data_name)
	if data.info_texture == null:
		validation_results.errors_update("Missing texture for " + data_name)
	if data.info_description == "":
		validation_results.warnings_update("No description for " + data_name)
	data_check(data)
	return validation_results

@abstract func data_check(data) -> void
