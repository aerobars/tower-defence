class_name Baddy extends PathFollow2D

signal base_damage(damage)

@export var data : BaddyStats

@onready var health_bar = $HealthBar
@onready var impact_area = $Impact
var projectile_impact = preload("res://GameData/SupportScenes/projectile_impact.tscn")

func _ready() -> void:
	#healthbar setup
	health_bar.max_value = data.current_max_health
	health_bar.value = data.health
	health_bar.set_as_top_level(true)
	
	#signal connections
	data.create_dot_timers.connect(initialize_dot)
	data.health_changed.connect(healthbar_update)
	data.health_depleted.connect(destroy)

func _physics_process(delta: float) -> void:
	if progress_ratio == 1.0:
		base_damage.emit(data.current_damage)
		queue_free()
	move(delta)

func move(delta) -> void:
	set_progress(get_progress() + data.current_move_speed * delta)
	health_bar.position = position - Vector2(30, 30)

func on_hit(dmg: float, debuff: Array[DotBuff]) -> void:
	impact()
	calculate_damage(dmg)
	if debuff != null:
		for i in debuff:
			initialize_dot(i)

func initialize_dot(dot) -> void:
	dot_tick(dot)
	await(get_tree().create_timer(dot.dot_duration, false).timeout)
	dot.is_active = false
	data.remove_buff(dot)

func dot_tick(dot) -> void:
	while dot.is_active:
		await(get_tree().create_timer(dot.damage_interval, false).timeout)
		calculate_damage(dot.damage_amount)

func calculate_damage(dmg) -> void:
	data.health -= dmg

func healthbar_update(health, max_health) -> void:
	health_bar.max_value = max_health
	health_bar.value = health

func impact() -> void:
	var x_pos = randi() % 31
	var y_pos = randi() % 31
	var impact_location = Vector2(x_pos, y_pos)
	var new_impact = projectile_impact.instantiate()
	new_impact.position = impact_location
	impact_area.add_child(new_impact)

func destroy() -> void:
	$CharacterBody2D.queue_free()
	await (get_tree().create_timer(0.2).timeout)
	self.queue_free()
