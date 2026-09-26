class_name DataLoader
extends RefCounted

const DataSanitizer = preload("res://src/systems/data_loader/data_sanitizer.gd")

## Carrega a base de dados completa (manifesto, clubes, atletas, instalacoes e competicoes)
static func load_database(base_dir: String = "res://data") -> Dictionary:
	var result := {
		"manifest": {},
		"clubs": {},
		"players": {},
		"facilities": {},
		"competitions": {},
		"errors": []
	}
	
	# 1. Carrega Manifesto (mod.json)
	var manifest_path := "%s/mod.json" % base_dir
	if FileAccess.file_exists(manifest_path):
		result["manifest"] = _read_json_file(manifest_path)
	else:
		result["errors"].append("Manifesto mod.json nao encontrado em: %s" % manifest_path)
		
	# 2. Carrega Clubes
	var clubs_dir := "%s/clubs" % base_dir
	for club_file in _list_json_files(clubs_dir):
		var raw_club = _read_json_file(club_file)
		if typeof(raw_club) == TYPE_DICTIONARY and raw_club.has("id"):
			var clean_club = DataSanitizer.sanitize_club(raw_club)
			result["clubs"][clean_club["id"]] = clean_club
			
	# 3. Carrega Jogadores (suporta objetos individuais ou arrays de jogadores)
	var players_dir := "%s/players" % base_dir
	for player_file in _list_json_files(players_dir):
		var parsed = _read_json_file(player_file)
		if typeof(parsed) == TYPE_ARRAY:
			for item in parsed:
				if typeof(item) == TYPE_DICTIONARY and item.has("id"):
					var clean_p = DataSanitizer.sanitize_player(item)
					result["players"][clean_p["id"]] = clean_p
		elif typeof(parsed) == TYPE_DICTIONARY and parsed.has("id"):
			var clean_p = DataSanitizer.sanitize_player(parsed)
			result["players"][clean_p["id"]] = clean_p
			
	# 4. Carrega Instalacoes
	var facilities_dir := "%s/facilities" % base_dir
	for fac_file in _list_json_files(facilities_dir):
		var raw_fac = _read_json_file(fac_file)
		if typeof(raw_fac) == TYPE_DICTIONARY and raw_fac.has("id"):
			var clean_fac = DataSanitizer.sanitize_facility(raw_fac)
			result["facilities"][clean_fac["id"]] = clean_fac
			
	# 5. Carrega Competicoes
	var comp_dir := "%s/competitions" % base_dir
	for comp_file in _list_json_files(comp_dir):
		var raw_comp = _read_json_file(comp_file)
		if typeof(raw_comp) == TYPE_DICTIONARY and raw_comp.has("id"):
			result["competitions"][raw_comp["id"]] = raw_comp
			
	# 6. Checagem de Integridade Referencial
	_verify_referential_integrity(result)
	
	return result

## Verifica consistencia cruzada entre clubes, atletas e instalacoes
static func _verify_referential_integrity(db: Dictionary) -> void:
	var valid_player_ids = db["players"].keys()
	
	for club_id in db["clubs"]:
		var club = db["clubs"][club_id]
		var clean_squad: Array = []
		
		# Valida jogadores do elenco
		for pid in club.get("squad", []):
			if pid in valid_player_ids:
				clean_squad.append(pid)
			else:
				db["errors"].append("Clube %s referencia atleta inexistente: %s" % [club_id, pid])
		club["squad"] = clean_squad

static func _read_json_file(file_path: String) -> Variant:
	if not FileAccess.file_exists(file_path):
		return null
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return null
	var text := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var error := json.parse(text)
	if error != OK:
		push_error("Erro de parse JSON no arquivo %s: %s (linha %d)" % [file_path, json.get_error_message(), json.get_error_line()])
		return null
	return json.data

static func _list_json_files(dir_path: String) -> Array[String]:
	var files: Array[String] = []
	if not DirAccess.dir_exists_absolute(dir_path):
		return files
		
	var dir := DirAccess.open(dir_path)
	if not dir:
		return files
		
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			files.append("%s/%s" % [dir_path, file_name])
		file_name = dir.get_next()
	dir.list_dir_end()
	
	return files
