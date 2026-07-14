extends Node2D

signal update_wave_info(wave_baddies: Array)
signal new_baddy_spawned(new_baddy: Baddy)
signal wave_cleared
signal base_damaged(baddy_damage : float)
signal game_over

const BADDY_SCENE := preload("res://GameData/Baddies/ScriptsAndProtos/baddy.tscn")

var wave_total : int
var remaining_spawns : int
var living_baddies : Array[Baddy] = []
var escaped_baddies : int

func start_next_wave() -> void:
	SaveManager.save_data_run.current_wave += 1
	var wave_data = GameData.get_wave_data()
	wave_total = wave_data["wave_total"]
	remaining_spawns = wave_total
	living_baddies = []
	escaped_baddies = 0
	spawn_baddies(wave_data["wave_baddies"])

func spawn_baddies(wave_data) -> void:
	var wave_baddies : Array[Dictionary]
	var spawning := true
	
	for i in wave_data: 
		var baddy_data = GameData.get_baddy_filepath(i)
		
		wave_baddies.append({
			"data" : baddy_data,
			"spawn_count" : 0,
			"spawn_per_wave" : baddy_data.spawn_per_wave,
			"spawn_interval" : baddy_data.spawn_interval
			})
	update_wave_info.emit(wave_baddies)
		
	while spawning:
		spawning = false
		for baddy in wave_baddies:
			if baddy["spawn_count"] < baddy["spawn_per_wave"]:
				spawning = true
				
				var new_baddy = BADDY_SCENE.instantiate()
				
				new_baddy.data = baddy["data"].duplicate(true)
				new_baddy.baddy_escaped.connect(baddy_escaped)
				new_baddy.baddy_death.connect(on_baddy_death)
				new_baddy_spawned.emit(new_baddy)
				add_child(new_baddy, true)
				
				baddy["spawn_count"] += 1
				living_baddies.append(new_baddy)
				remaining_spawns -= 1
				await get_tree().create_timer(baddy["spawn_interval"], false).timeout

func on_baddy_death(baddy: Baddy) -> void:
	living_baddies.erase(baddy)
	if living_baddies.size() == 0 and remaining_spawns == 0:
		wave_cleared.emit()

func baddy_escaped(baddy: Baddy) -> void:
	if not baddy.data.spawn_summon:
		escaped_baddies += 1
	if escaped_baddies == wave_total:
		game_over.emit()
	else:
		base_damaged.emit(baddy.data.current_damage)
		on_baddy_death(baddy)
