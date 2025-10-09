class_name BuildTowerButton extends TextureButton

var data : Dictionary[StaticBody2D, TowerMod] : get = get_tower_mods

func get_tower_mods() -> Dictionary[StaticBody2D, TowerMod]:
	var dict : Dictionary[StaticBody2D, TowerMod]
	for child in get_children():
		if child.is_class("StaticBody2D"):
			dict.set(child, child.data)
	print(dict)
	return dict
