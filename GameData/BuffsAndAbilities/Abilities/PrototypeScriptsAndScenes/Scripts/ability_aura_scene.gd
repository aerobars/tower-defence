class_name AbilityAuraScene extends Node2D

#signal add_buff(buff: Buff, body: CollisionObject2D)
#signal remove_buff(buff: Buff, body: CollisionObject2D)

var ability_aura_data: AbilityAura


func _ready() -> void:
	$CollisionShape2D.get_shape().radius = ability_aura_data.ability_aoe[ability_aura_data.owner_level]
	#add_buff.connect(ability_aura_data.ability_owner.add_buff)
	#remove_buff.connect(ability_aura_data.ability_owner.remove_buff)

func _on_body_entered(body:UnitScenePrototype) -> void:
	var aura_targets = ability_aura_data.ability_targets
	if aura_targets == GlobalEnums.Targets.NONE:
		return
	if body.is_in_group("baddies") and aura_targets == GlobalEnums.Targets.BADDIES:
		body.add_effect(ability_aura_data.buff_data)
	elif body.is_in_group("towers") and aura_targets == GlobalEnums.Targets.TOWERS:
		body.add_effect(ability_aura_data.buff_data)

func _on_body_exited(body: UnitScenePrototype) -> void:
	var aura_targets = ability_aura_data.buff_data.buff_targets
	if aura_targets == GlobalEnums.Targets.NONE:
		return
	if body.is_in_group("baddies") and aura_targets == GlobalEnums.Targets.BADDIES:
		body.remove_effect(ability_aura_data.buff_data)
	elif body.is_in_group("towers") and aura_targets == GlobalEnums.Targets.TOWERS:
		body.remove_effect(ability_aura_data.buff_data)
