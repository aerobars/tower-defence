class_name AllDamageTags extends Resource

enum DamageTag {
	BLEED,
	BLUNT,
	BURN,
	HEAL,
	PIERCE,
	POISON,
	SHOCK,
}

enum BaddyArmorTags {
	UNARMORED,
	LIGHT,
	MEDIUM,
	HEAVY
}

const DEFENCE_TABLE : Dictionary = {
	BaddyArmorTags.UNARMORED: {
		AllDamageTags.DamageTag.BLEED: 1.0,
		AllDamageTags.DamageTag.BLUNT: 1.0,
		AllDamageTags.DamageTag.BURN: 1.1,
		AllDamageTags.DamageTag.PIERCE: 1.0,
		AllDamageTags.DamageTag.POISON: 1.0,
		AllDamageTags.DamageTag.SHOCK: 0.75,
	},
	BaddyArmorTags.LIGHT: {
		AllDamageTags.DamageTag.BLEED: 1.0,
		AllDamageTags.DamageTag.BLUNT: 1.0,
		AllDamageTags.DamageTag.BURN: 1.0,
		AllDamageTags.DamageTag.PIERCE: 1.0,
		AllDamageTags.DamageTag.POISON: 1.0,
		AllDamageTags.DamageTag.SHOCK: 0.75,
	},
	BaddyArmorTags.MEDIUM: {
		AllDamageTags.DamageTag.BLEED: 1.0,
		AllDamageTags.DamageTag.BLUNT: 1.0,
		AllDamageTags.DamageTag.BURN: 1.0,
		AllDamageTags.DamageTag.PIERCE: 1.0,
		AllDamageTags.DamageTag.POISON: 1.0,
		AllDamageTags.DamageTag.SHOCK: 0.75,
	},
	BaddyArmorTags.HEAVY: {
		AllDamageTags.DamageTag.BLEED: 0.75,
		AllDamageTags.DamageTag.BLUNT: 0.75,
		AllDamageTags.DamageTag.BURN: 0.75,
		AllDamageTags.DamageTag.PIERCE: 0.75,
		AllDamageTags.DamageTag.POISON: 0.75,
		AllDamageTags.DamageTag.SHOCK: 0.75,
	},
} 
