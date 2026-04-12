class_name LastLaughSpawn extends LastLaugh

const BADDY_SCENE = preload("res://GameData/Baddies/ScriptsAndProtos/baddy.tscn")

@export var baddy_data : BaddyStats
var scene_type #used if/when spawning traps is implemented

func last_laugh(owner) -> void:
	for i in baddy_data.spawn_per_wave:
		var new_scene = BADDY_SCENE.instantiate()
		new_scene.data = baddy_data
		owner.add_child(new_scene)
		new_scene.global_position = owner.global_position
		await owner.get_tree().create_timer(baddy_data.spawn_interval, false).timeout
	print("last laugh spawn completed")
