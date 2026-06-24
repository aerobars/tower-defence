class_name EffectDisplay extends Control

@export var effect_icon : TextureRect
@export var path_stack_count : Label

const DISPLAY_SIZE : float = 16

var info_name : String

func setup(buff_name: String, img: Texture2D, count: int) -> void:
	info_name = buff_name
	set_image(img)
	update_stacks(count)

func set_image(img: Texture2D) -> void:
	effect_icon.texture = img
	effect_icon.scale = Vector2(DISPLAY_SIZE/img.get_width(), DISPLAY_SIZE / img.get_height())

func update_stacks(count: int) -> void:
	if count == 1:
		path_stack_count.visible = false
	else:
		path_stack_count.visible = true
		path_stack_count.text = str(count)
