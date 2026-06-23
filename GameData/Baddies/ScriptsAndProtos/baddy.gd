class_name Baddy extends UnitPrototype

##Signals
signal baddy_death
signal base_damage(damage)
signal open_baddy_display(data: BaddyStats)
signal update_baddy_display(data: BaddyStats)
signal hit_detected
#signal unit_selected(baddy: Baddy)

##Node Paths
@export_group("Node Paths", "path")
@export var path_status_display : Node2D
@export var path_impact_area : Marker2D
@export var path_damage_number_origin : Marker2D
@export var path_hit_flash : AnimationPlayer
@export var path_aura : CollisionShape2D
@export var path_baddy_texture : Sprite2D
#@export var path_selection_circle : Sprite2D

##Pathfinding
var path_map
var movement_delta : float
var path_point_margin : float = 0.5

var current_path : PackedVector2Array #set in Game Scene when baddy is instantiated
var current_path_index : int = 0
var current_path_point : Vector2
var waypoint_index : int = 1

##Runtime Variables
const PROJECTILE_IMPACT := preload("res://GameData/SupportScenes/Scenes/projectile_impact.tscn")
@export var data : BaddyStats
var destroyed := false
var level : int = 0
#var selected := false

##Setup

func _ready() -> void:
	if data == null:
		print("missing baddy data")
		return
	data.buff_owner = self
	path_baddy_texture.texture = data.info_texture
	path_aura.get_shape().radius = data.aura_aoe
	
	#healthbar setup
	healthbar_update(data.health, data.current_max_health)
	path_status_display.position = position + Vector2(-30, 18)
	path_status_display.update_defence(data.current_defence)
	
	#pathing setup
	update_pathing()
	
	#signal connections
	data.health_changed.connect(healthbar_update)
	data.health_depleted.connect(destroy)
	data.stats_updated.connect(stats_update)
	data.update_buff_display.connect(path_status_display.path_buff_display_container.update_display)
	data.remove_buff_display.connect(path_status_display.path_buff_display_container.remove_buff)
	
	#ability setup
	
	for ability in data.inate_abilities:
		ability.ability_owner = self
		ability.ability_setup()
	
	for buff in data.initial_buffs:
		add_buff(buff, level)
		if data.aura_aoe > 1:
			add_buff_aoe(buff, self)
	for effect in data.last_laugh_effects:
		path_status_display.path_buff_display_container.update_display(effect)
		if effect is LastLaughSpawn:
			pass

##Runtime Functions

func _process(delta: float) -> void:
	for buff in data.active_buffs:
		data.active_buffs[buff].update(delta, global_position)

func _physics_process(delta: float) -> void:
	path_status_display.position = position + Vector2(-30, 18)
	if current_path.is_empty():
		return
	
	movement_delta = data.current_move_speed * delta
	
	if global_position.distance_to(current_path_point) <= path_point_margin:
		current_path_index += 1
		if current_path_index >= current_path.size(): 
			waypoint_index += 1
			update_pathing()
			if current_path == PackedVector2Array([Vector2(-1000,-1000)]) and not destroyed:
				destroyed = true
				#current_path = []
				#current_path_index = 0
				#current_path_point = global_transform.origin
				base_damage.emit(data.current_damage, data.spawn_summon)
				queue_free()
				return
	
	current_path_point = current_path[current_path_index]
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", global_position.angle_to_point(current_path_point), 0.15)
	global_position = global_position.move_toward(current_path_point, movement_delta)

func periodic_effect_trigger() -> void:
	if data.periodic_effect.is_empty():
		return
	for effect in data.periodic_effect:
		add_buff(effect, self, level)

func update_pathing() -> void:
	current_path = path_map.update_pathing(global_position, waypoint_index)
	current_path_index = 0
	current_path_point = current_path[current_path_index]

##dmg Array contains dmg amt, dmg tags, and crit status
func on_hit(dmg: Array, debuff: Array = [], tower_mod_level : int = 0) -> void: 
	calculate_damage(dmg)
	var pending_buffs : Array[Buff] = []
	hit_detected.emit()
	for buff in data.active_buffs:
		data.active_buffs[buff].level = tower_mod_level
		if buff is BuffOnHit:
			data.active_buffs[buff].on_hit_check(dmg[1], pending_buffs)
	#debuff.append_array(pending_buffs)
	if debuff != []:
		for i in debuff:
			add_buff(i, self ,level)

##dmg Array contains dmg amt, dmg tags, and crit status
func calculate_damage(dmg: Array) -> void:
	for tag in GlobalEnums.DamageTag.keys():
		var cur_tag = GlobalEnums.DamageTag[tag]
		if dmg[1] & cur_tag:
			if cur_tag == GlobalEnums.DamageTag.BLUNT or cur_tag == GlobalEnums.DamageTag.PIERCE:
				dmg[0] = max(0, dmg[0] - data.current_defence)
				impact(cur_tag)
			elif cur_tag == GlobalEnums.DamageTag.HEAL:
				dmg[0] = dmg[0] * -1
			else:
				dmg[0] *=  GlobalEnums.DEFENCE_TABLE[data.base_defence_tag][cur_tag]
	data.health -= dmg[0]
	DamageNumbers.display_number(dmg[0], path_damage_number_origin.global_position, dmg[1], dmg[2])

func healthbar_update(health, max_health) -> void:
	path_status_display.path_health_bar.max_value = max_health
	path_status_display.path_health_bar.value = health
	update_baddy_display.emit(self)

func stats_update() -> void:
	path_status_display.update_defence(data.current_defence)
	update_baddy_display.emit(self)

func impact(damage_type: GlobalEnums.DamageTag) -> void:
	if damage_type == GlobalEnums.DamageTag.BLUNT or damage_type == GlobalEnums.DamageTag.PIERCE:
		var x_pos = randi() % 31
		var y_pos = randi() % 31
		var impact_location = Vector2(x_pos, y_pos)
		var new_impact = PROJECTILE_IMPACT.instantiate()
		new_impact.position = impact_location
		path_impact_area.add_child(new_impact)
	else:
		path_hit_flash.play("hit_flash")

func destroy() -> void:
	if destroyed:
		return
	destroyed = true
	data.health_depleted.disconnect(destroy)
	baddy_death.emit()
	await (get_tree().create_timer(0.2).timeout)
	queue_free()

## Input Functions

func set_selected(value: bool) -> void:
	super(value)
	if selected:
		open_baddy_display.emit(self)
