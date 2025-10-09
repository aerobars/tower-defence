class_name ModDraggable extends Node2D

var draggable := false
var inside_droppable := false
var mod_slot_ref : StaticBody2D
var offset : Vector2
var initial_pos :  Vector2
var inventory_pos : Vector2
var in_inventory : bool = true

var data : TowerMod

signal mod_dropped

func _process(delta: float) -> void:
	if draggable:
		if Input.is_action_just_pressed("click") and not in_inventory:
			initial_pos = global_position
			offset = get_global_mouse_position() - initial_pos
			GameData.is_dragging = true
		if Input.is_action_pressed("click"):
			global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("click"):
			GameData.is_dragging = false
			var tween = get_tree().create_tween()
			if inside_droppable:
				tween.tween_property(self, "global_position", mod_slot_ref.global_position,0.2).set_ease(Tween.EASE_OUT)
				in_inventory = false
				mod_slot_ref.data = data
				#check if mod slot is occupied with different mod
				if mod_slot_ref.occupied && mod_slot_ref.occupying_mod != self:
					#returns old mod back to inventory
					mod_slot_ref.occupying_mod.mod_dropped.emit(data, 1)
					#signals built towers to update associated mods
					mod_slot_ref.mod_updated.emit(mod_slot_ref, data)
					tween.tween_property(mod_slot_ref.occupying_mod, "global_position", inventory_pos,0.2).set_ease(Tween.EASE_OUT)
					await tween.finished
					mod_slot_ref.occupying_mod.queue_free()
					#print("success!")
				mod_slot_ref.occupied = true
				mod_slot_ref.occupying_mod = self
				mod_dropped.emit(data, -1)
				#print("test1")
				#mod_slot_ref.get_parent().data
			elif in_inventory:
				tween.tween_property(self, "global_position", initial_pos,0.2).set_ease(Tween.EASE_OUT)
				#print("test2")
				await tween.finished
				queue_free()
			else:
				tween.tween_property(self, "global_position", inventory_pos,0.2).set_ease(Tween.EASE_OUT)
				mod_dropped.emit(data, 1)
				mod_slot_ref.occupied = false
				#print("test3")
				await tween.finished
				queue_free()


#react to player mousing over mod when not in inventory
func _on_area_2d_mouse_entered() -> void:
	if not GameData.is_dragging and not in_inventory:
		draggable = true
		scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited() -> void:
	if not GameData.is_dragging:
		draggable = false
		if not in_inventory:
			scale = Vector2(1, 1)

#react to player dragging over mod slot
func _on_area_2d_body_entered(body: StaticBody2D) -> void:
	if body.is_in_group("droppable"):
		inside_droppable = true
		body.modulate = Color(Color.BISQUE, 1)
		mod_slot_ref = body


func _on_area_2d_body_exited(body: StaticBody2D) -> void:
		if body.is_in_group("droppable"):
			inside_droppable = false
			body.modulate = Color(Color.AZURE, 0.7)
