extends Node

func display_number(value: int, position: Vector2, damage_source, is_critical: bool = false) -> void:
	var number = Label.new()
	number.global_position = position
	number.text = str(value)
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var colour = match_damage_source(damage_source)
	if is_critical:
		colour = GameData.critical_colour
	if value == 0:
		colour = "#FFF8"
	
	number.label_settings.font_color = colour
	number.label_settings.font_size = 18
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 1
	
	call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	##Animation
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	number.queue_free()

func match_damage_source(damage_source) -> Color:
	match AllDamageTags.DamageTag.keys()[damage_source]:
		"BLEED":
			return "#FFF"
		"BLUNT": #Blunt
			return "#FFF"
		"BURN": #Burn
			return GameData.burn_colour #Orange
		"PIERCE": #Pierce
			return "#FFF"
		"POISON": #Poison
			return GameData.poison_colour #Dark Green
		"SHOCK": #Shock
			return GameData.shock_colour
		_:
			return "#FFF"
