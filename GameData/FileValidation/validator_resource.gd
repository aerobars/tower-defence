class_name ValidatorResource extends RefCounted

#func _init(resource_filepath: String) -> void:
#	var resource = load(resource_filepath)
#	validate(resource)

static func validate(resource_filepath: String) -> void:
	var resource = load(resource_filepath)
	var valid_check
	if resource is ModPrototype:
		valid_check = ValidatorModData.new()
		valid_check.validate(resource)
	if resource is BaddyStats:
		#valid_check = ValidationBaddy.new(resource)
		pass
		
