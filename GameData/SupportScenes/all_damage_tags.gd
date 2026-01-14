class_name AllDamageTags extends Resource

enum DamageTag {
	BLUNT,
	BURN,
	CONCUSSIVE,
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
		AllDamageTags.DamageTag.BURN: 1.5,
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
		AllDamageTags.DamageTag.BLUNT: 1.0,
		AllDamageTags.DamageTag.BURN: 1.0,
		AllDamageTags.DamageTag.CONCUSSIVE: 1.0,
		AllDamageTags.DamageTag.PIERCE: 1.0,
		AllDamageTags.DamageTag.POISON: 1.0,
	},
} 
