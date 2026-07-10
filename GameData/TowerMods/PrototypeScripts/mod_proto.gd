@abstract
class_name ModPrototype extends UnitDataPrototype

enum ModClass { AURA, POWER, WEAPON }


var class_string : String: 
	get: 
		return ModClass.keys()[ModClass.values().find(mod_class)]

##Stats for all mod types
@export_group("Universal Mod Stats", "base_")
@export var base_power_levels : Array[int] = [-1, -1, -1, -1, -1]
##range is radius of range circle, default (26) is 1/2 tower base
@export var base_range_levels : Array[float] = [26, 26, 26, 26, 26] 
var current_power : int
var current_range : float
@export var mod_class : ModClass

@export_group("Swapper Data", "swap_")
@export var swap_enabled : bool
##Create buff in inspector, don't used saved resource
@export var swap_buff : Buff
@export var swap_buff_duration: float

##Innate onhit effects that tower starts with
@export var on_hit_effects : Array[Buff] = []
var net_power : int = 0
var power_surplus_buffs : Dictionary = {}
var power_calc : float :
	get:
		return (1 + float(net_power)/10) # * float(power_surplus_buffs[stat_name])/10)

func add_buff(buff : Buff, _buff_source : CollisionObject2D, buff_level : int, amt : int = 1) -> void:
	if buff.buff_targets == GlobalEnums.Targets.TOWERS or buff.buff_targets == GlobalEnums.Targets.SELF:
		super(buff, _buff_source, buff_level, amt)
	elif buff.buff_targets == GlobalEnums.Targets.BADDIES:
		add_on_hit_effect(buff)

func remove_buff(buff : Buff, buff_source : CollisionObject2D, amt : = 1) -> void:
	if buff is BuffStat and buff.buff_targets == GlobalEnums.Targets.TOWERS:
		super(buff, buff_source ,amt)
	else:
		remove_on_hit_effect(buff)

func add_on_hit_effect(_buff : Buff) -> void: #setup for Weapon Mods
	pass

func remove_on_hit_effect(_buff : Buff) -> void:#setup for Weapon Mods
	pass

func power_buff() -> void:
	for stat_name in power_surplus_buffs.keys():
		if buff_check(stat_name):
			var cur_property_name: String = str("current_" + stat_name)
			set(cur_property_name, get(cur_property_name) * power_calc)

@abstract
func set_current_stats() -> void
