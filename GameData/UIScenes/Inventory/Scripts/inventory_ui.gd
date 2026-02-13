class_name InventoryUI extends Control

signal slot_created(new_slot)

const INVENTORY_SLOT = preload("res://GameData/UIScenes/Inventory/inventory_slot.tscn")

#InventoryData holds and array of SlotData and Update Inventory function
@export var data : InventoryData

@export var game_scene : Node2D


func _ready() -> void:
	await game_scene.ready
	data.inventory_ui = self
	if SaveManager.save_data_run.inventory_data == null:
		SaveManager.save_data_run.inventory_data = data
	else:
		data = SaveManager.save_data_run.inventory_data
	for i in data.slots:
		create_slot(i)

func update_slot(slot_data) -> void:
	for child in get_children():
		if slot_data.inventory_mod.name == child.slot_data.inventory_mod.name:
			child.set_slot_data(slot_data)
			if slot_data.quantity <= 0:
				remove_slot(child)

func create_slot(slot_data) -> void:
	var new_slot = INVENTORY_SLOT.instantiate()
	add_child(new_slot)
	new_slot.set_slot_data(slot_data)
	#signal connected to game_scene
	slot_created.emit(new_slot)

func remove_slot(mod_slot) -> void:
	mod_slot.queue_free()
