class_name InventoryData extends Resource

#SlotData holds TowerMod and quantity
@export var slots: Array[InventorySlotData]

var inventory_ui : InventoryUI

func update_inventory(mod: PrototypeMod, value: int = 1) -> void:
	for i in slots: #check if mod exists in inventory and increment
		if i.inventory_mod.name == mod.name:
			i.quantity += value
			inventory_ui.update_slot(i)
			slots = slots.filter(func(slot): return slot.quantity > 0)
			return
	if value != -1: #confirmed not in inventory, make new slot
		var new_slot = InventorySlotData.new()
		new_slot.inventory_mod = mod
		new_slot.quantity = value
		slots.append(new_slot)
		inventory_ui.create_slot(new_slot)
