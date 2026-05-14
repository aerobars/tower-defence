class_name BuffDisplayContainer extends HBoxContainer

const BUFF_DISPLAY_SCENE = preload("res://GameData/SupportScenes/buff_display.tscn")

func update_display(buff: Buff, buff_stacks: int = 1) -> void:
	for child in get_children(): #check if mod exists in inventory and increment
		if child.info_name == buff.info_name:
			child.update_stacks(buff_stacks)
			return
	var new_buff = BUFF_DISPLAY_SCENE.instantiate()
	new_buff.setup(buff.info_name, buff.info_display_icon, buff_stacks)
	add_child(new_buff)

func remove_buff(buff: Buff) -> void:
	for child in get_children(): #check if mod exists in inventory and increment
		if child.info_name == buff.info_name:
			child.queue_free()
