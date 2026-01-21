class_name TowerMod extends Node2D

signal power_check
signal mod_updated(mod: StaticBody2D)

var data : PrototypeMod
var mod_slot_ref : StaticBody2D

var baddies_in_range : Array
var targets : Array
var aura_targets : Array
var attack_timer : float = 0.0


func _ready():
	$Range.global_position = get_parent().global_position
	if data != null:
		update_mod()
	for body in $Range.get_overlapping_bodies():
		_on_range_body_entered(body)
	mod_updated.connect(GameData.mod_updated)
	GameData.mod_update_check.connect(_on_mod_updated)


##Mod Updates

func update_mod() -> void:
	if data == null:
		$Range/CollisionShape2D.get_shape().radius = 0.0
		$Turret.texture = null
		remove_from_group("turret")
		power_check.emit()
		return
	elif data.mod_class != data.ModClass.POWER:
		$Range/CollisionShape2D.get_shape().radius = data.current_range
		add_to_group("turret")
	else:
		remove_from_group("turret")
	$Turret.texture = data.texture
	power_check.emit()
	mod_updated.emit(self)

func mod_slot_updated(mod_slot : StaticBody2D, mod_slot_data : PrototypeMod) -> void:
	if mod_slot == mod_slot_ref:
		if data != null and data.mod_class == data.ModClass.AURA:
			for body in aura_targets:
				clear_buffs(body)
		data = mod_slot_data
		update_mod()

func _on_mod_updated(updated_mod: StaticBody2D) -> void:
	if updated_mod in $Range.get_overlapping_bodies() and updated_mod != self:
		_on_range_body_entered(updated_mod)

##In Game Function

func _process(delta: float) -> void:
	if data != null and get_parent().is_powered:
		if (data.mod_class == data.ModClass.AURA and data.offensive_aura and get_parent().aura_tower) or data.mod_class == data.ModClass.WEAPON:
			attack_timer += delta
			if attack_timer >= data.current_attack_speed:
				attack_timer = 0.0
				if baddies_in_range.size() != 0:
					match data.mod_class:
						data.ModClass.AURA:
							for baddy in baddies_in_range:
								fire(baddy)
						data.ModClass.WEAPON:
							targets = select_targets()
							if not $AnimationPlayer.is_playing():
								turn()
							for i in data.current_multitarget:
								if i < targets.size():
									fire(targets[i])
				else:
					targets = [null]

func _on_range_body_entered(body) -> void:
	if body.is_in_group("baddies"):
		baddies_in_range.append(body.get_parent())
	elif data != null and data.mod_class == data.ModClass.AURA and body.is_in_group("turret"):
		if data.offensive_aura and get_parent().aura_tower:
			print('aura tower')
			pass #nothing gets added to aura_targets for offensive auras in aura mode
		else:
			print('not aura tower')
			aura_targets.append(body)
			apply_buff(body)

func _on_range_body_exited(body) -> void:
	if body.is_in_group("baddies"):
		baddies_in_range.erase(body.get_parent())
	elif data != null and data.mod_class == data.ModClass.AURA and body.is_in_group("turret"):
		clear_buffs(body)
		aura_targets.erase(body)

func apply_buff(body) -> void:
	body.data.add_buff(data.buff_data, body)

func clear_buffs(body) -> void:
	body.data.remove_buff(data.buff_data)

##Weapon Function

func select_targets() -> Array:
	var target_progress_array := baddies_in_range
	target_progress_array.sort_custom(func(a, b): return a.progress > b.progress)
	return target_progress_array


func turn():
	$Turret.look_at(targets[0].position)

func fire(target):
	match data.mod_class: 
		data.ModClass.WEAPON: 
			if data.projectile_tag == data.ProjectileTag.PROJECTILE:
				fire_projectile()
			elif data.projectile_tag == data.ProjectileTag.INSTANT:
				fire_gun()
			if data.current_aoe > 0:
				var aoe = setup_aoe()
				aoe.global_position = target.position
				await get_tree().physics_frame
				for body in aoe.get_overlapping_bodies():
					if body.is_in_group("baddies"):
						body.get_parent().on_hit(data.calculate_damage(), data.dot_buffs)
				aoe.queue_free()
			else:
				target.on_hit(data.calculate_damage(), data.dot_buffs)
		data.ModClass.AURA:
			apply_buff(target)

func fire_projectile() -> void:
	pass

func fire_gun() -> void:
	$AnimationPlayer.play("fire")

func setup_aoe() -> Area2D:
	var aoe = Area2D.new()
	var aoe_range = CollisionShape2D.new()
	aoe_range.shape = CircleShape2D.new()
	aoe_range.get_shape().radius = data.current_aoe
	aoe.add_child(aoe_range)
	add_child(aoe)
	return aoe
