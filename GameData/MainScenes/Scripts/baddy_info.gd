extends FoldableContainer


func update_baddy_info(baddy) -> void:
	$VBoxContainer/Name.text = "Name: " + baddy.name.replace("([a-z])([A-Z])", "$1 $2")
	$VBoxContainer/Health.text = "Health: " + str(baddy.data.base_max_health)
	$VBoxContainer/Damage.text = "Damage: " + str(baddy.data.base_damage)
	$VBoxContainer/Defence.text = "Defence: " + str(baddy.data.base_defence)
	$VBoxContainer/MoveSpeed.text = "Move Speed: " + str(baddy.data.base_move_speed)
	$VBoxContainer/Description.text = "baddy description goes here"
	set_folded(false)
