class_name ValidatorResource extends RefCounted

var data_name : String
var validation_results : ValidatorResult

func validate(filepath: String) -> void:
	var data = load(filepath)
	data_name = data.resource_path.get_file()
	validation_results = ValidatorResult.new()
	if data.info_name == "":
		validation_results.errors_update("Missing info_name for " + data_name)
	if data.info_texture == null:
		validation_results.errors_update("Missing texture for " + data_name)
	if data.info_description == "":
		validation_results.warnings_update("No description for " + data_name)
	if data is ModPrototype:
		mod_validation(data)
	if data is BaddyStats:
		baddy_validation(data)
	if not validation_results.is_valid():
		print(validation_results.errors.size(), " errors for ", data_name)
		validation_results.display_errors()
	if validation_results.has_warnings():
		print(validation_results.warnings.size(), " warnings for ", data_name)
		validation_results.display_warnings()

##errors: aura with no buff data
##warnings, power with <= 0 power value, weapon with <= 0 dmg attack
func mod_validation(mod: ModPrototype) -> void:
	var valid_class := false
	match mod.mod_class:
		mod.ModClass.AURA:
			valid_class =  data_name.left(4) == "aura"
			if valid_class and mod.buff_data == null:
				validation_results.errors_update("Missing Buff Data for " + data_name)
		mod.ModClass.POWER:
			valid_class = data_name.left(3) == "pwr"
			if valid_class:
				for i in mod.base_power_levels.size():
					if mod.base_power_levels[i] <= 0:
						validation_results.warnings_update(data_name + " at level " + str(i) + " is " + str(mod.base_power_levels[i]))
		mod.ModClass.WEAPON:
			valid_class = data_name.left(3) == "wep"
			if valid_class:
				for i in mod.base_damage_levels.size():
					if mod.base_damage_levels[i] <= 0:
						validation_results.warnings_update(data_name + " at level " + str(i) + " is " + str(mod.base_power_levels[i]))
	if not valid_class:
		validation_results.errors_update("Invalid mod class for " + data_name)

##errors: movespeed <= 0, damage <= 0, 
func baddy_validation(_baddy: BaddyStats) -> void:
	pass
#errors, check if name is filled out, name prefix and class mismatch, aura mod with no buff

#warnings, power mod with 0 or negative power value, missing icon or description, 
#weapon mod with 0 dmg attack
