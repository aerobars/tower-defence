class_name TowerMod extends Node2D

## Signals
#signal power_check
signal mod_updated(mod: StaticBody2D)

## Tower Setup
var non_aura_radius : float
var data : PrototypeMod
var button_slot_ref : StaticBody2D
@onready var turret := $Turret
@onready var range_aoe := $Range/CollisionShape2D

## Gametime
var baddies_in_range : Array
var targets : Array
var aura_targets : Array
var attack_timer : float = 0.0
var attack_tracker : int


## Initial Setup
func _ready():
	$Range.global_position = get_parent().global_position
	if data != null:
		data.buff_owner = self
	for body in $Range.get_overlapping_bodies():
		_on_range_body_entered(body)
	
	mod_updated.connect(GameData.mod_updated)
	GameData.mod_update_check.connect(_on_mod_updated)
	#above signals allow other mods to be added to auras after they are updated

## Mod Updates
func update_mod(net_power : int = 0) -> void:
	if data == null:
		range_aoe.get_shape().radius = 0.0
		turret.texture = null
		remove_from_group("turret")
		return
	data.net_power = net_power
	data.setup_stats(get_parent().level)
	match data.mod_class:
		0: #Aura
			if get_parent().aura_tower:
				$Range/CollisionShape2D.get_shape().radius = data.current_range
			else:
				$Range/CollisionShape2D.get_shape().radius = non_aura_radius
			add_to_group("turret")
		1: #Power
			$Range/CollisionShape2D.get_shape().radius = non_aura_radius
			remove_from_group("turret")
		2: #Weapon
			$Range/CollisionShape2D.get_shape().radius = data.current_range
			add_to_group("turret")
	turret.texture = data.texture
	mod_updated.emit(self)

#func button_slot_updated(button_slot : StaticBody2D, button_slot_data : PrototypeMod) -> void:
#	if button_slot != button_slot_ref:
#		return
#	if data != null:
#		if data.mod_class == data.ModClass.AURA: 
#			for body in aura_targets: #clears aura effects of old aura before updating
#				clear_buffs(body)
#	if button_slot_data != null:
#		data = button_slot_data.duplicate(true)
#	aura_targets = []
#	update_mod()

func _on_mod_updated(updated_mod: StaticBody2D) -> void: #Connected to GameData, triggers whenever any mod is updated
	if updated_mod == self:
		return
	if updated_mod in $Range.get_overlapping_bodies():
		_on_range_body_entered(updated_mod)


## In-Game Function
func _process(delta: float) -> void:
	if data == null or data is PowerMod: 
		return
	for buff in data.active_buffs.keys(): #.keys for clarity, does the same as data.active_buffs
		data.active_buffs[buff].update(delta)
	if get_parent().net_power < 0:
		return
	attack_timer = clamp(attack_timer + delta, 0, data.current_attack_speed)
	if baddies_in_range.size() > 0:
		targets = select_targets()
		if data.mod_class == data.ModClass.WEAPON:
			if not $AnimationPlayer.is_playing():
				turn()
		if attack_timer >= data.current_attack_speed:
			if data is AuraMod and data.offensive_aura and get_parent().aura_tower:
				for baddy in baddies_in_range:
					apply_buff(baddy)
			elif data is WeaponMod:
				#attack_tracker += 1
				for i in data.current_multitarget:
					if i < targets.size():
						fire(targets[i])
			attack_timer = 0.0
	else:
		targets = [null]

func _on_range_body_entered(body) -> void:
	if data == null or body == self:
		return
	if body.is_in_group("baddies"):
		baddies_in_range.append(body.get_parent())
	elif data.mod_class == data.ModClass.AURA and body.is_in_group("turret"):
		if data.offensive_aura and get_parent().aura_tower:
			return #nothing gets added to aura_targets for offensive auras in aura mode
		else:
			aura_targets.append(body)
			apply_buff(body)

func _on_range_body_exited(body) -> void:
	if data == null:
		return
	if body.is_in_group("baddies"):
		baddies_in_range.erase(body.get_parent())
	elif data.mod_class == data.ModClass.AURA and body.is_in_group("turret"):
		aura_targets.erase(body)
		clear_buffs(body)

func apply_buff(body) -> void:
	if body is TowerMod:
		if data.offensive_aura and data.buff_data is StatBuff:
			body.data.on_hit_effects.append(data.buff_data)
		else:
			body.data.add_buff(data.buff_data)
	elif body is Baddy:
		body.data.add_buff(data.buff_data)

func clear_buffs(body) -> void:
	if body is TowerMod:
		if data.offensive_aura and data.buff_data is StatBuff:
			body.data.on_hit_effects.erase(data.buff_data)
		else:
			body.data.remove_buff(data.buff_data)
	elif body is Baddy:
		body.data.remove_buff(data.buff_data)

## Weapon Function
func select_targets() -> Array:
	var target_progress_array := baddies_in_range
	target_progress_array.sort_custom(func(a, b): return a.progress > b.progress)
	return target_progress_array

func turn():
	$Turret.look_at(targets[0].position)

func fire(target):
	if data.projectile_tag == data.ProjectileTag.INSTANT:
		fire_instant()
	elif data.projectile_tag == data.ProjectileTag.PROJECTILE:
		fire_projectile()
	if data.current_aoe > 0:
		var baddies = await setup_aoe(target.global_position)
		for baddy in baddies:
			baddy.on_hit(data.calculate_damage(), data.on_hit_effects)
	else:
		target.on_hit(data.calculate_damage(), data.on_hit_effects)


func fire_projectile() -> void:
	pass

func fire_instant() -> void:
	$AnimationPlayer.play("fire")

func setup_aoe(target_pos : Vector2) -> Array:
	var aoe = Area2D.new()
	var aoe_range = CollisionShape2D.new()
	var baddies : Array = []
	aoe_range.shape = CircleShape2D.new()
	aoe_range.get_shape().radius = data.current_aoe
	aoe.add_child(aoe_range)
	add_child(aoe)
	aoe.global_position = target_pos
	await get_tree().process_frame
	await get_tree().physics_frame
	for body in aoe.get_overlapping_bodies():
		if body.is_in_group("baddies"):
			baddies.append(body.get_parent())
	aoe.queue_free()
	return baddies
