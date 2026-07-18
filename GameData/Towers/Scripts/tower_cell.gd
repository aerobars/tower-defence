##Handles gametime tower functions (shooting, etc.) and last step of mod updates (update to mod class and net power)
class_name TowerCell extends UnitScenePrototype


## Signals

signal mod_updated(cell: TowerCell)
signal create_projectile(projectile_data: ProjectileData)
signal update_range_display(tower_cell: TowerCell)
signal hide_range_display
signal process_update(delta: float, cur_pos: Vector2)
signal hit_detected(target_pos: Vector2)
signal wave_cleared
signal wave_clear_ability_triggered(ability_data: AbilityWaveClear)
#signal display_popup
#signal clear_popup


## Tower Setup

const TURRET_TEXTURE_SIZE : float = 32
var non_aura_radius : float #equal to TowerBase's Marker2D radius
var button_slot_id : int

@export_group("Tower Node Paths", "path_")
@export var path_turret : Sprite2D
@export var path_muzzle : Marker2D
@export var path_range_scene : Area2D
@export var path_range_aoe : CollisionShape2D
@export var path_animation_player : AnimationPlayer
@export var path_buff_display : HBoxContainer
@export var path_timer : Timer
@onready var path_tower_highlight := $TowerHighlight


## Gametime

var baddies_in_range : Array[UnitScenePrototype]
var attack_targets : Array = [UnitScenePrototype]
var activation_timer : float = 0.0
var attack_tracker : int


## Initial Setup

func _ready():
	super()
	for body in path_range_scene.get_overlapping_bodies():
		_on_range_body_entered(body)
	if data is ModPower or data is ModWeapon:
		for ability in data.abilities:
			var new_ability = ability.duplicate(true) #ability is duplicated to avoid share instances across baddies
			data.active_abilities.append(new_ability)
			new_ability.ability_setup(self)
			path_buff_display.update_display(new_ability)

func get_level() -> int:
	return get_parent().tower_data.level

## Mod Updates

func update_mod(net_power : int = 0) -> void:
	if data == null:
		path_range_aoe.get_shape().radius = 0.0
		path_turret.texture = null
		remove_from_group("towers")
		return
	data.net_power = net_power
	data.setup_stats(get_parent().tower_data.level)
	match data.mod_class:
		0: #Aura
			if get_parent().aura_tower:
				path_range_aoe.get_shape().radius = data.current_range
			else:
				path_range_aoe.get_shape().radius = non_aura_radius
			add_to_group("towers")
		1: #Power
			path_range_aoe.get_shape().radius = non_aura_radius
			remove_from_group("towers")
		2: #Weapon
			path_range_aoe.get_shape().radius = data.current_range
			add_to_group("towers")
	path_turret.texture = data.info_texture
	mod_updated.emit(self)

func on_tower_cell_updated(updated_cell: TowerCell) -> void: #Connected to GameData, triggers whenever any mod is updated
	if updated_cell == self:
		return
	if updated_cell in path_range_scene.get_overlapping_bodies():
		_on_range_body_entered(updated_cell)

##Input Event Handling

func _on_mouse_entered() -> void:
	if get_parent().is_built == false:
		return
	super()
	if data == null:
		return
	#path_timer.start()
	if data.mod_class == ModPrototype.ModClass.WEAPON or (data.mod_class == ModPrototype.ModClass.AURA and get_parent().aura_tower):
		update_range_display.emit(self)

func _on_mouse_exited() -> void:
	super()
	#path_timer.stop()
	hide_range_display.emit()
	#clear_popup.emit()

func _on_timer_timeout() -> void:
#	display_popup.emit(POPUP_TYPE, data)
	pass # Replace with function body.

#func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
#	super(viewport, event, shape_idx)

#func set_tower_highlight(value: bool) -> void:
	#path_tower_highlight.visible = value

## In-Game Function

func _process(delta: float) -> void:
	if data == null or data is ModPower: 
		return
	process_update.emit(delta, global_position)
	if get_parent().net_power < 0:
		return
	activation_timer = clamp(activation_timer + delta, 0, data.activation_cooldown)
	if baddies_in_range.size() > 0:
		attack_targets = select_targets()
		if data.mod_class == data.ModClass.WEAPON:
			if not path_animation_player.is_playing():
				turn()
		if activation_timer >= data.activation_cooldown:
			if data is ModAura and data.buff_data.buff_targets == GlobalEnums.Targets.BADDIES and not data.buff_data.buff_persistent_effect and get_parent().aura_tower:
				for baddy in baddies_in_range:
					add_buff(data.buff_data, baddy, get_parent().tower_data.level)
			elif data is ModWeapon:
				#attack_tracker += 1
				for i in data.current_multitarget:
					if i < attack_targets.size():
						fire(attack_targets[i])
			activation_timer = 0.0
	else:
		attack_targets = [null]

func _on_range_body_entered(body) -> void:
	if data == null or body == self:
		return
	if body.is_in_group("baddies"):
		baddies_in_range.append(body)
		if data.mod_class == data.ModClass.AURA and data.buff_data.buff_persistent_effect:
			add_buff(data.buff_data, body, get_parent().tower_data.level)
	elif data.mod_class == data.ModClass.AURA and body.is_in_group("towers"):
		if data.buff_data.buff_targets == GlobalEnums.Targets.BADDIES and get_parent().aura_tower:
			return #nothing gets added for offensive auras in aura mode
		else:
			add_buff(data.buff_data, body, get_parent().tower_data.level)

func _on_range_body_exited(body) -> void:
	if data == null:
		return
	if body.is_in_group("baddies"):
		baddies_in_range.erase(body)
	if data.mod_class == data.ModClass.AURA and data.buff_data.buff_persistent_effect:
		remove_buff(data.buff_data, body)

func on_wave_cleared() -> void:
	wave_cleared.emit()

##Pairs with on_wave_cleared to have Wave Clear Trigger Abilities send their data to Game Scene
func on_wave_clear_ability_trigger(ability_data: AbilityWaveClear) -> void:
	wave_clear_ability_triggered.emit(ability_data, get_parent().tower_data.level)

## Weapon Function

func select_targets() -> Array:
	return baddies_in_range

func turn():
	if is_instance_valid(attack_targets[0]):
		path_turret.look_at(attack_targets[0].global_position)

func fire(target: UnitScenePrototype):
	if data.projectile_speed > 0:
		fire_projectile(target)
	else:
		fire_instant(target)

func fire_projectile(target: UnitScenePrototype) -> void:
	create_projectile.emit(
		ProjectileData.new(
			self, 
			path_muzzle.global_position, 
			target.global_position))

func projectile_contact(projectile_pos: Vector2) -> void:
	hit_detected.emit(projectile_pos)

func fire_instant(target: UnitScenePrototype) -> void:
	path_animation_player.play("fire")
	if data.current_aoe > 0:
		var baddies = StaticFunctions.setup_aoe(
			self, 
			target.global_position, 
			"baddies", 
			data.current_aoe)
		for baddy in baddies:
			baddy.on_hit(data.calculate_damage(), data.on_hit_effects, get_parent().tower_data.level)
			hit_detected.emit(baddy.global_position)
	else:
		target.on_hit(data.calculate_damage(), data.on_hit_effects, get_parent().tower_data.level)
		hit_detected.emit(target.global_position)
