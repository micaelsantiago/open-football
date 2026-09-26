class_name SaveManager
extends RefCounted

const GameStateClass = preload("res://src/core/state/game_state.gd")

const SAVES_BASE_DIR: String = "user://saves"

static func get_save_dir(slot_id: String) -> String:
	return "%s/%s" % [SAVES_BASE_DIR, slot_id]

static func save_game(state: RefCounted, slot_id: String = "carreira_default") -> Error:
	var dir_path = get_save_dir(slot_id)
	if not DirAccess.dir_exists_absolute(dir_path):
		var err = DirAccess.make_dir_recursive_absolute(dir_path)
		if err != OK:
			return err
			
	var tmp_path = "%s/game_state.json.tmp" % dir_path
	var final_path = "%s/game_state.json" % dir_path
	var meta_path = "%s/metadata.json" % dir_path
	
	# 1. Serializa GameState completo para o arquivo temporario (.tmp)
	var file = FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
		
	var state_dict = state.to_dict()
	var json_str = JSON.stringify(state_dict, "  ")
	file.store_string(json_str)
	file.flush()
	file.close()
	
	# 2. Renomeia atomicamente sobre o arquivo final
	var dir = DirAccess.open(dir_path)
	if dir != null:
		if dir.file_exists("game_state.json"):
			dir.remove("game_state.json")
		var ren_err = dir.rename(tmp_path, final_path)
		if ren_err != OK:
			return ren_err
			
	# 3. Grava metadata leve
	var meta_file = FileAccess.open(meta_path, FileAccess.WRITE)
	if meta_file != null:
		var club = state.get_user_club()
		var metadata = {
			"save_version": int(state.get("save_version")),
			"slot_id": slot_id,
			"career_name": str(state.get("career_name")),
			"club_id": str(state.get("user_club_id")),
			"club_name": club.name if club != null else "Meu Clube",
			"current_season": int(state.get("current_season")),
			"current_round": int(state.get("current_round")),
			"total_rounds": int(state.get("total_rounds")),
			"saved_at_unix": int(Time.get_unix_time_from_system())
		}
		meta_file.store_string(JSON.stringify(metadata, "  "))
		meta_file.flush()
		meta_file.close()
		
	return OK

static func load_game(slot_id: String = "carreira_default") -> RefCounted:
	var final_path = "%s/game_state.json" % get_save_dir(slot_id)
	if not FileAccess.file_exists(final_path):
		return null
		
	var file = FileAccess.open(final_path, FileAccess.READ)
	if file == null:
		return null
		
	var json_str = file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(json_str)
	if typeof(parsed) != TYPE_DICTIONARY:
		return null
		
	return GameStateClass.from_dict(parsed)

static func list_saves() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	if not DirAccess.dir_exists_absolute(SAVES_BASE_DIR):
		return results
		
	var dir = DirAccess.open(SAVES_BASE_DIR)
	if dir == null:
		return results
		
	dir.list_dir_begin()
	var slot_name = dir.get_next()
	while not slot_name.is_empty():
		if dir.current_is_dir() and not slot_name.begins_with("."):
			var meta_path = "%s/%s/metadata.json" % [SAVES_BASE_DIR, slot_name]
			if FileAccess.file_exists(meta_path):
				var m_file = FileAccess.open(meta_path, FileAccess.READ)
				if m_file != null:
					var m_json = JSON.parse_string(m_file.get_as_text())
					if typeof(m_json) == TYPE_DICTIONARY:
						results.append(m_json)
					m_file.close()
		slot_name = dir.get_next()
	dir.list_dir_end()
	
	results.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("saved_at_unix", 0)) > int(b.get("saved_at_unix", 0))
	)
	return results

static func has_save(slot_id: String = "carreira_default") -> bool:
	var final_path = "%s/game_state.json" % get_save_dir(slot_id)
	return FileAccess.file_exists(final_path)

static func delete_save(slot_id: String) -> bool:
	var dir_path = get_save_dir(slot_id)
	if not DirAccess.dir_exists_absolute(dir_path):
		return false
	var dir = DirAccess.open(dir_path)
	if dir == null:
		return false
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir():
			dir.remove(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	return DirAccess.remove_absolute(dir_path) == OK
