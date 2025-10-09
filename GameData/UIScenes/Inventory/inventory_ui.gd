class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("res://GameData/UIScenes/Inventory/inventory_slot.tscn")

#InventoryData holds and array of SlotData and Update Inventory function
@export var data : InventoryData

signal slot_created(new_slot)

func _ready() -> void:
	await $"../../../../..".ready
	for i in data.slots:
		create_slot(i)

func clear_inventory() -> void:
	for i in get_children():
		i.queue_free()

func update_inventory(tower_mod: TowerMod, value: int) -> void:
	data.update_inventory(tower_mod, value)
	for i in data.slots:
		if get_children().size() > 0:
			for child in get_children():
				if i.tower_mod.name == child.slot_data.tower_mod.name:
					child.update_amount(i.quantity)
				else:
					create_slot(i)
		else:
			create_slot(i)

func create_slot(slot_data) -> void:
	var new_slot = INVENTORY_SLOT.instantiate()
	add_child(new_slot)
	new_slot.set_slot_data(slot_data)
	slot_created.emit(new_slot)
