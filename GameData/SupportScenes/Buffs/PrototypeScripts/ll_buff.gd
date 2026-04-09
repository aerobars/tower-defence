class_name LastLaughBuff extends LastLaugh

@export var buff : Buff


func last_laugh(owner: Node) -> void:
	var targets = await AOESetup.setup_aoe(
		owner,
		owner.global_position,
		GlobalEnums.Targets.keys()[buff.buff_targets].to_lower(),
		owner.data.aura_aoe
	)
	for target in targets:
		target.data.add_buff(buff, -1.0)
	print("last laugh buff completed")
