##Ability class for abilities that trigger after a baddy is hit
class_name AbilityOnHit extends AbilityTriggeredPrototype

##Success chance for onhit abilities
@export_range(0.0, 1.0, 0.01) var onhit_success_chance : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]

func ability_setup(_ability_owner) -> void:
	super(_ability_owner)
	ability_owner.hit_detected.connect(on_hit_check)

func on_hit_check() -> void:
	if randf() <= onhit_success_chance[owner_level]:
		triggered_effect()
