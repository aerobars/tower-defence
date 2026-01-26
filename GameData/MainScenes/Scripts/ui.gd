extends CanvasLayer


@export var hp_bar : TextureProgressBar
@export var hp_text : Label
@export var cash_display : Label
@export var game_message : Label
const GAME_MESSAGE_A_VALUE = 0.78
@onready var texture : CompressedTexture2D = preload("res://Assets/UI/range_overlay.png")
@onready var tower : PackedScene = preload("res://GameData/Towers/tower_base.tscn")

## Tower Preview
func set_tower_preview(_tower_type: String, mouse_pos: Vector2, dict: Dictionary) -> void: #runs via GameScenes initiate_build_mod func
	var drag_tower = tower.instantiate()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color("GREEN")
	
	var control := Control.new()
	var range_texture : Sprite2D

	for key in dict["mods"]: #adds range indictator to auras and weapons
		if dict["mods"][key] != null:
			if (dict["mods"][key].mod_class == dict["mods"][key].ModClass.AURA) or dict["mods"][key].mod_class == dict["mods"][key].ModClass.WEAPON:
				range_texture = Sprite2D.new()
				#range_texture.position = Vector2(32,32) #position needed if range is offest from tower
				var scaling: float = dict["mods"][key].current_range / 300.0
				range_texture.scale = Vector2(scaling, scaling)
				range_texture.texture = texture
				if dict["mods"][key].mod_class == dict["mods"][key].ModClass.WEAPON:
					range_texture.modulate = Color("CRIMSON")
				elif dict["aura_tower"]:
					range_texture.modulate = Color("BLUE")
				control.add_child(range_texture, true)
			#add mod texture

	control.add_child(drag_tower, true)
	control.set_position(mouse_pos)
	control.set_name("TowerPreview")
	add_child(control, true)
	move_child($TowerPreview, 0)

func update_tower_preview(new_pos, color) -> void: #runs via GameScene's process func
	$TowerPreview.set_position(new_pos)
	if $TowerPreview/DragTower.modulate != Color(color):
		$TowerPreview/DragTower.modulate = Color(color)
		#$TowerPreview/Sprite2D.modulate = Color(color)

## UI
func update_health_bar(cur_health: int, max_health: int) -> void:
	var hp_bar_tween := hp_bar.create_tween()
	hp_bar_tween.tween_property(hp_bar, "value", cur_health, 0.1)
	hp_text.text = str(max(cur_health, 0)) + "/" + str(max_health)
	if cur_health >= 60:
		hp_bar.set_tint_progress("00a800")#Green
	elif cur_health >= 25:
		hp_bar.set_tint_progress("c77200")#Orange
	else:
		hp_bar.set_tint_progress("ff0000")#Red

func update_cash_display(amount: int) -> void:
	cash_display.text = str(amount)

func update_game_message(message : String, display_time : float = 3.0, fade_time : float = 0.0, font_size : int = 25) -> void:
	game_message.modulate.a = GAME_MESSAGE_A_VALUE
	game_message.add_theme_font_size_override("font_size", font_size)
	game_message.text = message
	game_message.visible = true
	await(get_tree().create_timer(display_time - fade_time, false)).timeout
	await game_message.create_tween().tween_property(game_message, "modulate:a", 0.0, fade_time).finished
	game_message.visible = false

func end_game(_result) -> void:
	pass
