##Ability that triggers when a wave has been cleared, Ability targets 
class_name AbilityWaveClear extends AbilityTriggeredPrototype

signal send_ability_data(data: AbilityWaveClear)

enum Boon {MAX_HEATLH, HEAL, MONEY, UPGRADE}

@export_group("Wave Clear Abilities")
##The type of boon the player will receive upon wave completion
@export var boon_type : Boon
##The upper limit for the number of instances of this ability in play that will be able to proc this boon per wave, 
##i.e. a limit of 5 means that up to 5 instances will trigger, but a 6th instance has no effect.
@export var boon_limit : int = 1
##How much of the boon is implemented per instacne
@export var boon_amount : Array[int] = [1, 2, 3, 4, 5]

func ability_setup(_ability_owner: CollisionObject2D) -> void:
	super(_ability_owner)
	if ability_targets != GlobalEnums.Targets.NONE:
		print("Incorrect wave clear ability targets, targets must be NONE")
	ability_owner.wave_cleared.connect(triggered_effect)

func no_target_trigger() -> void:
	send_ability_data.emit(self)
	pass
