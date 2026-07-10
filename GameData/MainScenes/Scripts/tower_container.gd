extends Node2D

signal new_tower_built(new_tower: TowerBase)
signal tower_upgraded(upgrade_cost)
signal tower_sold(sell_value: int, tower: TowerBase)

const TOWER_BASE_SCENE := preload("res://GameData/Towers/Scenes/tower_base.tscn")

func create_tower(
	_build_data: TowerBuildData, 
	connected_btn: BuildTowerButton, 
	_build_location: Vector2,
	_build_rotation: float, 
	level: int = 0,
	saved_tower: bool = false,
	) -> void:
	
	var new_tower = TOWER_BASE_SCENE.instantiate()
	
	new_tower.build_data = _build_data
	new_tower.tower_data = TowerBaseData.new()
	new_tower.tower_data.connected_button_id = connected_btn.button_data.button_id
	new_tower.tower_data.level = level
	new_tower.tower_data.position = _build_location
	new_tower.position = new_tower.tower_data.position
	new_tower.is_built = true
	
	connected_btn.update_towers.connect(new_tower.tower_update)
	
	if not saved_tower:
		SaveManager.save_data_run.tower_data.append(new_tower.tower_data)
		new_tower.rotation = _build_rotation
	else:
		new_tower.rotation = new_tower.tower_data.rotation
	
	add_child(new_tower, true)
	
	new_tower_built.emit(new_tower)

func upgrade_check(upgrade_cost : int, tower : TowerBase, popup : TowerPopup) -> void:
	if get_parent().check_cash(upgrade_cost):
		tower.level_up()
		popup.setup_stats()
		tower_upgraded.emit(upgrade_cost)

func sell_tower(sell_value : int, tower : TowerBase) -> void:
	tower_sold.emit(sell_value, tower)
	tower.queue_free()
