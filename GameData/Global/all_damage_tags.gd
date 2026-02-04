class_name AllDamageTags extends Resource

enum DamageTag {
	BLEED,
	BLUNT,
	BURN,
	CONCUSSIVE,
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
		AllDamageTags.DamageTag.BLUNT: 1.0,
		AllDamageTags.DamageTag.BURN: 1.0,
		AllDamageTags.DamageTag.CONCUSSIVE: 1.0,
		AllDamageTags.DamageTag.PIERCE: 1.5,
		AllDamageTags.DamageTag.POISON: 1.0,
	},
	BaddyArmorTags.LIGHT: {
		AllDamageTags.DamageTag.BLUNT: 1.0,
		AllDamageTags.DamageTag.BURN: 1.0,
		AllDamageTags.DamageTag.CONCUSSIVE: 1.0,
		AllDamageTags.DamageTag.PIERCE: 1.0,
		AllDamageTags.DamageTag.POISON: 1.0,
	},
	BaddyArmorTags.MEDIUM: {
		AllDamageTags.DamageTag.BLUNT: 1.0,
		AllDamageTags.DamageTag.BURN: 1.0,
		AllDamageTags.DamageTag.CONCUSSIVE: 1.0,
		AllDamageTags.DamageTag.PIERCE: 1.0,
		AllDamageTags.DamageTag.POISON: 1.0,
	},
	BaddyArmorTags.HEAVY: {
		AllDamageTags.DamageTag.BLUNT: 0.75,
		AllDamageTags.DamageTag.BURN: 0.75,
		AllDamageTags.DamageTag.CONCUSSIVE: 0.75,
		AllDamageTags.DamageTag.PIERCE: 0.75,
		AllDamageTags.DamageTag.POISON: 0.75,
		AllDamageTags.DamageTag.SHOCK: 0.75,
	},
} 
