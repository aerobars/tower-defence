@abstract ##prototype for baddy and towers for shared features
class_name UnitScenePrototype extends CollisionObject2D

signal unit_selected(unit: UnitScenePrototype)

@export_group("Unit Node Paths", "path_")
@export var path_mouse_detection : CollisionObject2D
@export var path_selection_circle : Sprite2D

var data : UnitDataPrototype

var selected : bool = false

@abstract func get_level() -> int

func _ready() -> void:
	if data != null:
		data.data_owner = self
		data.setup_stats(get_level())
	else:
		print("no data file detected")


##UnitProtoype function, calls the add_buff function in data resource, body defaults to self
func add_buff(buff : Buff, body : CollisionObject2D = self, cur_level : int = 0) -> void:
	body.data.add_buff(buff, self, cur_level) #self = buff_source

##UnitProtoype function, calls the remove_buff function in data resource, body defaults to self
func remove_buff(buff: Buff, body : CollisionObject2D = self, _cur_level : int = 0) -> void:
	body.data.remove_buff(buff, self)

func add_buff_aoe(buff : Buff, _body : CollisionObject2D = self) -> void:
	var new_aoe = EffectAoE.new()
	new_aoe.shape = CircleShape2D
	new_aoe.get_shape().radius = buff.buff_effect_aoe
	new_aoe.connected_buff = buff
#	path_effect_aoe_container.add_child(new_aoe)

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
