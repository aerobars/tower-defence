class_name Baddy extends PathFollow2D

##Signals
signal baddy_death
signal base_damage(damage)

##Node Paths
@export_group("Node Paths", "path")
@export var path_health_bar : TextureProgressBar
@export var path_impact_area : Marker2D
@export var path_damage_number_origin : Marker2D
@export var path_hit_flash : AnimationPlayer
@export var path_aura : CollisionShape2D
@export var path_sprite : Sprite2D

##Runtime
const PROJECTILE_IMPACT := preload("res://GameData/SupportScenes/projectile_impact.tscn")
@export var data : BaddyStats
var destroyed := false

##Setup
func _ready() -> void:
	data.buff_owner = self
	path_sprite.texture = data.texture
	path_aura.get_shape().radius = data.aura_aoe
	
	#healthbar setup
	healthbar_update(data.health, data.health)
	path_health_bar.set_as_top_level(true)
	
	#signal connections
	data.health_changed.connect(healthbar_update)
	data.health_depleted.connect(destroy)
	
	for buff in data.initial_buffs:
		data.add_buff(buff, buff.buff_duration)

##Runtime
func _process(delta: float) -> void:
	for buff in data.active_buffs.keys(): #.keys for clarity, does the same as data.active_buffs
		data.active_buffs[buff].update(delta, progress)

func _physics_process(delta: float) -> void:
	if progress_ratio == 1.0:
		if destroyed:
			return
		destroyed = true
		$CharacterBody2D.free()
		base_damage.emit(data.current_damage)
		queue_free()
	move(delta)

func move(delta) -> void:
	set_progress(get_progress() + data.current_move_speed * delta)
	path_health_bar.position = position - Vector2(30, 30)

func on_hit(dmg: Array, debuff: Array = []) -> void: #Array contains dmg amt, dmg tags, and crit status
	calculate_damage(dmg)
	for buff in data.active_buffs.keys():
		if buff is OnHitBuff:
			data.active_buffs[buff].on_hit_check()
	if debuff != []:
		for i in debuff:
			data.add_buff(i)

func calculate_damage(dmg: Array) -> void:#Array contains dmg amt, dmg tag, and crit status
	for tag in GlobalEnums.DamageTag.keys():
		var cur_tag = GlobalEnums.DamageTag[tag]
		if dmg[1] & cur_tag:
			if cur_tag == GlobalEnums.DamageTag.BLUNT or cur_tag == GlobalEnums.DamageTag.PIERCE:
				dmg[0] = max(0, dmg[0] - data.current_defence)
				impact(cur_tag)
			else:
				dmg[0] *=  GlobalEnums.DEFENCE_TABLE[data.base_defence_tag][cur_tag]
	data.health -= dmg[0]
	DamageNumbers.display_number(dmg[0], path_damage_number_origin.global_position, dmg[1], dmg[2])

func healthbar_update(health, max_health) -> void:
	path_health_bar.max_value = max_health
	path_health_bar.value = health

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
	$CharacterBody2D.free()
	for buff in data.on_death_buffs:
		var trigger = BuffInstance.new(buff, self)
		await trigger.on_death_trigger()#access buff instance without settin up buff in active buffs?
	await (get_tree().create_timer(0.2).timeout)
	queue_free()
	baddy_death.emit()

##Aura Functions
func _on_aura_range_body_entered(body: Node2D) -> void:
	if path_aura.get_shape().radius < 1 or data.initial_buffs.size() == 0: #min radius is 0.01, instead of making separate boolean variable
		return
	for buff in data.initial_buffs:
		var buff_targets = buff.data.buff_targets
		if buff_targets == GlobalEnums.AuraTargets.NONE:
			continue
		if body.is_in_group("baddies") and buff_targets == GlobalEnums.AuraTargets.BADDIES:
			add_buff(body.get_parent(), buff)
		elif body.is_in_group("turret") and buff_targets == GlobalEnums.AuraTargets.TOWERS:
			add_buff(body, buff)

func _on_aura_range_body_exited(body: Node2D) -> void:
	if path_aura.get_shape().radius < 1: #min radius is 0.01, instead of making separate boolean variable
		return
	for buff in data.initial_buffs:
		var buff_targets = buff.data.buff_targets
		if buff_targets == GlobalEnums.AuraTargets.NONE:
			continue
		if body.is_in_group("baddies") and buff_targets == GlobalEnums.AuraTargets.BADDIES:
			remove_buff(body.get_parent(), buff)
		elif body.is_in_group("turret") and buff_targets == GlobalEnums.AuraTargets.TOWERS:
			remove_buff(body, buff)

func add_buff(body : Node2D, buff : Buff) -> void:
	body.data.add_buff(buff, buff.buff_duration)

func remove_buff(body : Node2D, buff : Buff) -> void:
	body.data.remove_buff(buff)
