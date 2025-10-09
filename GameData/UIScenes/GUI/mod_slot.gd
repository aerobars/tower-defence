extends Node2D

var data : TowerMod
var occupied := false
var occupying_mod : Node2D

signal mod_updated

func _ready() -> void:
	modulate = Color(Color.AZURE, 0.7)

func _process(delta: float) -> void:
	##when a tower mod is being dragged, highlight matching mod slots in tower slots
	
	if GameData.is_dragging:
		visible = true
	else:
		visible = false
	
	
