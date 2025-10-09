extends Area2D

var target_baddy

#when an enemy enters weapon range, trigger timer to start attacking
func _on_body_entered(_body):
	print("body entered")
	$WeaponCooldown.start()

#wait for WeaponCooldown to finish final tick before stopping to provide some banding with aoe
func _on_body_exited(_body):
	print("body exited")
	#will shoot the last baddy to leave the weapon range one last time if cd was close to finishing
	if $WeaponCooldown.time_left < 1:
		await $WeaponCooldown.timeout
	$WeaponCooldown.stop()
	print("timer stopped")

func _on_timer_timeout():
	shoot()
	print("tick")

func shoot():
	const PROJECTILE = preload("res://projectile.tscn")
	#if the last baddy leaves the weapon range, it will still hit one last time
	if get_overlapping_bodies().size() > 0:
		target_baddy = get_overlapping_bodies()[0]
	$ShootingPoint.look_at(target_baddy.global_position)
	
	var new_proj = PROJECTILE.instantiate()
	new_proj.global_position = $ShootingPoint.global_position
	new_proj.global_rotation = $ShootingPoint.global_rotation
	$ShootingPoint.add_child(new_proj)
	
