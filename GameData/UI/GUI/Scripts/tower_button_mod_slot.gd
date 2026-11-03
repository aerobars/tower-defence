class_name TowerButtonModSlot extends StaticBody2D

##Connected to build buttons
signal mod_updated(slot_id : int, data : ModPrototype) 

var slot_id: int
var occupied := false
var occupying_mod: ModDraggable
#var data : PrototypeMod

func _ready() -> void:
	modulate = Color(Color.AZURE, 0.7)

func _process(_delta: float) -> void:
	##when a tower mod is being dragged, highlight matching mod slots in tower slots
	if GameData.is_dragging:
		visible = true
	else:
		visible = false

func get_focus() -> void:
	modulate = Color(Color.BISQUE, 1)

func lose_focus() -> void:
	modulate = Color(Color.AZURE, 0.7)

func update(_data: ModPrototype, _occupied: bool = occupied, _occupying_mod: ModDraggable = occupying_mod) -> void:
	occupied = _occupied
	#data = _data
	occupying_mod = _occupying_mod
	mod_updated.emit(slot_id, _data)
