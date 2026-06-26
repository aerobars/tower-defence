class_name AbilityAura extends AbilityPrototype

#signal ability_aura_setup(ability_info : AbilityAura)

func ability_setup(_ability_owner: CollisionObject2D) -> void:
	super(_ability_owner)
	ability_owner.aura_setup(self)
	#ability_aura_setup.emit(self)
	#print("aura setup signal emitted")
