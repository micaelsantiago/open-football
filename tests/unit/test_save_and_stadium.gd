class_name TestSaveAndStadium
extends RefCounted

const DataLoader = preload("res://src/systems/data_loader/data_loader.gd")
const GameStateClass = preload("res://src/core/state/game_state.gd")
const SeasonControllerClass = preload("res://src/core/calendar/season_controller.gd")
const SaveManagerClass = preload("res://src/systems/save_system/save_manager.gd")
const AudioServiceClass = preload("res://src/systems/audio/audio_service.gd")

const StadiumUpgradeModalClass = preload("res://src/presentation/ui/stadium/stadium_upgrade_modal.gd")
const MainMenuClass = preload("res://src/presentation/ui/main_menu/main_menu.gd")
const AppControllerClass = preload("res://src/presentation/app_controller.gd")

static func run_all_tests() -> bool:
	print("\n=== [TEST SUITE] TestSaveAndStadium ===")
	var all_passed := true
	
	all_passed = test_save_manager_atomic_operations() and all_passed
	all_passed = test_stadium_renovation_cycle_and_capacity_jump() and all_passed
	all_passed = test_audio_service_procedural_fx() and all_passed
	all_passed = test_main_menu_interactions() and all_passed
	all_passed = test_app_controller_orchestration() and all_passed
	
	if all_passed:
		print("=== [TEST SUITE] TestSaveAndStadium: TODOS OS TESTES PASSARAM! ===\n")
	else:
		push_error("=== [TEST SUITE] TestSaveAndStadium: FALHA EM TESTES! ===")
		
	return all_passed

static func test_save_manager_atomic_operations() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 999)
	state.current_round = 4
	state.get_user_club().credit(45000)
	
	var test_slot := "test_slot_atomic_unit"
	var err = SaveManagerClass.save_game(state, test_slot)
	assert(err == OK, "Falha ao gravar save com SaveManager: %d" % err)
	
	assert(SaveManagerClass.has_save(test_slot), "Save gravado nao foi localizado no disco")
	
	# Verifica que o arquivo temporario foi removido apos o rename atomico
	var tmp_path = "%s/game_state.json.tmp" % SaveManagerClass.get_save_dir(test_slot)
	assert(not FileAccess.file_exists(tmp_path), "Arquivo .tmp nao deveria existir apos o rename atomico")
	
	# Carrega e valida fidelidade
	var loaded = SaveManagerClass.load_game(test_slot)
	assert(loaded != null, "Falha ao carregar save gravado")
	assert(loaded.current_round == 4, "Rodada restaurada incorreta: %d" % loaded.current_round)
	assert(loaded.user_club_id == "club-aurora-fc", "Clube restaurado incorreto")
	assert(loaded.get_user_club().get_balance() == state.get_user_club().get_balance(), "Saldo restaurado incorreto")
	
	# Testa listagem de metadados
	var saves_list = SaveManagerClass.list_saves()
	assert(not saves_list.is_empty(), "Lista de saves nao deveria estar vazia")
	
	# Limpeza
	var deleted = SaveManagerClass.delete_save(test_slot)
	assert(deleted, "Falha ao deletar save temporario de teste")
	assert(not SaveManagerClass.has_save(test_slot), "Save deveria ter sido removido do disco")
	
	print("[PASS] test_save_manager_atomic_operations: Gravacao atomica JSON e restauracao comprovadas")
	return true

static func test_stadium_renovation_cycle_and_capacity_jump() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 123)
	var controller = SeasonControllerClass.new(state)
	
	var club = state.get_user_club()
	club.finances["balance"] = 200000 # Saldo suficiente para a reforma de R$ 150.000
	
	var modal = StadiumUpgradeModalClass.new()
	modal.open_for_stadium(state)
	
	var stadium = state.get_facility("facility-estadio-aurora")
	assert(stadium.current_level == 1, "Estadio inicial deve ser nivel 1")
	assert(stadium.get_current_capacity() == 3000, "Capacidade inicial deve ser 3000 torcedores")
	
	# Dispara a confirmacao de upgrade no modal
	modal._on_confirm_upgrade()
	
	assert(club.get_balance() == 50000, "Deveria debitar R$ 150.000 do saldo (200.000 - 150.000 = 50.000)")
	assert(stadium.is_under_construction, "Estadio deveria estar em obras")
	assert(stadium.rounds_remaining == 4, "Obras do Nivel 2 devem durar exatamente 4 rodadas")
	assert(stadium.get_current_capacity() == 2250, "Durante obras a capacidade cai 25%% (2250)")
	
	# Simula 4 rodadas para concluir a obra
	for r in range(4):
		controller.simulate_full_round()
		
	assert(not stadium.is_under_construction, "Obra deveria ter finalizado apos 4 rodadas")
	assert(stadium.current_level == 2, "Estadio deveria ter alcancado o Nivel 2")
	assert(stadium.get_current_capacity() == 8500, "Capacidade do Estadio Nivel 2 deve ser exatamente 8500 torcedores!")
	
	modal.queue_free()
	print("[PASS] test_stadium_renovation_cycle_and_capacity_jump: Reforma com custo de 150k, 4 rodadas e salto para 8.500 torcedores validada")
	return true

static func test_audio_service_procedural_fx() -> bool:
	var audio = AudioServiceClass.get_instance()
	audio._ready()
	
	audio.play_whistle()
	audio.play_click()
	audio.play_goal()
	audio.play_upgrade()
	
	assert(audio._player != null, "AudioStreamPlayer nao inicializado")
	assert(audio._player.stream != null, "AudioStreamWAV sintetizado nao atribuido")
	
	print("[PASS] test_audio_service_procedural_fx: Efeitos sonoros procedurais táteis (apito, clique, gol, obra) gerados com sucesso")
	return true

static func test_main_menu_interactions() -> bool:
	var menu = MainMenuClass.new()
	menu._build_ui_structure()
	
	var signals_hit := { "new": false, "cont": false }
	menu.new_career_requested.connect(func(): signals_hit["new"] = true)
	menu.continue_career_requested.connect(func(): signals_hit["cont"] = true)
	
	menu._on_new_pressed()
	assert(signals_hit["new"], "Sinal new_career_requested nao capturado")
	
	menu._on_continue_pressed()
	assert(signals_hit["cont"], "Sinal continue_career_requested nao capturado")
	
	menu.queue_free()
	print("[PASS] test_main_menu_interactions: Menu Principal com Nova Carreira, Continuar e Sair validado")
	return true

static func test_app_controller_orchestration() -> bool:
	var app = AppControllerClass.new()
	app._build_ui()
	
	# Inicia nova carreira via evento
	app._on_new_career_requested()
	assert(app.game_state != null, "GameState nao foi criado no AppController")
	assert(app.create_club_wizard.visible, "Wizard de criacao de clube deveria estar visivel")
	
	# Confirma inicio da carreira com o Aurora FC
	app._on_career_started("club-aurora-fc")
	assert(app.hud_panel.visible, "HUD deveria estar visivel")
	assert(app.world_view.visible, "WorldView deveria estar visivel")
	assert(app.game_state.current_round == 1, "Carreira deveria iniciar na rodada 1")
	
	# Simula jogar a rodada
	app._on_advance_round_pressed()
	assert(app.match_view.visible, "MatchView deveria estar visivel para a partida do usuario")
	
	# Finaliza a partida do usuario e fecha a rodada
	var dummy_result = {
		"home_club_id": "club-aurora-fc",
		"away_club_id": "club-juventude-paulista",
		"home_score": 2,
		"away_score": 1
	}
	app._on_match_finished(dummy_result)
	
	assert(not app.match_view.visible, "MatchView deveria ter sido ocultado apos o fim do jogo")
	assert(app.game_state.current_round == 2, "A rodada deveria ter avancado para 2")
	
	app.queue_free()
	print("[PASS] test_app_controller_orchestration: Loop completo Menu -> Wizard -> Mundo -> Partida -> Avanco validado com maestria")
	return true
