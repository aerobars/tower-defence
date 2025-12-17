class_name TowerModPrototype extends Node2D

signal power_check

var data : TowerMod
var mod_slot_ref : StaticBody2D

var target_array : Array
var target
var aura_targets : Array
var reloaded := true
var powered : bool


func _ready():
	$Range.global_position = get_parent().global_position
	if data != null:
		update_mod()
	for body in $Range.get_overlapping_bodies():
		_on_range_body_entered(body)


##Mod Updates
func update_mod() -> void:
	if data.mod_class != data.ModType.POWER:
		$Range/CollisionShape2D.get_shape().radius = 0.5 * data.current_range
	$Turret.texture = data.texture
	power_check.emit()
	if data.mod_class == data.ModType.AURA or data.mod_class == data.ModType.WEAPON:
		add_to_group("turret")
	else:
		remove_from_group("turret")

func mod_slot_updated(mod_slot : StaticBody2D, mod_slot_data : TowerMod) -> void:
	if mod_slot == mod_slot_ref:
		if data != null and data.mod_class == data.ModType.AURA:
			for body in aura_targets:
				clear_buffs(body)
		data = mod_slot_data
		update_mod()


##In Game Function

func _physics_process(_delta: float) -> void:
	if data != null and get_parent().is_powered:
		if target_array.size() != 0 and reloaded:
			if data.mod_class == data.ModType.AURA and data.offensive_aura:
				for i in target_array:
					target = i
					fire()
			elif data.mod_class == data.ModType.WEAPON:
				select_target()
				if not $AnimationPlayer.is_playing():
					turn()
				fire()
		else:
			target = null

##Weapon Function

func select_target():
	var target_progress_array := []
	for i in target_array:
		target_progress_array.append(i.progress)
	var max_progress = target_progress_array.max()
	var target_index = target_progress_array.find(max_progress)
	target = target_array[target_index]

func turn():
	$Turret.look_at(target.position)

func fire():
	reloaded = false
	match data.mod_class: 
		data.ModType.WEAPON: 
			if data.projectile_tag == data.ProjectileType.PROJECTILE:
				fire_projectile()
			elif data.projectile_tag == data.ProjectileType.INSTANT:
				fire_gun()
			target.on_hit(data.current_damage, data.dot_buffs)
		data.ModType.AURA:
			apply_buff(target)
	await(get_tree().create_timer(data.current_attack_speed, false).timeout)
	reloaded = true

func fire_projectile():
	pass

func fire_gun():
	$AnimationPlayer.play("fire")

func _on_range_body_entered(body) -> void:
	if body.is_in_group("baddies"):
		target_array.append(body.get_parent())
	elif data != null and data.mod_class == data.ModType.AURA and body.is_in_group("turret"):
		if data.offensive_aura and get_parent().aura_tower:
			pass
		else:
			aura_targets.append(body)
			apply_buff(body)

func _on_range_body_exited(body) -> void:
	if body.is_in_group("baddies"):
		target_array.erase(body.get_parent())
	elif data != null and data.mod_class == data.ModType.AURA and body.is_in_group("turret"):
		clear_buffs(body)
		aura_targets.erase(body)

func apply_buff(body) -> void:
	body.data.add_buff(data.buff_data.duplicate(true))

func clear_buffs(body) -> void:
	body.data.remove_buff(data.buff_data)
