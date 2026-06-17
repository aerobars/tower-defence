##Handles gametime tower functions (shooting, etc.) and last step of mod updates (update to mod class and net power)
class_name TowerCell extends UnitPrototype


## Signals
signal mod_updated(mod: StaticBody2D)
#signal clear_popup
#signal display_popup
signal update_range_display(tower_cell: TowerCell)
signal hide_range_display


## Tower Setup
const PROJECTILE_SCENE := preload("res://GameData/Towers/Scenes/tower_projectile.tscn")
const TURRET_TEXTURE_SIZE : float = 32
var non_aura_radius : float #equal to TowerBase's Marker2D radius
var data : PrototypeMod
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
var baddies_in_range : Array
var attack_targets : Array = []
var aura_targets : Array = []
var attack_timer : float = 0.0
var attack_tracker : int


## Initial Setup

func _ready():
	if data != null:
		data.buff_owner = self
	for body in path_range_scene.get_overlapping_bodies():
		_on_range_body_entered(body)
	
	mod_updated.connect(GameData.mod_updated) #for when this mod gets updated
	GameData.mod_update_check.connect(_on_mod_updated) #for when other mods get updated
	#above signals allow other mods to be added to auras after they are updated

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

func _on_mod_updated(updated_mod: StaticBody2D) -> void: #Connected to GameData, triggers whenever any mod is updated
	if updated_mod == self:
		return
	if updated_mod in path_range_scene.get_overlapping_bodies():
		_on_range_body_entered(updated_mod)

##Input Event Handling

func _on_mouse_entered() -> void:
	if get_parent().is_built == false:
		return
	super()
	if data == null:
		return
	#path_timer.start()
	if data.mod_class == PrototypeMod.ModClass.WEAPON or (data.mod_class == PrototypeMod.ModClass.AURA and get_parent().aura_tower):
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
	if data == null or data is PowerMod: 
		return
	for buff in data.active_buffs:
		data.active_buffs[buff].update(delta)
	if get_parent().net_power < 0:
		return
	attack_timer = clamp(attack_timer + delta, 0, data.current_attack_speed)
	if baddies_in_range.size() > 0:
		attack_targets = select_targets()
		if data.mod_class == data.ModClass.WEAPON:
			if not path_animation_player.is_playing():
				turn()
		if attack_timer >= data.current_attack_speed:
			if data is AuraMod and data.buff_data.buff_targets == GlobalEnums.Targets.BADDIES and not data.buff_data.persistent_effect and get_parent().aura_tower:
				for baddy in baddies_in_range:
					add_buff(data.buff_data, get_parent().tower_data.level, baddy)
			elif data is WeaponMod:
				#attack_tracker += 1
				for i in data.current_multitarget:
					if i < attack_targets.size():
						fire(attack_targets[i])
			attack_timer = 0.0
	else:
		attack_targets = [null]

func _on_range_body_entered(body) -> void:
	if data == null or body == self:
		return
	if body.is_in_group("baddies"):
		baddies_in_range.append(body)
		if data.mod_class == data.ModClass.AURA and data.buff_data.persistent_effect:
			add_buff(data.buff_data, get_parent().tower_data.level, body)
	elif data.mod_class == data.ModClass.AURA and body.is_in_group("towers"):
		if data.buff_data.buff_targets == GlobalEnums.Targets.BADDIES and get_parent().aura_tower:
			return #nothing gets added for offensive auras in aura mode
		else:
			aura_targets.append(body)
			add_buff(data.buff_data, get_parent().tower_data.level, body)

func _on_range_body_exited(body) -> void:
	if data == null:
		return
	if body.is_in_group("baddies"):
		baddies_in_range.erase(body)
		if data.mod_class == data.ModClass.AURA and data.buff_data.persistent_effect:
			remove_buff(data.buff_data, body)
	elif data.mod_class == data.ModClass.AURA and body.is_in_group("towers"):
		aura_targets.erase(body)
		remove_buff(data.buff_data, body)

## Weapon Function

func select_targets() -> Array:
	return baddies_in_range

func turn():
	if is_instance_valid(attack_targets[0]):
		path_turret.look_at(attack_targets[0].position)

func fire(target):
	if data.projectile_speed > 0:
		fire_projectile(target)
	else:
		fire_instant()
		if data.current_aoe > 0:
			var baddies = await AOESetup.setup_aoe(
				self, 
				target.global_position, 
				"baddies", 
				data.current_aoe)
			for baddy in baddies:
				baddy.on_hit(data.calculate_damage(), data.on_hit_effects, get_parent().tower_data.level)
		else:
			target.on_hit(data.calculate_damage(), data.on_hit_effects, get_parent().tower_data.level)

func fire_projectile(target) -> void:
	var new_projectile = PROJECTILE_SCENE.instantiate()
	new_projectile.speed = data.projectile_speed
	new_projectile.pierce_total = data.current_pierce
	new_projectile.damage = data.calculate_damage()
	new_projectile.on_hit_effects = data.on_hit_effects
	new_projectile.aoe = data.current_aoe
	add_child(new_projectile)
	new_projectile.position = path_muzzle.position
	new_projectile.look_at(target.position)
	new_projectile.direction = Vector2.RIGHT.rotated(new_projectile.rotation)

func fire_instant() -> void:
	path_animation_player.play("fire")
