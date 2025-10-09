class_name InventorySlotUi extends Button

#SlotData holds TowerMod and quantity
var slot_data : SlotData : set = set_slot_data

@onready var image : TextureRect = $TextureRect
@onready var amount : Label = $Label

func _ready() -> void:
	pass

func set_slot_data(value: SlotData):
	slot_data = value
	#if statement only needed if I want empty inventory slots
	#if slot_data == null:
	#	return
	image.texture = value.tower_mod.texture
	amount.text = str(value.quantity)

func update_amount(value: int) -> void:
	amount.text = str(value)
