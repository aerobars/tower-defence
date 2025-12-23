extends CanvasLayer


@export var hp_bar : TextureProgressBar
@export var hp_text : Label
@export var cash_display : Label
@onready var texture := preload("res://Assets/UI/range_overlay.png")
@onready var tower = preload("res://GameData/Towers/tower_base.tscn")

#runs via GameScenes initiate_build_mod func
func set_tower_preview(_tower_type: String, mouse_pos: Vector2, dict: Dictionary) -> void:
	var drag_tower = tower.instantiate()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color("GREEN")
	
	var control := Control.new()
	var range_texture : Sprite2D

	#adds range indictator to auras and weapons
	for key in dict["mods"]:
		if dict["mods"][key] != null:
			if (dict["mods"][key].mod_class == dict["mods"][key].ModType.AURA) or dict["mods"][key].mod_class == dict["mods"][key].ModType.WEAPON:
				range_texture = Sprite2D.new()
				#position needed if range is offest from tower
				#range_texture.position = Vector2(32,32)
				var scaling: float = dict["mods"][key].current_range / 600.0
				range_texture.scale = Vector2(scaling, scaling)
				range_texture.texture = texture
				if dict["mods"][key].mod_class == dict["mods"][key].ModType.WEAPON:
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

#runs via GameScene's process func
func update_tower_preview(new_pos, color):
	$TowerPreview.set_position(new_pos)
	if $TowerPreview/DragTower.modulate != Color(color):
		$TowerPreview/DragTower.modulate = Color(color)
		#$TowerPreview/Sprite2D.modulate = Color(color)


## Gameplay Functions

func update_health_bar(cur_health, max_health):
	var hp_bar_tween := $HUD/InfoBar/InfoContainer/HealthBar.create_tween()
	hp_bar_tween.tween_property(hp_bar, "value", cur_health, 0.1)
	hp_text.text = str(cur_health) + "/" + str(max_health)
	if cur_health >= 60:
		hp_bar.set_tint_progress("00a800")#Green
	elif cur_health >= 25:
		hp_bar.set_tint_progress("c77200")#Orange
	else:
		hp_bar.set_tint_progress("ff0000")#Red

func end_game(_result) -> void:
	pass
