##Ability class for abilities that trigger after a baddy is hit
class_name AbilityOnHit extends AbilityTriggeredPrototype

##Success chance for onhit abilities
@export_range(0.0, 1.0, 0.01) var onhit_success_chance: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]

func _init(_ability: Ability, _onhit_chance: float = 1.0, ) -> void:
	ability_aoe = _ability.ability_aoe
	ability_cooldown = _ability.ability_cooldown
	ability_damage_tag = _ability.ability_damage_tag
	ability_effect_amount = _ability.ability_effect_amount
	ability_targets = _ability.ability_targets
	buff_data = _ability.buff_data
	onhit_success_chance = [_onhit_chance, _onhit_chance, _onhit_chance, _onhit_chance, _onhit_chance]

func ability_setup(_ability_owner, _ability_source: UnitScenePrototype) -> void:
	super(_ability_owner, _ability_source)
	ability_owner.hit_detected.connect(on_hit_check)

func on_hit_check(triggering_unit: Node2D) -> void:
	if randf() <= onhit_success_chance[owner_level]:
		triggered_effect(triggering_unit)
