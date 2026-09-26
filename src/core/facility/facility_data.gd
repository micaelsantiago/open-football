class_name FacilityData
extends RefCounted

var id: String = ""
var club_id: String = ""
var type: String = "STADIUM" # STADIUM, TRAINING_CENTER, HEADQUARTERS
var name: String = ""
var grid_x: int = 0
var grid_y: int = 0
var current_level: int = 1

# Lista de niveis disponiveis da instalacao
var levels: Array = []

# Estado da reforma / expansao
var is_under_construction: bool = false
var target_level: int = 1
var rounds_remaining: int = 0

func get_current_level_data() -> Dictionary:
	for lvl in levels:
		if int(lvl.get("level", 1)) == current_level:
			return lvl
	if not levels.is_empty():
		return levels[0]
	return {}

func get_next_level_data() -> Dictionary:
	var next_lvl_idx = current_level + 1
	for lvl in levels:
		if int(lvl.get("level", 1)) == next_lvl_idx:
			return lvl
	return {}

func can_upgrade() -> bool:
	if is_under_construction:
		return false
	return not get_next_level_data().is_empty()

func get_current_capacity() -> int:
	if type != "STADIUM":
		return 0
	var lvl_data = get_current_level_data()
	var base_capacity = int(lvl_data.get("capacity", 0))
	if is_under_construction:
		# Durante reformas a capacidade cai em 25% temporariamente
		return int(base_capacity * 0.75)
	return base_capacity

func get_maintenance_cost() -> int:
	var lvl_data = get_current_level_data()
	return int(lvl_data.get("maintenance_cost_per_round", 0))

func start_upgrade() -> bool:
	if not can_upgrade():
		return false
	var next_lvl = get_next_level_data()
	var time_rounds = int(next_lvl.get("construction_time_rounds", 1))
	target_level = int(next_lvl.get("level", current_level + 1))
	
	if time_rounds <= 0:
		current_level = target_level
		is_under_construction = false
		rounds_remaining = 0
	else:
		is_under_construction = true
		rounds_remaining = time_rounds
	return true

## Avanca 1 rodada na construcao. Retorna true se a obra foi concluida neste ciclo.
func tick_construction() -> bool:
	if not is_under_construction:
		return false
	rounds_remaining -= 1
	if rounds_remaining <= 0:
		current_level = target_level
		is_under_construction = false
		rounds_remaining = 0
		return true
	return false

static func from_dict(dict: Dictionary) -> FacilityData:
	var f := FacilityData.new()
	f.id = str(dict.get("id", ""))
	f.club_id = str(dict.get("club_id", ""))
	f.type = str(dict.get("type", "STADIUM"))
	f.name = str(dict.get("name", ""))
	
	var world_pos = dict.get("world_position", {})
	if typeof(world_pos) == TYPE_DICTIONARY:
		f.grid_x = int(world_pos.get("grid_x", 0))
		f.grid_y = int(world_pos.get("grid_y", 0))
		
	f.current_level = int(dict.get("current_level", 1))
	
	if dict.has("levels") and typeof(dict["levels"]) == TYPE_ARRAY:
		f.levels = []
		for lvl in dict["levels"]:
			if typeof(lvl) == TYPE_DICTIONARY:
				f.levels.append(lvl.duplicate(true))
				
	var construction = dict.get("construction_state", {})
	if typeof(construction) == TYPE_DICTIONARY:
		f.is_under_construction = bool(construction.get("is_under_construction", false))
		f.target_level = int(construction.get("target_level", f.current_level))
		f.rounds_remaining = int(construction.get("rounds_remaining", 0))
		
	return f

func to_dict() -> Dictionary:
	return {
		"id": id,
		"club_id": club_id,
		"type": type,
		"name": name,
		"world_position": {
			"grid_x": grid_x,
			"grid_y": grid_y
		},
		"current_level": current_level,
		"levels": levels,
		"construction_state": {
			"is_under_construction": is_under_construction,
			"target_level": target_level,
			"rounds_remaining": rounds_remaining
		}
	}
