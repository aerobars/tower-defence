class_name BuildTowerButton extends TextureButton

var data : Dictionary : get = get_tower_mods

func get_tower_mods() -> Dictionary:
	var dict : Dictionary
	var has_wep := false
	var has_aura := false
	var aura_tower := false
	
	#adds mods to data Dictionary and checks if it is an aura tower
	for child in get_children():
		if child.is_class("StaticBody2D"):
			dict[child] = child.data
			if not has_wep and dict[child] != null:
				if child.data.mod_class == child.data.ModType.WEAPON:
					has_wep = true
				elif child.data.mod_class == child.data.ModType.AURA:
					has_aura = true
	
	if has_aura and not has_wep:
		aura_tower = true
	
	return {
		"aura_tower": aura_tower,
		"mods": dict
		}

#func aura_check() -> bool:
	
