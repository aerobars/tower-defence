class_name GlobalEnums extends Resource

enum DamageTag {
	BLUNT = 1 << 1,
	PIERCE = 1 << 4, #weapon damage types first to maintain additives before mulitplicatives in damage calculation
	BLEED = 1 << 0,
	BURN = 1 << 2,
	POISON = 1 << 5,
	SHOCK = 1 << 6,
	HEAL = 1 << 3,
}

enum BaddyArmorTags {
	UNARMORED,
	LIGHT,
	MEDIUM,
	HEAVY
}

const DEFENCE_TABLE : Dictionary = {
	BaddyArmorTags.UNARMORED: {
		GlobalEnums.DamageTag.BLEED: 1.0,
		GlobalEnums.DamageTag.BLUNT: 1.0,
		GlobalEnums.DamageTag.BURN: 1.5,
		GlobalEnums.DamageTag.PIERCE: 2.0,
		GlobalEnums.DamageTag.POISON: 1.0,
		GlobalEnums.DamageTag.SHOCK: 0.75,
	},
	BaddyArmorTags.LIGHT: {
		GlobalEnums.DamageTag.BLEED: 1.0,
		GlobalEnums.DamageTag.BLUNT: 1.0,
		GlobalEnums.DamageTag.BURN: 1.0,
		GlobalEnums.DamageTag.PIERCE: 1.0,
		GlobalEnums.DamageTag.POISON: 1.0,
		GlobalEnums.DamageTag.SHOCK: 0.75,
	},
	BaddyArmorTags.MEDIUM: {
		GlobalEnums.DamageTag.BLEED: 1.0,
		GlobalEnums.DamageTag.BLUNT: 1.0,
		GlobalEnums.DamageTag.BURN: 1.0,
		GlobalEnums.DamageTag.PIERCE: 1.0,
		GlobalEnums.DamageTag.POISON: 1.0,
		GlobalEnums.DamageTag.SHOCK: 0.75,
	},
	BaddyArmorTags.HEAVY: {
		GlobalEnums.DamageTag.BLEED: 0.75,
		GlobalEnums.DamageTag.BLUNT: 0.75,
		GlobalEnums.DamageTag.BURN: 0.75,
		GlobalEnums.DamageTag.PIERCE: 0.75,
		GlobalEnums.DamageTag.POISON: 0.75,
		GlobalEnums.DamageTag.SHOCK: 0.75,
	},
} 

enum BuffableStats {
	AOE,
	ATTACK_SPEED,
	CRIT_CHANCE,
	DAMAGE,
	DEFENCE,
	MAX_HEALTH,
	MOVE_SPEED
}

enum AuraTargets {
	NONE,
	TOWERS,
	BADDIES,
}
