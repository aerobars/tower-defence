class_name ButtonModSlot extends Node2D

var data : PrototypeMod
var occupied := false
var occupying_mod : ModDraggable

signal mod_updated(StaticBody2D, PrototypeMod)

func _ready() -> void:
	modulate = Color(Color.AZURE, 0.7)

func _process(_delta: float) -> void:
	##when a tower mod is being dragged, highlight matching mod slots in tower slots
	if GameData.is_dragging:
		visible = true
	else:
		visible = false
	
	
