class_name BuffOnHit extends Buff

enum AffectedStat {
	HEALTH,
	MAX_HEALTH,
	MOVE_SPEED,
	DAMAGE,
	ATTACK_SPEED,
	DEFENCE,
}
##Chance to successfully trigger onhit effect, 1.0 = 100%
@export_range(0.0, 1.0, 0.1) var success_chance_per_stack : Array[float] = [0.1, 0.1, 0.1, 0.1, 0.1]
@export var buff_to_apply : Buff
@warning_ignore("int_as_enum_without_cast")
@warning_ignore("int_as_enum_without_match")
##Damage Tag = 0 is no effect
@export var damage_tag : GlobalEnums.DamageTag = 0
