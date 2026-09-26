class_name TestDataLoader
extends RefCounted

const DataLoader = preload("res://src/systems/data_loader/data_loader.gd")

static func run_all_tests() -> bool:
	print("\n=== [TEST SUITE] TestDataLoader ===")
	var all_passed := true
	
	all_passed = test_database_loading() and all_passed
	all_passed = test_clubs_integrity() and all_passed
	all_passed = test_players_clamping() and all_passed
	all_passed = test_competition_calendar() and all_passed
	
	if all_passed:
		print("=== [TEST SUITE] TestDataLoader: TODOS OS TESTES PASSARAM! ===\n")
	else:
		push_error("=== [TEST SUITE] TestDataLoader: FALHA EM TESTES! ===")
		
	return all_passed

static func test_database_loading() -> bool:
	var start_time := Time.get_ticks_msec()
	var db := DataLoader.load_database("res://data")
	var elapsed := Time.get_ticks_msec() - start_time
	
	assert(not db.is_empty(), "O banco de dados carregado esta vazio!")
	assert(db["errors"].is_empty(), "Erros encontrados durante a carga: %s" % str(db["errors"]))
	
	print("[PASS] test_database_loading: Carga completa executada em %d ms" % elapsed)
	assert(elapsed < 100, "Carga demorou mais de 100 ms (Performance insuficiente)!")
	return true

static func test_clubs_integrity() -> bool:
	var db := DataLoader.load_database("res://data")
	var clubs: Dictionary = db["clubs"]
	
	assert(clubs.size() == 8, "Esperado exatamente 8 clubes, encontrado: %d" % clubs.size())
	assert(clubs.has("club-aurora-fc"), "Clube Aurora FC nao foi encontrado!")
	
	var aurora: Dictionary = clubs["club-aurora-fc"]
	assert(aurora["reputation"] == 48, "Reputacao incorreta do Aurora FC")
	assert(aurora["squad"].size() == 16, "Aurora FC deve possuir 16 atletas no elenco!")
	
	print("[PASS] test_clubs_integrity: 8 clubes fundadores validados com sucesso")
	return true

static func test_players_clamping() -> bool:
	var db := DataLoader.load_database("res://data")
	var players: Dictionary = db["players"]
	
	assert(players.size() == 128, "Esperado exatamente 128 atletas (16 x 8 times), encontrado: %d" % players.size())
	
	for pid in players:
		var p: Dictionary = players[pid]
		assert(p.has("attributes"), "Atleta %s nao possui dicionario de atributos!" % pid)
		var tech: Dictionary = p["attributes"]["technical"]
		for attr_name in tech:
			var val: int = tech[attr_name]
			assert(val >= 1 and val <= 99, "Atributo %s do jogador %s fora da faixa 1-99: %d" % [attr_name, pid, val])
			
	print("[PASS] test_players_clamping: 128 atletas verificados com atributos seguros e normalizados")
	return true

static func test_competition_calendar() -> bool:
	var db := DataLoader.load_database("res://data")
	var comps: Dictionary = db["competitions"]
	
	assert(comps.has("comp-liga-inaugural"), "Liga Inaugural nao encontrada!")
	var liga: Dictionary = comps["comp-liga-inaugural"]
	var match_days: Array = liga["season_calendar"]["match_days"]
	
	assert(match_days.size() == 14, "Esperado 14 rodadas na Liga Inaugural, encontrado: %d" % match_days.size())
	
	for md in match_days:
		assert(md["fixtures"].size() == 4, "Cada rodada deve ter exatamente 4 confrontos!")
		
	print("[PASS] test_competition_calendar: Calendario de 14 rodadas e 56 confrontos validado")
	return true
