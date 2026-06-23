@abstract ##prototype for baddy and towers for shared features
class_name UnitPrototype extends CollisionObject2D

signal unit_selected(unit: UnitPrototype)

@export_group("Unit Node Paths", "path_")
@export var path_mouse_detection : CollisionObject2D
@export var path_selection_circle : Sprite2D
@export var path_effect_aoe_container : Area2D

var selected : bool = false

func _ready() -> void:
	path_mouse_detection.input_event.connect(_on_input_event)
	path_mouse_detection.mouse_entered.connect(_on_mouse_entered)
	path_mouse_detection.mouse_exited.connect(_on_mouse_exited)

## Buff

##UnitProtoype function, calls the add_buff function in data resource, body defaults to self
func add_buff(buff : Buff, body : CollisionObject2D = self, cur_level : int = 0) -> void:
	body.data.add_buff(buff, cur_level)

##UnitProtoype function, calls the remove_buff function in data resource, body defaults to self
func remove_buff(buff: Buff, body : CollisionObject2D = self, cur_level : int = 0) -> void:
	body.data.remove_buff(buff)

func add_buff_aoe(buff : Buff, _body : CollisionObject2D = self) -> void:
		var new_aoe = EffectAoE.new()
		new_aoe.shape = CircleShape2D
		new_aoe.get_shape().radius = buff.buff_effect_aoe
		new_aoe.connected_buff = buff
		path_effect_aoe_container.add_child(new_aoe)

## Mouse Detection

##UnitProtoype function
func _on_mouse_entered() -> void:
	path_selection_circle.visible = true

##UnitProtoype function
func _on_mouse_exited() -> void:
	if not selected:
		path_selection_circle.visible = false

##UnitProtoype function
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		unit_selected.emit(self)

##UnitProtoype function
func set_selected(value: bool) -> void:
	selected = value
	if not selected:
		path_selection_circle.visible = false
