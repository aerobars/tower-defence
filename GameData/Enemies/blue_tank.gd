extends PathFollow2D

signal base_damage(damage)

var speed := 150
var hp := 1000
var damage := 21

@onready var health_bar = $HealthBar
@onready var impact_area = $Impact
var projectile_impact = preload("res://GameData/Support Scenes/projectile_impact.tscn")

func _ready() -> void:
	health_bar.max_value = hp
	health_bar.value = hp
	health_bar.set_as_top_level(true)

func _physics_process(delta: float) -> void:
	if progress_ratio == 1.0:
		emit_signal("base_damage", damage)
		queue_free()
	move(delta)

func move(delta):
	set_progress(get_progress() + speed * delta)
	health_bar.position = position - Vector2(30, 30)

func on_hit(dmg):
	impact()
	hp -= dmg
	health_bar.value = hp
	if hp <= 0:
		destroy()
		
func impact():
	randomize()
	var x_pos = randi() % 31
	randomize()
	var y_pos = randi() % 31
	var impact_location = Vector2(x_pos, y_pos)
	var new_impact = projectile_impact.instantiate()
	new_impact.position = impact_location
	impact_area.add_child(new_impact)

func destroy():
	$CharacterBody2D.queue_free()
	await (get_tree().create_timer(0.2).timeout)
	self.queue_free()
