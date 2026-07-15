##Passes Aura Status, Power Surplus Buffs, and slot id and data 
##when Player updates a tower button's mod slot
class_name ModUpdateData extends Resource

var aura_status: bool
var power_surplus_buffs : Dictionary
var slot_id : int
var slot_data: ModPrototype

func _init(
	_aura_status : bool,
	_power_buffs : Dictionary,
	_slot_id : int = 0,
	_slot_data : ModPrototype = null
) -> void:
	aura_status = _aura_status
	power_surplus_buffs = _power_buffs
	slot_id = _slot_id
	slot_data = _slot_data
