class_name ModDraggable extends Node2D

##Connected to inventory_ui
signal mod_dropped
#signal hovered(data: PrototypeMod)
#signal clear_popup

var data : ModPrototype

var draggable := false
var overlapping_slots: Array[TowerButtonModSlot] =[]
var inside_droppable: bool :
	get:
		return not overlapping_slots.is_empty()
var mod_slot_ref: TowerButtonModSlot
##mod_slot previously occupied by the draggable, so that mod slot will be updated with any changes as well 
var prev_slot_ref: TowerButtonModSlot

var offset:  Vector2
var initial_pos:  Vector2
var inventory_pos: Vector2
var in_inventory: bool = true

@onready var hover_timer := $Timer
@export var mod_icon: Sprite2D
const HOVER_DELAY: float = 0.5


func _ready() -> void:
	hover_timer.wait_time = HOVER_DELAY
	hover_timer.one_shot = true
	mod_icon.texture = data.info_texture

func _process(_delta: float) -> void:
	if draggable:
		if Input.is_action_just_pressed("ui_accept") and not in_inventory:
			initial_pos = global_position
			offset = get_global_mouse_position() - initial_pos
			GameData.is_dragging = true
		if Input.is_action_pressed("ui_accept"):
			scale = Vector2(0.6, 0.6)
			global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("ui_accept"):
			GameData.is_dragging = false
			droppable_check()
			draggable = false
			overlapping_slots.clear()

func droppable_check() -> void:
	var tween = get_tree().create_tween()
	if inside_droppable:
		mod_slot_ref = overlapping_slots.back()
		check_mod_slot_state(tween)
		tween.tween_property(self, "global_position", mod_slot_ref.global_position, 0.2).set_ease(Tween.EASE_OUT)
		in_inventory = false
		mod_slot_ref.lose_focus()
		prev_slot_ref = mod_slot_ref #for moving mods from one button slot to another
		mod_slot_ref.update(data, true, self)
	
	#if mod slot started in inventory and wasn't added to mod slot
	elif in_inventory: 
		tween.tween_property(self, "global_position", inventory_pos, 0.2).set_ease(Tween.EASE_OUT)
		await tween.finished
		queue_free()
	
	#if mod started in mod slot and removed back to inventory
	else: 
		tween.tween_property(self, "global_position", inventory_pos, 0.2).set_ease(Tween.EASE_OUT)
		mod_dropped.emit(data, 1)
		prev_slot_ref.update(null, false)
		await tween.finished
		queue_free()

func check_mod_slot_state(tween: Tween) -> void:
	#check if mod occupied a previous slot
	if prev_slot_ref != null: 
		prev_slot_ref.update(null, false, null)
	
	#check if mod slot is occupied with different mod
	if mod_slot_ref.occupied and mod_slot_ref.occupying_mod != self: 
		mod_slot_ref.occupying_mod.mod_dropped.emit(mod_slot_ref.occupying_mod.data, 1) #returns old mod back to inventory
		_run_tween_async(tween, mod_slot_ref.occupying_mod, "global_position", mod_slot_ref.occupying_mod.inventory_pos, 0.2) 
		mod_dropped.emit(data, -1) 
	elif not mod_slot_ref.occupied:
		mod_dropped.emit(data, -1)
	#unwritten else: stops inventory from subtracting if occupying mod is returned to same slot

func _run_tween_async(tween: Tween, object: ModDraggable, property: NodePath, end_pos: Variant, duration: float) -> void:
	tween.tween_property(object, property, end_pos, duration).set_ease(Tween.EASE_OUT)
	await tween.finished
	object.queue_free()

func _on_area_2d_mouse_entered() -> void: #react to player mousing over mod, scales when not in inventory
	#hover_timer.start()
	if not GameData.is_dragging and not in_inventory:
		draggable = true
		scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited() -> void:
	#clear_popup.emit()
	if not GameData.is_dragging:
		draggable = false
		if not in_inventory:
			scale = Vector2(1, 1)

func _on_timer_timeout() -> void:
	#if not GameData.is_dragging:
		#hovered.emit(data)
	pass

func _on_area_2d_body_entered(slot: TowerButtonModSlot) -> void: #react to player dragging over mod slot
	if not overlapping_slots.has(slot):
		overlapping_slots.append(slot)
	slot.get_focus()

func _on_area_2d_body_exited(slot: TowerButtonModSlot) -> void:
	overlapping_slots.erase(slot)
	slot.lose_focus()
