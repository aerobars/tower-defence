class_name ButtonModSlot extends Node2D

signal mod_updated(StaticBody2D, PrototypeMod) #connected to build buttons

var data : PrototypeMod
var occupied := false
var occupying_mod : ModDraggable


func _ready() -> void:
	modulate = Color(Color.AZURE, 0.7)

func _process(_delta: float) -> void:
	##when a tower mod is being dragged, highlight matching mod slots in tower slots
	if GameData.is_dragging:
		visible = true
	else:
		visible = false

func update(_data : PrototypeMod, _occupied : bool = occupied, _occupying_mod : ModDraggable = occupying_mod) -> void:
	occupied = _occupied
	data = _data
	occupying_mod = _occupying_mod
	mod_updated.emit(self, data)
