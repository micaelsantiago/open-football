class_name TestMatchEngine
extends RefCounted

const DataLoader = preload("res://src/systems/data_loader/data_loader.gd")
const GameStateClass = preload("res://src/core/state/game_state.gd")
const MatchSimulationClass = preload("res://src/core/match/match_simulation.gd")
const MatchEventClass = preload("res://src/core/match/match_event.gd")

static func run_all_tests() -> bool:
	print("\n=== [TEST SUITE] TestMatchEngine ===")
	var all_passed := true
	
	all_passed = test_deterministic_replay() and all_passed
	all_passed = test_instant_match_performance() and all_passed
	all_passed = test_interactive_stepping() and all_passed
	all_passed = test_tactical_mentality_influence() and all_passed
	all_passed = test_100_matches_goal_average() and all_passed
	
	if all_passed:
		print("=== [TEST SUITE] TestMatchEngine: TODOS OS TESTES PASSARAM! ===\n")
	else:
		push_error("=== [TEST SUITE] TestMatchEngine: FALHA EM TESTES! ===")
		
	return all_passed

static func test_deterministic_replay() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 555)
	
	var res1 = MatchSimulationClass.run_instant(state, "club-aurora-fc", "club-uniao-fc", "fixture_1", 1)
	var res2 = MatchSimulationClass.run_instant(state, "club-aurora-fc", "club-uniao-fc", "fixture_1", 1)
	
	assert(res1["home_score"] == res2["home_score"], "Placar mandante divergente em replay deterministico!")
	assert(res1["away_score"] == res2["away_score"], "Placar visitante divergente em replay deterministico!")
	assert(res1["home_shots"] == res2["home_shots"], "Finalizacoes mandante divergentes!")
	assert(res1["away_shots"] == res2["away_shots"], "Finalizacoes visitante divergentes!")
	assert(res1["events"].size() == res2["events"].size(), "Quantidade de eventos divergente!")
	
	print("[PASS] test_deterministic_replay: Reprodutibilidade 100%% garantida por semente derivada")
	return true

static func test_instant_match_performance() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 123)
	
	var start_time := Time.get_ticks_usec()
	for i in range(10):
		MatchSimulationClass.run_instant(state, "club-aurora-fc", "club-estrela-ec", "perf_test_%d" % i, 1)
	var total_usec = Time.get_ticks_usec() - start_time
	var avg_ms = float(total_usec) / 10000.0 # media em milissegundos por jogo
	
	print("[PASS] test_instant_match_performance: 10 partidas simuladas em %.2f ms (Media de %.3f ms por partida)" % [float(total_usec) / 1000.0, avg_ms])
	assert(avg_ms < 2.0, "Performance de simulacao instantanea insuficiente (> 2.0 ms)")
	return true

static func test_interactive_stepping() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 888)
	
	var home_c = state.get_club("club-aurora-fc")
	var away_c = state.get_club("club-uniao-fc")
	var h_players = []
	for pid in home_c.squad:
		h_players.append(state.get_player(pid))
	var a_players = []
	for pid in away_c.squad:
		a_players.append(state.get_player(pid))
		
	var rng = state.create_match_rng("step_test", 1)
	var sim = MatchSimulationClass.new(home_c, away_c, h_players, a_players, rng)
	
	var total_events := 0
	var saw_kickoff := false
	var saw_halftime := false
	var saw_fulltime := false
	
	for t in range(1, 31):
		var tick_events = sim.tick()
		total_events += tick_events.size()
		for evt in tick_events:
			if evt.type == MatchEventClass.Type.KICKOFF:
				saw_kickoff = true
			elif evt.type == MatchEventClass.Type.HALF_TIME:
				saw_halftime = true
			elif evt.type == MatchEventClass.Type.FULL_TIME:
				saw_fulltime = true
				
	assert(sim.is_finished, "Partida interativa deveria estar finalizada apos 30 ticks")
	assert(sim.current_minute == 90, "Minuto final deveria ser 90, obtido: %d" % sim.current_minute)
	assert(saw_kickoff, "Evento de apito inicial nao foi gerado")
	assert(saw_halftime, "Evento de intervalo nao foi gerado aos 45'")
	assert(saw_fulltime, "Evento de fim de jogo nao foi gerado aos 90'")
	
	print("[PASS] test_interactive_stepping: Reproducao tick a tick com 30 blocos de 3 minutos validada")
	return true

static func test_tactical_mentality_influence() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 42)
	
	var home_c = state.get_club("club-aurora-fc")
	var away_c = state.get_club("club-uniao-fc")
	var h_players = []
	for pid in home_c.squad:
		h_players.append(state.get_player(pid))
	var a_players = []
	for pid in away_c.squad:
		a_players.append(state.get_player(pid))
		
	var off_mult = MatchSimulationClass.new(home_c, away_c).get_mentality_multipliers("OFFENSIVE")
	var def_mult = MatchSimulationClass.new(home_c, away_c).get_mentality_multipliers("DEFENSIVE")
	var bal_mult = MatchSimulationClass.new(home_c, away_c).get_mentality_multipliers("BALANCED")
	
	assert(off_mult["ATK"] > bal_mult["ATK"], "Mentalidade ofensiva deve aumentar poder de ataque")
	assert(off_mult["DEF"] < bal_mult["DEF"], "Mentalidade ofensiva deve reduzir protecao defensiva")
	assert(def_mult["DEF"] > bal_mult["DEF"], "Mentalidade defensiva deve aumentar protecao defensiva")
	assert(def_mult["ATK"] < bal_mult["ATK"], "Mentalidade defensiva deve reduzir forca ofensiva")
	
	print("[PASS] test_tactical_mentality_influence: Modificadores taticos de postura verificados")
	return true

static func test_100_matches_goal_average() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 1000)
	
	var clubs_list = state.clubs.keys()
	var total_goals := 0
	var total_matches := 100
	
	for i in range(total_matches):
		var h_id = clubs_list[i % clubs_list.size()]
		var a_id = clubs_list[(i + 1) % clubs_list.size()]
		var res = MatchSimulationClass.run_instant(state, h_id, a_id, "sim_100_%d" % i, (i % 14) + 1)
		total_goals += (res["home_score"] + res["away_score"])
		
	var avg_goals: float = float(total_goals) / float(total_matches)
	print("[PASS] test_100_matches_goal_average: 100 partidas simuladas com total de %d gols (Media: %.2f gols/jogo)" % [total_goals, avg_goals])
	
	assert(avg_goals >= 2.0 and avg_goals <= 3.2, "Media de gols fora da faixa realista [2.0, 3.2]: %.2f" % avg_goals)
	return true
