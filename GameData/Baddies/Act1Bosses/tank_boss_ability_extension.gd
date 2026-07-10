extends AbilityHPThreshold

func ability_setup(_ability_owner: CollisionObject2D) -> void:
	super(_ability_owner)
	threshold_reached.connect(armor_decrease)
	print("connection complete")

func armor_decrease() -> void:
	ability_owner.data.base_defence_tag = max(0, ability_owner.data.base_defence_tag - 1)
	print(ability_owner.data.base_defence_tag)
