class_name AbilityAuraScene extends Node2D

signal add_buff(buff : Buff, body : CollisionObject2D)
signal remove_buff(buff : Buff, body : CollisionObject2D)

var ability_aura_data : AbilityAura


func _ready() -> void:
	$CollisionShape2D.get_shape().radius = ability_aura_data.ability_aoe[ability_aura_data.owner_level]
	add_buff.connect(ability_aura_data.ability_owner.add_buff)
	remove_buff.connect(ability_aura_data.ability_owner.remove_buff)

func _on_body_entered(body: Node2D) -> void:
	var buff_targets = ability_aura_data.buff_data.buff_targets
	if buff_targets == GlobalEnums.Targets.NONE:
		return
	if body.is_in_group("baddies") and buff_targets == GlobalEnums.Targets.BADDIES:
		add_buff.emit(ability_aura_data.buff_data, body)
	elif body.is_in_group("towers") and buff_targets == GlobalEnums.Targets.TOWERS:
		add_buff.emit(ability_aura_data.buff_data, body)

func _on_body_exited(body: Node2D) -> void:
	var buff_targets = ability_aura_data.buff_data.buff_targets
	if buff_targets == GlobalEnums.Targets.NONE:
		return
	if body.is_in_group("baddies") and buff_targets == GlobalEnums.Targets.BADDIES:
		remove_buff.emit(ability_aura_data.buff_data, body)
	elif body.is_in_group("towers") and buff_targets == GlobalEnums.Targets.TOWERS:
		remove_buff.emit(ability_aura_data.buff_data, body)
