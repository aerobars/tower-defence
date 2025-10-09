class_name InventoryData extends Resource

#SlotData holds TowerMod and quantity
@export var slots: Array[SlotData]

func update_inventory(tower_mod: TowerMod, value: int) -> void:
	#check if mod exists in inventory and increment
	for i in slots:
		if i.tower_mod.name == tower_mod.name:
			i.quantity += value
	#confirmed not in inventory, make new slot
	if value != -1:
		var new_slot = SlotData.new()
		new_slot.tower_mod = tower_mod
		new_slot.quantity = value
	#remove slots without remaining mods
	slots = slots.filter(func(slot): return slot.quantity > 0)
