class_name AbilityAura extends AbilityPrototype

signal ability_aura_setup

func ability_setup(_ability_owner: CollisionObject2D) -> void:
	super(_ability_owner)
	ability_aura_setup.emit()
