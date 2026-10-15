class_name ValidatorModData extends ValidatorProto


func data_check(mod: ModPrototype) -> void:
	var filepath = mod.resource_path.get_file()
	var valid_class := false
	match mod.mod_class:
		mod.ModClass.AURA:
			valid_class =  filepath.left(4) == "aura"
			if valid_class and mod.buff_data == null:
				validation_results.errors_update("Missing Buff Data for " + data_name)
		mod.ModClass.POWER:
			valid_class = filepath.left(3) == "pwr"
			if valid_class:
				for i in mod.base_power_levels.size():
					if mod.base_power_levels[i] <= 0:
						validation_results.warnings_update(data_name + " at level " + str(i) + " is " + str(mod.base_power_levels[i]))
		mod.ModClass.WEAPON:
			valid_class = filepath.left(3) == "wep"
			if valid_class:
				for i in mod.base_damage_levels.size():
					if mod.base_damage_levels[i] <= 0:
						validation_results.warnings_update(data_name + " at level " + str(i) + " is " + str(mod.base_power_levels[i]))
	if not valid_class:
		validation_results.errors_update("Invalid mod class for " + data_name)
