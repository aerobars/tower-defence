extends FoldableContainer

## Node Paths
@export_group("Node Paths", "path_")
@export var path_baddy_name: RichTextLabel
@export var path_baddy_health: RichTextLabel
@export var path_baddy_damage: RichTextLabel
@export var path_baddy_defence: RichTextLabel
@export var path_baddy_move_speed: RichTextLabel
@export var path_baddy_description: RichTextLabel

## Img Files
var img_health: Texture2D
var img_damage: Texture2D
var img_defence: Texture2D
var img_move_speed: Texture2D

var label_children: Array[RichTextLabel]
var baddy_id

func _ready() -> void:
	img_health = set_image(GameData.ICON_HEALTH_COORDS)
	img_damage = set_image(GameData.ICON_DAMAGE_COORDS)
	img_defence = set_image(GameData.ICON_DEFENCE_COORDS)
	img_move_speed = set_image(GameData.ICON_MOVE_SPEED_COORDS)
	for child in $VBoxContainer.get_children():
		if child is RichTextLabel:
			label_children.append(child)
		else:
			print("incorrect node type in Baddy Info Foldable")

func set_image(atlas_region: Rect2) -> Texture2D:
	var new_atlas = AtlasTexture.new()
	new_atlas.atlas = GameData.ICON_ATLAS
	new_atlas.region = atlas_region
	return new_atlas

func wave_display(wave_data) -> void:
	clear_display()
	var first : bool = true
	for baddy in wave_data:
		path_baddy_name.custom_minimum_size.y = 16
		path_baddy_name.add_image(baddy["data"].info_texture, 16, 16)
		if first:
			path_baddy_name.append_text(baddy["data"].info_name + " and ")
		else:
			path_baddy_name.append_text(baddy["data"].info_name)
		first = false
	set_folded(false)

func open_display(baddy) -> void:
	for child in label_children:
		child.custom_minimum_size.y = 16
	baddy_id = baddy
	update_display(baddy)
	set_folded(false)

##id = baddy scene reference
func update_display(baddy: Baddy) -> void:
	if baddy_id != baddy:
		return
	clear_display()
	path_baddy_name.add_image(baddy.data.info_texture, 16, 16)
	path_baddy_name.append_text(baddy.data.info_name)
	path_baddy_health.add_image(img_health, 16, 16)
	path_baddy_health.append_text(": " + str(baddy.data.health) + "/" + str(baddy.data.current_max_health))
	path_baddy_damage.add_image(img_damage, 16, 16)
	path_baddy_damage.append_text(": " + str(baddy.data.current_damage))
	path_baddy_defence.add_image(img_defence, 16, 16)
	path_baddy_defence.append_text(": " + str(baddy.data.current_defence))
	path_baddy_move_speed.add_image(img_move_speed, 16, 16)
	path_baddy_move_speed.append_text(": " + str(baddy.data.current_move_speed))
	path_baddy_description.append_text(baddy.data.info_description)

func _update_label(label: RichTextLabel, baddy: BaddyStats, img) -> void:
	label.add_image(img, 16, 16)
	label.append_text(baddy.data.info_name)

func close_display() -> void:
	for child in label_children:
		child.clear()
		child.custom_minimum_size.y = 0
	set_folded(true)

func clear_display() -> void:
	for child in label_children:
		child.clear()

func _depracated(baddy) -> void: #old text update function, just in case
	for child in label_children:
		match child.name:
			"Name":
				pass
		if child.text == "":
			if child.name == "Name":
				child.text = child.name + ": " + baddy.info_name
			elif child.name == "Description":
				child.text =  child.name + ": " + baddy.info_description
			else: 
				var stat_name : String = str("base_" + child.name.to_snake_case())
				child.text = child.name + ": " + str(baddy.get(stat_name))
		else:
			if child.name == "Name":
				child.text += " / " + baddy.info_name
			elif child.name == "Description":
				child.text +=  " / " + baddy.info_description
			else: 
				var stat_name : String = str("base_" + child.name.to_snake_case())
				child.text += " / " + str(baddy.get(stat_name))
