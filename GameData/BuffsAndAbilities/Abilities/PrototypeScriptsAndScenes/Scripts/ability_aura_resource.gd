class_name AbilityAura extends Ability

#signal ability_aura_setup(ability_info: AbilityAura)

func ability_setup(_ability_owner: UnitScenePrototype, _ability_source: UnitScenePrototype) -> void:
	super(_ability_owner, _ability_source)
	ability_owner.aura_setup(self)
	#ability_aura_setup.emit(self)
	#print("aura setup signal emitted")
