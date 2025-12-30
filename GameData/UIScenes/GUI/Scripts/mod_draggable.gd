class_name ModDraggable extends Node2D

signal mod_dropped #connected to inventory_ui
signal hovered(data: TowerMod)
signal clear_popup

var data : TowerMod

var draggable := false
var inside_droppable := false
var mod_slot_ref : StaticBody2D

var offset : Vector2
var initial_pos :  Vector2
var inventory_pos : Vector2
var in_inventory : bool = true

@onready var hover_timer := $Timer
const HOVER_DELAY : float = 0.5



func _ready() -> void:
	hover_timer.wait_time = HOVER_DELAY
	hover_timer.one_shot = true
	scale = Vector2(0.6, 0.6)

func _process(_delta: float) -> void:
	if draggable:
		if Input.is_action_just_pressed("click") and not in_inventory:
			initial_pos = global_position
			offset = get_global_mouse_position() - initial_pos
			GameData.is_dragging = true
		if Input.is_action_pressed("click"):
			global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("click"):
			GameData.is_dragging = false
			droppable_check()

func droppable_check() -> void:
	var tween = get_tree().create_tween()
	if inside_droppable:
		tween.tween_property(self, "global_position", mod_slot_ref.global_position, 0.2).set_ease(Tween.EASE_OUT)
		in_inventory = false
		mod_slot_ref.data = data
		
		if mod_slot_ref.occupied and mod_slot_ref.occupying_mod != self: #check if mod slot is occupied with different mod
			mod_slot_ref.occupying_mod.mod_dropped.emit(mod_slot_ref.occupying_mod.data, 1) #returns old mod back to inventory
			_run_tween_async(tween, mod_slot_ref.occupying_mod, "global_position", mod_slot_ref.occupying_mod.inventory_pos, 0.2) 
			mod_dropped.emit(data, -1) #mod_updated connected to inventory_ui
		#elif stops inventory from subtracting if occupying mod is returned to same slot
		elif not mod_slot_ref.occupied:
			mod_dropped.emit(data, -1)
		#signals built towers to update associated mods
		mod_slot_ref.mod_updated.emit(mod_slot_ref, data)
		mod_slot_ref.occupied = true
		mod_slot_ref.occupying_mod = self
		#mod_slot_ref.get_parent().data
	elif in_inventory:
		tween.tween_property(self, "global_position", initial_pos, 0.2).set_ease(Tween.EASE_OUT)
		#print("test2")
		await tween.finished
		queue_free()
	else:
		tween.tween_property(self, "global_position", inventory_pos, 0.2).set_ease(Tween.EASE_OUT)
		mod_dropped.emit(data, 1)
		mod_slot_ref.occupied = false
		#print("test3")
		await tween.finished
		queue_free()
	draggable = false

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

func _on_area_2d_body_entered(body: StaticBody2D) -> void: #react to player dragging over mod slot
	if body.is_in_group("droppable"):
		inside_droppable = true
		body.modulate = Color(Color.BISQUE, 1)
		mod_slot_ref = body

func _on_area_2d_body_exited(body: StaticBody2D) -> void:
		if body.is_in_group("droppable"):
			inside_droppable = false
			body.modulate = Color(Color.AZURE, 0.7)
