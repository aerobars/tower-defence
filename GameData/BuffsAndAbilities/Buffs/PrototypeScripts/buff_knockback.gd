class_name BuffKnockback extends Buff

enum KnockbackType { PUSH, PULL }

@export_group("Knockback Data")
## Maximum knockback distance in pixels per level [1-5]
@export var knockback_strength: Array[float] = [150.0, 180.0, 210.0, 240.0, 270.0]
## Whether to push away from or pull toward the source
@export var knockback_type: KnockbackType = KnockbackType.PUSH
