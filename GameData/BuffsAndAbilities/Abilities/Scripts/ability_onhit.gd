##Ability class for abilities that trigger after a baddy is hit
class_name AbilityOnHit extends AbilityTriggeredPrototype

var success_chance : float :
	get():
		return 1

func ability_setup(_ability_owner) -> void:
	ability_owner.hit_detected.connect(on_hit_check)

func on_hit_check() -> void:
	if success_chance >= randf():
		triggered_effect()

func triggered_effect() -> void:
	pass
