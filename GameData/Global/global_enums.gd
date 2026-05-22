class_name GlobalEnums extends Resource

enum DamageTag {
	BLUNT = 1 << 1, #2
	PIERCE = 1 << 4, # 16, weapon damage types first to maintain additives before mulitplicatives in damage calculation
	BLEED = 1 << 0, #1
	BURN = 1 << 2, #4
	POISON = 1 << 5, #32
	SHOCK = 1 << 6, #64
	HEAL = 1 << 3, #8
}

enum BaddyArmorTags {
	UNARMORED,
	LIGHT,
	MEDIUM,
	HEAVY
}

const DEFENCE_TABLE : Dictionary = {
	BaddyArmorTags.UNARMORED: { #Nakies
		GlobalEnums.DamageTag.BLEED: 1.5,
		GlobalEnums.DamageTag.BLUNT: 1.5,
		GlobalEnums.DamageTag.BURN: 1.5,
		GlobalEnums.DamageTag.PIERCE: 1.0,
		GlobalEnums.DamageTag.POISON: 1.5,
		GlobalEnums.DamageTag.SHOCK: 1,
	},
	BaddyArmorTags.LIGHT: { #Cloth
		GlobalEnums.DamageTag.BLEED: 1.0,
		GlobalEnums.DamageTag.BLUNT: 1.0,
		GlobalEnums.DamageTag.BURN: 2.0,
		GlobalEnums.DamageTag.PIERCE: 1.0,
		GlobalEnums.DamageTag.POISON: 1.0,
		GlobalEnums.DamageTag.SHOCK: 1,
	},
	BaddyArmorTags.MEDIUM: { #Leather Daddy
		GlobalEnums.DamageTag.BLEED: 0.75,
		GlobalEnums.DamageTag.BLUNT: 0.75,
		GlobalEnums.DamageTag.BURN: 0.75,
		GlobalEnums.DamageTag.PIERCE: 1.5,
		GlobalEnums.DamageTag.POISON: 0.75,
		GlobalEnums.DamageTag.SHOCK: 0.5,
	},
	BaddyArmorTags.HEAVY: { #Metal Armor
		GlobalEnums.DamageTag.BLEED: 0.5,
		GlobalEnums.DamageTag.BLUNT: 0.5,
		GlobalEnums.DamageTag.BURN: 0.5,
		GlobalEnums.DamageTag.PIERCE: 0.75,
		GlobalEnums.DamageTag.POISON: 0.5,
		GlobalEnums.DamageTag.SHOCK: 1.5,
	},
} 

enum BuffableStats {
	AOE = 1 << 0, #1
	ATTACK_SPEED = 1 << 1, #2
	CRIT_CHANCE = 1 << 2, #4
	CRIT_DAMAGE = 1 << 7, #128
	DAMAGE = 1 << 3, #8
	DEFENCE = 1 << 4, #16
	MAX_HEALTH = 1 << 5, #32
	MOVE_SPEED = 1 << 6, #64
	RANGE = 1 << 8, #256
}

enum Targets {
	NONE,
	TOWERS,
	BADDIES,
	SELF,
}
