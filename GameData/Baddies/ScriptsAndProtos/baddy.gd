class_name Baddy extends PathFollow2D

signal baddy_death
signal base_damage(damage)

@export var data : BaddyStats

## Node Paths
@onready var health_bar : TextureProgressBar = $HealthBar
@onready var impact_area : Marker2D = $Impact
@onready var damage_number_origin : Marker2D = $DamageNumberOrigin
@onready var hit_flash : AnimationPlayer = $HitFlashAnimation
@onready var aura : CollisionShape2D = $AuraRange/CollisionShape2D
@onready var sprite : Sprite2D = $Sprite2D
var projectile_impact := preload("res://GameData/SupportScenes/projectile_impact.tscn")


func _ready() -> void:
	data.buff_owner = self
	sprite.texture = data.texture
	aura.get_shape().radius = data.base_aura_aoe
	
	#healthbar setup
	healthbar_update(data.health, data.health)
	health_bar.set_as_top_level(true)
	
	#signal connections
	data.health_changed.connect(healthbar_update)
	data.health_depleted.connect(destroy)
	
	for buff in data.initial_buffs:
		data.add_buff(buff.duplicate(true), buff.buff_duration)

func _process(delta: float) -> void:
	for buff in data.active_buffs.keys(): #.keys for clarity, does the same as data.active_buffs
		data.active_buffs[buff].update(delta, progress)

func _physics_process(delta: float) -> void:
	if progress_ratio == 1.0:
		$CharacterBody2D.free()
		base_damage.emit(data.current_damage)
		queue_free()
	move(delta)

func move(delta) -> void:
	set_progress(get_progress() + data.current_move_speed * delta)
	health_bar.position = position - Vector2(30, 30)

func on_hit(dmg: Array, debuff: Array = []) -> void: #Array contains dmg amt, dmg tag, and crit status
	calculate_damage(dmg)
	for buff in data.active_buffs.keys():
		if buff is OnHitBuff:
			data.active_buffs[buff].on_hit_check()
	if debuff != []:
		for i in debuff:
			data.add_buff(i)

func calculate_damage(dmg: Array) -> void:#Array contains dmg amt, dmg tag, and crit status
	match AllDamageTags.DamageTag.keys()[dmg[1]]:
		"BLUNT", "PIERCE":
			dmg[0] = max(0, dmg[0] - data.current_defence) * AllDamageTags.DEFENCE_TABLE[data.defence_tag][dmg[1]]
		_:
			dmg[0] = dmg[0] * AllDamageTags.DEFENCE_TABLE[data.defence_tag][dmg[1]]
	data.health -= dmg[0]
	impact(dmg[1])
	DamageNumbers.display_number(dmg[0], damage_number_origin.global_position, dmg[1], dmg[2])

func healthbar_update(health, max_health) -> void:
	health_bar.max_value = max_health
	health_bar.value = health

func impact(damage_type: AllDamageTags.DamageTag) -> void:
	match AllDamageTags.DamageTag.keys()[damage_type]:
		"BLEED":
			hit_flash.play("hit_flash")
		"BURN": #Burn
			hit_flash.play("hit_flash")
		"POISON": #Poison
			hit_flash.play("hit_flash")
		"BLUNT", "PIERCE": # Blunt, Explosion, and Pierce
			var x_pos = randi() % 31
			var y_pos = randi() % 31
			var impact_location = Vector2(x_pos, y_pos)
			var new_impact = projectile_impact.instantiate()
			new_impact.position = impact_location
			impact_area.add_child(new_impact)

func destroy() -> void:
	data.health_depleted.disconnect(destroy)
	$CharacterBody2D.free()
	await (get_tree().create_timer(0.2).timeout)
	queue_free()
	baddy_death.emit()


func _on_aura_range_body_entered(body: Node2D) -> void:
	if body is Baddy:
		pass
	elif body is TowerMod:
		pass
