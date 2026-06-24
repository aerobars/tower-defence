class_name EffectDisplayContainer extends HBoxContainer

const EFFECT_DISPLAY_SCENE = preload("res://GameData/SupportScenes/Scenes/effect_display.tscn")

func update_display(effect, effect_stacks: int = 1) -> void:
	for child in get_children(): #check if mod exists in inventory and increment
		if child.info_name == effect.info_name:
			child.update_stacks(effect_stacks)
			return
	var new_effect = EFFECT_DISPLAY_SCENE.instantiate()
	new_effect.setup(effect.info_name, effect.info_display_icon, effect_stacks)
	add_child(new_effect)

func remove_buff(effect) -> void:
	for child in get_children(): #check if mod exists in inventory and increment
		if child.info_name == effect.info_name:
			child.queue_free()
