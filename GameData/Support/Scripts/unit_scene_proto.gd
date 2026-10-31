@abstract ##prototype for baddy and towers for shared features
class_name UnitScenePrototype extends CollisionObject2D

signal unit_selected(unit: UnitScenePrototype)

@export_group("Unit Node Paths", "path_")
@export var path_mouse_detection: CollisionObject2D
@export var path_selection_circle: Sprite2D
#@export var path_unit_texture: Sprite2D

var data: UnitDataPrototype

var selected: bool = false

@abstract func get_level() -> int

func _ready() -> void:
	if data == null:
		return
	data.data_owner = self
	data.setup_stats(get_level())

func add_ability(ability: Ability, ability_source) -> void:
	var new_ability = ability.duplicate(true) #ability is duplicated to avoid shared instances (esp. important for periodic abilities)
	data.active_abilities.append(new_ability)
	new_ability.ability_setup(self, ability_source)
	display_update(new_ability)

func remove_ability(ability: Ability, ability_source) -> void:
	#match ability source before removing ability
	data.active_abilities.erase(ability)
	#display_update(ability)

@abstract func display_update(effect) -> void

##UnitProtoype function, directs effect to the appropriate add_ function
func add_effect(effect: Effect, effect_source: UnitScenePrototype = self ,cur_level: int = 0) -> void:
	if data == null:
		return
	if effect is Buff:
		data.add_buff(effect, effect_source, cur_level)
	elif effect is Ability:
		for ability in data.active_abilities:
			if effect.info_name == ability.info_name and ability.ability_source == effect_source: 
				return #prevent adding duplicate abilities from same source
			add_ability(effect, effect_source)

##UnitProtoype function, calls the remove_buff function in data resource, body defaults to self
func remove_effect(effect: Effect, effect_source: UnitScenePrototype = self, amt: int = 1) -> void:
	if data == null:
		return
	if effect is Buff:
		data.remove_buff(effect, effect_source, amt)
	elif effect is Ability:
		remove_ability(effect, effect_source)

func add_buff_aoe(buff: Buff, _body: UnitScenePrototype = self) -> void:
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
