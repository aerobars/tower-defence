class_name InventorySlotUi extends Button

signal hovered(info_popup, data: PrototypeMod)
signal clear_popup

#SlotData holds TowerMod and quantity
var slot_data : SlotData : set = set_slot_data

@onready var image : TextureRect = $TextureRect
@onready var amount : Label = $ColorRect/Label
@onready var hover_timer = $Timer

const HOVER_DELAY : float = 0.5
const POPUP_TYPE : String = "info"


#timer timeout signal connected to game_scene
func _ready() -> void:
	hover_timer.wait_time = HOVER_DELAY
	hover_timer.one_shot = true

func set_slot_data(value: SlotData):
	slot_data = value
	#if statement only needed if I want empty inventory slots
	#if slot_data == null:
	#	return
	image.texture = value.tower_mod.texture
	amount.text = str(value.quantity)

func _on_mouse_entered() -> void:
	hover_timer.start()

func _on_mouse_exited() -> void:
	hover_timer.stop()
	clear_popup.emit()

func _on_timer_timeout() -> void:
	hovered.emit(POPUP_TYPE, slot_data.tower_mod)
