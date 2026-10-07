class_name ValidatorModData extends RefCounted

var validation_results : ValidatorResult

#errors, check if name is filled out, name prefix and class mismatch, aura mod with no buff

#warnings, power mod with 0 or negative power value, missing icon or description, 
#weapon mod with 0 dmg attack

func validation_check(mod: ModPrototype) -> ValidatorResult:
	if mod.info_name == "":
		validation_results.errors_update("Missing mod name")
	if mod.info_texture == null:
		validation_results.errors_update("Missing texture for " + mod.info_name)
	if mod.info_description == "":
		validation_results.warnings_update("No description for " + mod.info_name)
	mod_class_check(mod)
	return validation_results

func mod_class_check(mod: ModPrototype) -> void:
	var filepath = mod.resource_path.get_file()
	var valid_class := false
	match mod.mod_class:
		mod.ModClass.AURA:
			valid_class =  filepath.left(4) == "aura"
			if mod.buff_data == null:
				validation_results.errors_update(mod.info_name + " missing Buff Data")
		mod.ModClass.POWER:
			valid_class = filepath.left(3) == "pwr"
			for i in mod.base_power_levels.size():
				if mod.base_power_levels[i] <= 0:
					validation_results.warnings_update(mod.info_name + " at level " + str(i) + " is " + str(mod.base_power_levels[i]))
		mod.ModClass.WEAPON:
			for i in mod.base_damage_levels.size():
				if mod.base_damage_levels[i] <= 0:
					validation_results.warnings_update(mod.info_name + " at level " + str(i) + " is " + str(mod.base_power_levels[i]))
			valid_class = filepath.left(3) == "wep"
	if not valid_class:
		validation_results.errors_update("Invalid mod class for " + mod.info_name)
