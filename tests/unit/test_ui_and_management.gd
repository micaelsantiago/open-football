class_name TestUIAndManagement
extends RefCounted

const DataLoader = preload("res://src/systems/data_loader/data_loader.gd")
const GameStateClass = preload("res://src/core/state/game_state.gd")
const PlayerDataClass = preload("res://src/core/player/player_data.gd")
const EventBusClass = preload("res://src/systems/event_bus/event_bus.gd")

const DataTableClass = preload("res://src/presentation/ui/common/data_table.gd")
const PlayerCardClass = preload("res://src/presentation/ui/common/player_card.gd")
const ActionModalClass = preload("res://src/presentation/ui/common/action_modal.gd")
const SquadViewClass = preload("res://src/presentation/ui/squad/squad_view.gd")
const FinancesViewClass = preload("res://src/presentation/ui/finances/finances_view.gd")
const CreateClubWizardClass = preload("res://src/presentation/ui/create_club/create_club_wizard.gd")
const ClubDashboardViewClass = preload("res://src/presentation/ui/dashboard/club_dashboard_view.gd")
const AppControllerClass = preload("res://src/presentation/app_controller.gd")

static func run_all_tests() -> bool:
	print("\n=== [TEST SUITE] TestUIAndManagement ===")
	var all_passed := true
	
	all_passed = test_event_bus_signals() and all_passed
	all_passed = test_data_table_component() and all_passed
	all_passed = test_player_card_component() and all_passed
	all_passed = test_action_modal_component() and all_passed
	all_passed = test_squad_view_tactics() and all_passed
	all_passed = test_finances_view_ticket_pricing() and all_passed
	all_passed = test_create_club_wizard() and all_passed
	all_passed = test_club_dashboard_and_fixed_navigation() and all_passed
	
	if all_passed:
		print("=== [TEST SUITE] TestUIAndManagement: TODOS OS TESTES PASSARAM! ===\n")
	else:
		push_error("=== [TEST SUITE] TestUIAndManagement: FALHA EM TESTES! ===")
		
	return all_passed

static func test_event_bus_signals() -> bool:
	var bus = EventBusClass.get_instance()
	var res := { "received": false, "balance": 0 }
	
	bus.balance_changed.connect(func(bal: int, delta: int):
		res["received"] = true
		res["balance"] = bal
	)
	
	bus.balance_changed.emit(150000, 50000)
	assert(res["received"], "EventBus: Sinal balance_changed nao foi capturado")
	assert(res["balance"] == 150000, "EventBus: Saldo transmitido incorreto: %d" % res["balance"])
	
	print("[PASS] test_event_bus_signals: Desacoplamento via EventBus validado")
	return true

static func test_data_table_component() -> bool:
	var table = DataTableClass.new()
	table.set_columns([
		{ "id": "pos", "title": "Pos", "width": 40 },
		{ "id": "name", "title": "Nome", "width": 140 },
		{ "id": "pts", "title": "Pts", "width": 40 }
	])
	
	var rows = [
		{ "pos": "1º", "name": "Aurora FC", "pts": 32 },
		{ "pos": "2º", "name": "União FC", "pts": 28 },
		{ "pos": "3º", "name": "Estrela EC", "pts": 25 }
	]
	table.set_rows(rows)
	
	assert(table.get_rows_count() == 3, "Tabela deveria conter 3 linhas")
	
	var clicked := { "row": {} }
	table.row_clicked.connect(func(r: Dictionary, idx: int): clicked["row"] = r)
	table.row_clicked.emit(rows[0], 0)
	assert(clicked["row"].get("name") == "Aurora FC", "Linha clicada incorreta")
	
	table.queue_free()
	print("[PASS] test_data_table_component: Componente DataTable validado")
	return true

static func test_player_card_component() -> bool:
	var p = PlayerDataClass.new()
	p.id = "card-test-player"
	p.name = "Carlos Alberto Silva"
	p.common_name = "Carlos Silva"
	p.primary_position = "ST"
	p.condition = 85.0
	
	var card = PlayerCardClass.new()
	card.setup(p)
	
	assert(card.player_id == "card-test-player", "ID do PlayerCard incorreto")
	assert(card._name_label.text == "Carlos Silva", "Nome no card incorreto")
	assert(card._condition_bar.value == 85.0, "Barra de condicao incorreta")
	
	card.queue_free()
	print("[PASS] test_player_card_component: Componente PlayerCard validado")
	return true

static func test_action_modal_component() -> bool:
	var modal = ActionModalClass.new()
	modal.open("Título do Modal", "Confirmar Teste", "Cancelar Teste")
	
	assert(modal.visible, "Modal deveria estar visivel apos open()")
	assert(modal._title_label.text == "Título do Modal", "Titulo incorreto")
	
	var status := { "confirmed": false }
	modal.confirmed.connect(func(): status["confirmed"] = true)
	modal.confirmed.emit()
	assert(status["confirmed"], "Sinal confirmed nao foi emitido")
	
	modal.close()
	assert(not modal.visible, "Modal nao deveria estar visivel apos close()")
	
	modal.queue_free()
	print("[PASS] test_action_modal_component: Componente ActionModal validado")
	return true

static func test_squad_view_tactics() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 50)
	
	var squad_view = SquadViewClass.new()
	squad_view.setup(state, "club-aurora-fc")
	
	assert(squad_view._starters_container.get_child_count() == 11, "Deveriam haver exatamente 11 titulares no container")
	assert(squad_view._subs_container.get_child_count() == 5, "Deveriam haver 5 reservas no container (16 - 11 = 5)")
	
	# Muda mentalidade para Ofensiva (index 1) e salva
	squad_view._mentality_option.select(1)
	squad_view._on_save_pressed()
	
	var aurora = state.get_club("club-aurora-fc")
	assert(aurora.tactics_preset["mentality"] == "OFFENSIVE", "Mentalidade tática nao foi atualizada no ClubData")
	
	squad_view.queue_free()
	print("[PASS] test_squad_view_tactics: Tela de escalacao e selecao tatica validada")
	return true

static func test_finances_view_ticket_pricing() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 50)
	
	var fin_view = FinancesViewClass.new()
	fin_view.setup(state, "club-aurora-fc")
	
	var aurora = state.get_club("club-aurora-fc")
	assert(aurora.get_ticket_price() == 20, "Preco inicial do ingresso deveria ser 20")
	
	# Altera o slider de preco do ingresso para 35 e salva
	fin_view._ticket_slider.value = 35
	fin_view._on_save_pressed()
	
	assert(aurora.get_ticket_price() == 35, "Preco do ingresso nao foi alterado no ClubData")
	
	fin_view.queue_free()
	print("[PASS] test_finances_view_ticket_pricing: Tela de financas e ajuste de bilheteria validada")
	return true

static func test_create_club_wizard() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 50)
	
	var wizard = CreateClubWizardClass.new()
	wizard.setup(state)
	
	# Teste Caminho 1: Selecionar clube existente (ex: Uniao FC)
	var chosen := { "id": "" }
	wizard.club_confirmed.connect(func(cid: String): chosen["id"] = cid)
	
	# Simula selecao do Uniao FC
	for i in range(wizard._existing_clubs_list.get_item_count()):
		if str(wizard._existing_clubs_list.get_item_metadata(i)) == "club-uniao-fc":
			wizard._existing_clubs_list.select(i)
			break
	wizard._on_confirm_existing_pressed()
	assert(chosen["id"] == "club-uniao-fc", "Caminho 1: Clube selecionado incorreto: %s" % chosen["id"])
	assert(state.user_club_id == "club-uniao-fc", "GameState user_club_id nao atualizado")
	
	# Teste Live Preview e Alternância de Modo
	assert(wizard._preview_shield != null, "Escudo dinâmico de Live Preview deveria existir")
	assert(wizard._preview_kit != null, "Uniforme dinâmico de Live Preview deveria existir")
	assert(wizard._preview_stadium != null, "Estádio dinâmico de Live Preview deveria existir")
	
	wizard._switch_mode(1) # Ativa modo customizado
	assert(wizard._custom_panel.visible, "Painel customizado deveria estar visivel")
	assert(not wizard._traditional_panel.visible, "Painel tradicional deveria estar oculto")
	
	# Teste Caminho 2: Fundar novo clube customizado
	wizard._name_edit.text = "Serra Dourada FC"
	wizard._short_name_edit.text = "SDF"
	wizard._stadium_name_edit.text = "Arena do Sol"
	wizard._on_custom_field_changed()
	assert(wizard._preview_short_name == "SDF", "Sigla do Live Preview deveria ser SDF")
	
	wizard._on_confirm_new_pressed()
	
	var my_club = state.get_user_club()
	assert(my_club.name == "Serra Dourada FC", "Caminho 2: Nome do novo clube incorreto")
	assert(my_club.short_name == "SDF", "Caminho 2: Sigla do novo clube incorreta")
	
	var my_stadium = state.get_facility(my_club.facilities["stadium_id"])
	assert(my_stadium.name == "Arena do Sol", "Caminho 2: Nome do estádio customizado incorreto")
	
	# Teste sinal back_requested
	var back_hit := { "val": false }
	wizard.back_requested.connect(func(): back_hit["val"] = true)
	wizard.back_requested.emit()
	assert(back_hit["val"], "Sinal back_requested deveria ter sido emitido")
	
	wizard.queue_free()
	print("[PASS] test_create_club_wizard: Assistente de criacao de clube (Dois Caminhos + Live Preview) validado com sucesso")
	return true

static func test_club_dashboard_and_fixed_navigation() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 50)
	
	# 1. Teste isolado do ClubDashboardView
	var dash = ClubDashboardViewClass.new()
	dash.setup(state)
	
	assert(dash._club_name_lbl.text == "Futebol Clube Aurora", "Nome do clube no dashboard incorreto")
	assert(dash._position_lbl.text.contains("Lugar"), "Posicao inicial no dashboard incorreta")
	assert(dash._balance_lbl.text.contains("250000"), "Saldo inicial no dashboard incorreto")
	assert(dash._mentality_lbl.text.contains("BALANCED"), "Postura tática inicial incorreta")
	assert(dash._stadium_name_lbl.text == "Estádio das Colinas", "Nome do estádio no dashboard incorreto")
	assert(dash._stadium_capacity_lbl.text.contains("3000"), "Capacidade do estádio incorreta")
	
	var nav_target := { "val": "" }
	dash.navigate_requested.connect(func(t: String): nav_target["val"] = t)
	dash._goto_finances_btn.pressed.emit()
	assert(nav_target["val"] == "finances", "Navegação para finanças via dashboard falhou")
	
	dash._goto_squad_btn.pressed.emit()
	assert(nav_target["val"] == "squad", "Navegação para elenco via dashboard falhou")
	
	var play_hit := { "val": false }
	dash.play_round_requested.connect(func(): play_hit["val"] = true)
	dash._play_round_btn.pressed.emit()
	assert(play_hit["val"], "Sinal play_round_requested nao emitido pelo dashboard")
	dash.queue_free()
	
	# 2. Teste do Menu Fixo e Alternância de Telas Dedicadas no AppController
	var app = AppControllerClass.new()
	app._build_ui()
	app._on_new_career_requested()
	app._on_career_started("club-aurora-fc")
	
	# Menu fixo sempre visível em jogo
	assert(app.hud_panel.visible, "Menu Fixo (hud_panel) deve estar visível")
	assert(app.current_in_game_view == "dashboard", "Tela inicial em jogo deve ser o dashboard")
	assert(app.club_dashboard_view.visible, "ClubDashboardView deve estar visível como tela principal")
	assert(not app.squad_view.visible, "SquadView deve iniciar oculta")
	assert(not app.finances_view.visible, "FinancesView deve iniciar oculta")
	assert(not app.standings_view.visible, "StandingsView deve iniciar oculta")
	
	# Navega para Finanças
	app._switch_in_game_view("finances")
	assert(app.current_in_game_view == "finances", "current_in_game_view deve ser finances")
	assert(app.finances_view.visible, "FinancesView deve estar visível")
	assert(not app.club_dashboard_view.visible, "ClubDashboardView deve estar oculta")
	
	# Navega para Elenco
	app._switch_in_game_view("squad")
	assert(app.current_in_game_view == "squad", "current_in_game_view deve ser squad")
	assert(app.squad_view.visible, "SquadView deve estar visível")
	assert(not app.finances_view.visible, "FinancesView deve estar oculta")
	
	# Retorna ao Dashboard via botão fechar da tela
	app.squad_view.closed.emit()
	assert(app.current_in_game_view == "dashboard", "Deve retornar ao dashboard ao fechar elenco")
	assert(app.club_dashboard_view.visible, "ClubDashboardView deve voltar a ficar visível")
	
	app.queue_free()
	print("[PASS] test_club_dashboard_and_fixed_navigation: Painel do clube e menu fixo validados com sucesso")
	return true
