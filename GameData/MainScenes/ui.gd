extends CanvasLayer

@onready var hp_bar := $HUD/InfoBar/InfoContainer/HealthBar
@onready var hp_bar_tween := $HUD/InfoBar/InfoContainer/HealthBar.create_tween()
@onready var texture := preload("res://Assets/UI/range_overlay.png")

#runs via GameScenes initiate_build_mod func
func set_tower_preview(tower_type: String, mouse_pos: Vector2, dict: Dictionary[StaticBody2D,TowerMod]) -> void:
	var drag_tower = load("res://GameData/Towers/" + tower_type + ".tscn").instantiate()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color("ad54ff")
	
	var control := Control.new()
	var range_texture: Sprite2D
	var mod_texture: Sprite2D
	for key in dict:
		if dict[key] != null:
			#adds range indictator to auras and weapons
			if (dict[key].mod_class == dict[key].ModType.AURA and dict[key].is_aura) or dict[key].mod_class == dict[key].ModType.WEAPON:
				range_texture = Sprite2D.new()
				#position needed if range is offest from tower
				#range_texture.position = Vector2(32,32)
				var scaling: float = dict[key].range / 600.0
				range_texture.scale = Vector2(scaling, scaling)
				range_texture.texture = texture
				if dict[key].mod_class == dict[key].ModType.WEAPON:
					range_texture.modulate = Color("CRIMSON")
				else:
					range_texture.modulate = Color("BLUE")
				control.add_child(range_texture, true)
			#add mod texture
			pass
	
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

##
## Game Control Functions
##

func _on_pause_play_pressed() -> void:
	if get_parent().build_mode:
		get_parent().cancel_build_mode()
	if get_tree().is_paused():
		get_tree().paused = false
	elif get_parent().current_wave == 0:
		get_parent().current_wave = 1
		get_parent().start_next_wave()
	else:
		get_tree().paused = true

func _on_fast_forward_pressed() -> void:
	if get_parent().build_mode:
		get_parent().cancel_build_mode()
	if Engine.get_time_scale() == 2.0:
		Engine.set_time_scale(1.0)
	else:
		Engine.set_time_scale(2.0)

func update_health_bar(base_health):
	hp_bar_tween.tween_property(hp_bar, "value", base_health, 0.1)
	if base_health >= 60:
		hp_bar.set_tint_progress("00a800")#Green
	elif base_health >= 25:
		hp_bar.set_tint_progress("c77200")#Orange
	else:
		hp_bar.set_tint_progress("ff0000")#Red
