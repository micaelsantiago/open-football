class_name TestDomainState
extends RefCounted

const DataLoader = preload("res://src/systems/data_loader/data_loader.gd")
const PlayerDataClass = preload("res://src/core/player/player_data.gd")
const ClubDataClass = preload("res://src/core/club/club_data.gd")
const FacilityDataClass = preload("res://src/core/facility/facility_data.gd")
const CompetitionDataClass = preload("res://src/core/competition/competition_data.gd")
const GameStateClass = preload("res://src/core/state/game_state.gd")
const SeasonControllerClass = preload("res://src/core/calendar/season_controller.gd")

static func run_all_tests() -> bool:
	print("\n=== [TEST SUITE] TestDomainState ===")
	var all_passed := true
	
	all_passed = test_player_attributes_and_power() and all_passed
	all_passed = test_club_finances() and all_passed
	all_passed = test_facility_upgrades() and all_passed
	all_passed = test_competition_standings() and all_passed
	all_passed = test_game_state_deterministic_rng() and all_passed
	all_passed = test_full_season_14_rounds_cycle() and all_passed
	all_passed = test_game_state_serialization() and all_passed
	
	if all_passed:
		print("=== [TEST SUITE] TestDomainState: TODOS OS TESTES PASSARAM! ===\n")
	else:
		push_error("=== [TEST SUITE] TestDomainState: FALHA EM TESTES! ===")
		
	return all_passed

static func test_player_attributes_and_power() -> bool:
	var p = PlayerDataClass.new()
	p.id = "test-striker"
	p.primary_position = "ST"
	p.attributes["technical"]["finishing"] = 80
	p.attributes["physical"]["pace"] = 75
	p.attributes["mental"]["positioning"] = 70
	p.attributes["technical"]["heading"] = 65
	
	var ovr = p.calculate_overall()
	assert(ovr > 60 and ovr < 85, "Overall calculado fora da faixa esperada: %d" % ovr)
	
	var atk_power = p.calculate_effective_power("ATK")
	assert(atk_power > 50.0, "Poder de ataque insuficiente para atacante titular")
	
	# Testa lesao
	p.injured_rounds_remaining = 2
	assert(not p.is_available(), "Jogador lesionado deveria estar indisponivel")
	assert(p.calculate_effective_power("ATK") == 0.0, "Jogador lesionado deve ter poder efetivo 0")
	
	print("[PASS] test_player_attributes_and_power: Overall, forca e disponibilidade validados")
	return true

static func test_club_finances() -> bool:
	var club = ClubDataClass.new()
	club.id = "test-club"
	club.finances["balance"] = 100000
	
	assert(club.can_afford(50000), "Deveria ter saldo suficiente para 50.000")
	assert(not club.can_afford(150000), "Nao deveria ter saldo suficiente para 150.000")
	
	var debited = club.debit(30000)
	assert(debited, "Debito de 30.000 deveria ter sido aceito")
	assert(club.get_balance() == 70000, "Saldo apos debito incorreto: %d" % club.get_balance())
	
	club.credit(20000)
	assert(club.get_balance() == 90000, "Saldo apos credito incorreto: %d" % club.get_balance())
	
	print("[PASS] test_club_finances: Transacoes e checagens financeiras validadas")
	return true

static func test_facility_upgrades() -> bool:
	var fac = FacilityDataClass.new()
	fac.id = "test-stadium"
	fac.type = "STADIUM"
	fac.current_level = 1
	fac.levels = [
		{
			"level": 1,
			"name": "Nivel 1",
			"capacity": 3000,
			"maintenance_cost_per_round": 1000,
			"upgrade_cost": 0,
			"construction_time_rounds": 0
		},
		{
			"level": 2,
			"name": "Nivel 2",
			"capacity": 8000,
			"maintenance_cost_per_round": 2500,
			"upgrade_cost": 100000,
			"construction_time_rounds": 3
		}
	]
	
	assert(fac.get_current_capacity() == 3000, "Capacidade inicial deve ser 3000")
	assert(fac.can_upgrade(), "Instalacao de nivel 1 deveria permitir upgrade")
	
	var started = fac.start_upgrade()
	assert(started, "Falha ao iniciar upgrade")
	assert(fac.is_under_construction, "Instalacao deveria estar em obras")
	assert(fac.rounds_remaining == 3, "Deveriam restar 3 rodadas de obras")
	
	# Capacidade cai 25% durante obras
	assert(fac.get_current_capacity() == 2250, "Capacidade em obras deveria ser 2250 (75% de 3000)")
	
	# Tick 1
	var done = fac.tick_construction()
	assert(not done and fac.rounds_remaining == 2, "Tick 1 incorreto")
	
	# Tick 2
	done = fac.tick_construction()
	assert(not done and fac.rounds_remaining == 1, "Tick 2 incorreto")
	
	# Tick 3 (Conclusao)
	done = fac.tick_construction()
	assert(done, "Tick 3 deveria concluir a reforma")
	assert(not fac.is_under_construction, "Obra deveria ter finalizado")
	assert(fac.current_level == 2, "Nivel deveria ter subido para 2")
	assert(fac.get_current_capacity() == 8000, "Nova capacidade deveria ser 8000")
	
	print("[PASS] test_facility_upgrades: Ciclo completo de reforma e capacidade validado")
	return true

static func test_competition_standings() -> bool:
	var comp = CompetitionDataClass.new()
	comp.id = "test-comp"
	comp.participants = ["club-a", "club-b", "club-c"]
	comp.init_standings()
	
	comp.record_match_result(1, "club-a", "club-b", 2, 0)
	comp.record_match_result(1, "club-c", "club-b", 1, 1)
	
	var standings = comp.get_sorted_standings()
	assert(standings.size() == 3, "Tabela deve conter 3 equipes")
	
	# Club A: 1 jogo, 1 vitoria, 3 pts, SG +2
	assert(standings[0]["club_id"] == "club-a", "Lider deveria ser club-a")
	assert(standings[0]["points"] == 3, "Pontos incorretos para club-a")
	
	# Club C: 1 jogo, 1 empate, 1 pt, SG 0
	assert(standings[1]["club_id"] == "club-c", "Segundo colocado deveria ser club-c")
	assert(standings[1]["points"] == 1, "Pontos incorretos para club-c")
	
	# Club B: 2 jogos, 1 empate, 1 derrota, 1 pt, SG -2
	assert(standings[2]["club_id"] == "club-b", "Lanterna deveria ser club-b")
	assert(standings[2]["points"] == 1 and standings[2]["goal_difference"] == -2, "Status do club-b incorreto")
	
	print("[PASS] test_competition_standings: Tabela e criterios de desempate validados")
	return true

static func test_game_state_deterministic_rng() -> bool:
	var db = DataLoader.load_database("res://data")
	var state1 = GameStateClass.create_from_database(db, "club-aurora-fc", 9999)
	var state2 = GameStateClass.create_from_database(db, "club-aurora-fc", 9999)
	
	var rng1 = state1.create_match_rng("aurora_vs_uniao", 1)
	var rng2 = state2.create_match_rng("aurora_vs_uniao", 1)
	
	for i in range(10):
		var val1 = rng1.randi()
		var val2 = rng2.randi()
		assert(val1 == val2, "RNG deterministico gerou valores divergentes na iteracao %d" % i)
		
	print("[PASS] test_game_state_deterministic_rng: RNG deterministico por partida comprovado")
	return true

static func test_full_season_14_rounds_cycle() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 42)
	var controller = SeasonControllerClass.new(state)
	
	var aurora_stadium = state.get_facility("facility-estadio-aurora")
	assert(aurora_stadium != null, "Estadio do Aurora nao encontrado")
	aurora_stadium.start_upgrade() # 4 rodadas de obras
	assert(aurora_stadium.is_under_construction, "Estadio deveria estar em obras")
	
	var total_rounds = state.total_rounds
	assert(total_rounds == 14, "Esperado exatamente 14 rodadas")
	
	for r in range(1, total_rounds + 1):
		assert(controller.get_current_round() == r, "Rodada atual esperada: %d, atual: %d" % [r, controller.get_current_round()])
		var summary = controller.simulate_full_round()
		assert(summary["results"].size() == 4, "Cada rodada deve ter 4 resultados simulados")
		
	assert(controller.is_season_finished(), "Temporada deveria estar marcada como finalizada")
	assert(aurora_stadium.current_level == 2, "Estadio deveria ter sido concluido para nivel 2")
	assert(aurora_stadium.get_current_capacity() == 8500, "Capacidade do estadio nivel 2 deveria ser 8500")
	
	var comp = state.get_active_competition()
	assert(comp.is_season_completed(), "Competicao deveria constar como 100%% concluida")
	
	var standings = comp.get_sorted_standings()
	var total_goals_for := 0
	var total_goals_against := 0
	for row in standings:
		assert(row["played"] == 14, "Clube %s nao jogou as 14 partidas!" % row["club_id"])
		total_goals_for += row["goals_for"]
		total_goals_against += row["goals_against"]
		
	assert(total_goals_for == total_goals_against, "Soma de gols marcados deve ser igual a gols sofridos")
	
	print("[PASS] test_full_season_14_rounds_cycle: 14 rodadas simuladas com sucesso em memoria")
	return true

static func test_game_state_serialization() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 777)
	state.current_round = 5
	state.get_user_club().credit(50000)
	
	var dict = state.to_dict()
	var restored = GameStateClass.from_dict(dict)
	
	assert(restored.current_round == 5, "Rodada restaurada incorreta")
	assert(restored.user_club_id == "club-aurora-fc", "Clube do usuario restaurado incorreto")
	assert(restored.clubs.size() == 8, "Quantidade de clubes restaurados incorreta")
	assert(restored.players.size() == 128, "Quantidade de atletas restaurados incorreta")
	assert(restored.get_user_club().get_balance() == state.get_user_club().get_balance(), "Saldo restaurado incorreto")
	
	print("[PASS] test_game_state_serialization: Serializacao e desserializacao de GameState validadas")
	return true
