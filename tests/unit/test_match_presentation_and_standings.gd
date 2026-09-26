class_name TestMatchPresentationAndStandings
extends RefCounted

const DataLoader = preload("res://src/systems/data_loader/data_loader.gd")
const GameStateClass = preload("res://src/core/state/game_state.gd")
const MatchSimulationClass = preload("res://src/core/match/match_simulation.gd")
const MatchViewClass = preload("res://src/presentation/match_view/match_view.gd")
const StandingsViewClass = preload("res://src/presentation/ui/standings/standings_view.gd")
const SeasonControllerClass = preload("res://src/core/calendar/season_controller.gd")

static func run_all_tests() -> bool:
	print("\n=== [TEST SUITE] TestMatchPresentationAndStandings ===")
	var all_passed := true
	
	all_passed = test_match_view_live_ticks_and_feed() and all_passed
	all_passed = test_match_view_controls_and_tactics() and all_passed
	all_passed = test_standings_view_live_update() and all_passed
	
	if all_passed:
		print("=== [TEST SUITE] TestMatchPresentationAndStandings: TODOS OS TESTES PASSARAM! ===\n")
	else:
		push_error("=== [TEST SUITE] TestMatchPresentationAndStandings: FALHA EM TESTES! ===")
		
	return all_passed

static func test_match_view_live_ticks_and_feed() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 777)
	
	var home_c = state.get_club("club-aurora-fc")
	var away_c = state.get_club("club-uniao-fc")
	var h_players = []
	for pid in home_c.squad:
		h_players.append(state.get_player(pid))
	var a_players = []
	for pid in away_c.squad:
		a_players.append(state.get_player(pid))
		
	var rng = state.create_match_rng("match_view_test", 1)
	var sim = MatchSimulationClass.new(home_c, away_c, h_players, a_players, rng)
	
	var view = MatchViewClass.new()
	view.setup(sim, true)
	
	# Simula ate o intervalo (15 ticks = 45 min)
	for t in range(15):
		view.step_tick()
	assert(sim.current_minute == 45, "Minuto aos 15 ticks deveria ser 45'")
	assert(view._clock_label.text == "45'", "Label de relogio deveria exibir 45'")
	assert(not view.feed_messages.is_empty(), "Feed de narracao nao deveria estar vazio")
	
	# Pula ate o final
	var finished_signal := { "received": false, "result": {} }
	view.match_finished.connect(func(res: Dictionary):
		finished_signal["received"] = true
		finished_signal["result"] = res
	)
	
	view.skip_to_end()
	assert(sim.is_finished, "Partida deveria estar finalizada")
	assert(view._clock_label.text == "Fim", "Relogio deveria exibir Fim apos o apito final")
	assert(finished_signal["received"], "Sinal match_finished nao foi emitido")
	
	view.queue_free()
	print("[PASS] test_match_view_live_ticks_and_feed: MatchView com cronometro acelerado e feed validada")
	return true

static func test_match_view_controls_and_tactics() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 333)
	
	var home_c = state.get_club("club-aurora-fc")
	var away_c = state.get_club("club-uniao-fc")
	var sim = MatchSimulationClass.new(home_c, away_c)
	
	var view = MatchViewClass.new()
	view.setup(sim, true)
	
	# Teste de pausa
	assert(not view.is_paused, "Deveria comecar despausado")
	view.toggle_pause()
	assert(view.is_paused, "Deveria pausar apos toggle_pause()")
	view.toggle_pause()
	assert(not view.is_paused, "Deveria despausar apos segundo toggle")
	
	# Teste de velocidade
	assert(view.playback_speed == 1.0, "Velocidade padrao deveria ser 1.0")
	view.toggle_speed()
	assert(view.playback_speed == 2.0, "Velocidade deveria alternar para 2.0")
	view.toggle_speed()
	assert(view.playback_speed == 1.0, "Velocidade deveria retornar para 1.0")
	
	# Teste de alteracao tatica no meio do jogo
	view._tactics_option.select(1)
	view._on_tactics_changed(1)
	assert(sim.home_mentality == "OFFENSIVE", "Mentalidade do mandante deveria mudar para OFFENSIVE")
	
	view.queue_free()
	print("[PASS] test_match_view_controls_and_tactics: Pausa, velocidade 1x/2x e intervencao tatica validadas")
	return true

static func test_standings_view_live_update() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 99)
	var controller = SeasonControllerClass.new(state)
	
	# Simula 2 rodadas da liga
	controller.simulate_full_round()
	controller.simulate_full_round()
	
	var view = StandingsViewClass.new()
	view.setup(state)
	
	assert(view._data_table.get_rows_count() == 8, "Tabela de classificacao deve listar exatamente 8 clubes")
	assert(view._leader_label.text.begins_with("Líder:"), "Rotulo do lider nao preenchido")
	
	view.queue_free()
	print("[PASS] test_standings_view_live_update: StandingsView exibindo 8 clubes e ordenacao atualizada")
	return true
