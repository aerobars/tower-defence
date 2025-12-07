class_name Baddy extends PathFollow2D

signal base_damage(damage)

@export var data : BaddyStats

var speed := 150
var hp := 1000
var damage := 21

@onready var health_bar = $HealthBar
@onready var impact_area = $Impact
var projectile_impact = preload("res://GameData/SupportScenes/projectile_impact.tscn")

func _ready() -> void:
	health_bar.max_value = data.current_max_health
	health_bar.value = data.health
	health_bar.set_as_top_level(true)
	data.create_dot_timers.connect(initialize_dot)

func _physics_process(delta: float) -> void:
	if progress_ratio == 1.0:
		emit_signal("base_damage", damage)
		queue_free()
	move(delta)

func move(delta) -> void:
	set_progress(get_progress() + data.current_move_speed * delta)
	health_bar.position = position - Vector2(30, 30)

func on_hit(dmg) -> void:
	impact()
	calculate_damage(dmg)

func initialize_dot(dot) -> void:
	dot_tick(dot)
	await(get_tree().create_timer(dot.dot_duration).timeout)
	dot.is_active = false

func dot_tick(dot) -> void:
	await(get_tree().create_timer(dot.damage_interval).timeout)
	calculate_damage(dot.damage)

func calculate_damage(dmg) -> void:
	data.health -= dmg
	health_bar.value = data.health
	if hp <= 0:
		destroy()

func impact() -> void:
	randomize()
	var x_pos = randi() % 31
	randomize()
	var y_pos = randi() % 31
	var impact_location = Vector2(x_pos, y_pos)
	var new_impact = projectile_impact.instantiate()
	new_impact.position = impact_location
	impact_area.add_child(new_impact)

func destroy() -> void:
	$CharacterBody2D.queue_free()
	await (get_tree().create_timer(0.2).timeout)
	self.queue_free()
