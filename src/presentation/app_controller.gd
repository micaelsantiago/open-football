class_name AppController
extends Control

const DataLoaderClass = preload("res://src/systems/data_loader/data_loader.gd")
const GameStateClass = preload("res://src/core/state/game_state.gd")
const SeasonControllerClass = preload("res://src/core/calendar/season_controller.gd")
const SaveManagerClass = preload("res://src/systems/save_system/save_manager.gd")
const EventBusClass = preload("res://src/systems/event_bus/event_bus.gd")
const AudioServiceClass = preload("res://src/systems/audio/audio_service.gd")

const MainMenuClass = preload("res://src/presentation/ui/main_menu/main_menu.gd")
const CreateClubWizardClass = preload("res://src/presentation/ui/create_club/create_club_wizard.gd")
const WorldViewClass = preload("res://src/presentation/world_2d/world_view.gd")
const SquadViewClass = preload("res://src/presentation/ui/squad/squad_view.gd")
const FinancesViewClass = preload("res://src/presentation/ui/finances/finances_view.gd")
const StandingsViewClass = preload("res://src/presentation/ui/standings/standings_view.gd")
const StadiumUpgradeModalClass = preload("res://src/presentation/ui/stadium/stadium_upgrade_modal.gd")
const MatchViewClass = preload("res://src/presentation/match_view/match_view.gd")
const MatchSimulationClass = preload("res://src/core/match/match_simulation.gd")

var game_state: RefCounted
var season_controller: RefCounted

var main_menu: MainMenu
var create_club_wizard: CreateClubWizard
var world_view: WorldView
var squad_view: SquadView
var finances_view: FinancesView
var standings_view: StandingsView
var stadium_modal: StadiumUpgradeModal
var match_view: MatchView

var hud_panel: PanelContainer
var club_name_label: Label
var round_label: Label
var balance_label: Label
var advance_round_btn: Button

func _ready() -> void:
	_build_ui()
	show_main_menu()

func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# 1. Mundo Isometrico de fundo
	world_view = WorldViewClass.new()
	add_child(world_view)
	world_view.facility_selected.connect(_on_world_facility_selected)
	
	# 2. HUD Superior de Gestao
	hud_panel = PanelContainer.new()
	hud_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_panel.custom_minimum_size = Vector2(0, 50)
	add_child(hud_panel)
	
	var hud_hbox = HBoxContainer.new()
	hud_panel.add_child(hud_hbox)
	
	club_name_label = Label.new()
	club_name_label.text = "Clube: --"
	club_name_label.add_theme_font_size_override("font_size", 16)
	club_name_label.add_theme_color_override("font_color", Color.GOLD)
	hud_hbox.add_child(club_name_label)
	
	hud_hbox.add_child(VSeparator.new())
	
	round_label = Label.new()
	round_label.text = "Rodada: 1/14"
	hud_hbox.add_child(round_label)
	
	hud_hbox.add_child(VSeparator.new())
	
	balance_label = Label.new()
	balance_label.text = "Saldo: R$ 0"
	balance_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
	hud_hbox.add_child(balance_label)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud_hbox.add_child(spacer)
	
	var squad_btn = Button.new()
	squad_btn.text = "📋 Elenco & Tática"
	squad_btn.pressed.connect(_on_squad_button_pressed)
	hud_hbox.add_child(squad_btn)
	
	var fin_btn = Button.new()
	fin_btn.text = "💰 Finanças"
	fin_btn.pressed.connect(_on_finances_button_pressed)
	hud_hbox.add_child(fin_btn)
	
	var stand_btn = Button.new()
	stand_btn.text = "📊 Tabela"
	stand_btn.pressed.connect(_on_standings_button_pressed)
	hud_hbox.add_child(stand_btn)
	
	var save_btn = Button.new()
	save_btn.text = "💾 Salvar"
	save_btn.pressed.connect(_on_save_button_pressed)
	hud_hbox.add_child(save_btn)
	
	hud_hbox.add_child(VSeparator.new())
	
	advance_round_btn = Button.new()
	advance_round_btn.text = "⚽ Jogar Rodada"
	advance_round_btn.add_theme_color_override("font_color", Color.GREEN_YELLOW)
	advance_round_btn.pressed.connect(_on_advance_round_pressed)
	hud_hbox.add_child(advance_round_btn)
	
	# 3. Telas Modais Sobrepostas
	squad_view = SquadViewClass.new()
	squad_view.visible = false
	add_child(squad_view)
	squad_view.tactics_saved.connect(func():
		squad_view.visible = false
		_update_camera_controls()
	)
	squad_view.closed.connect(func():
		squad_view.visible = false
		_update_camera_controls()
	)
	
	finances_view = FinancesViewClass.new()
	finances_view.visible = false
	add_child(finances_view)
	finances_view.finances_saved.connect(func():
		finances_view.visible = false
		_update_camera_controls()
	)
	finances_view.closed.connect(func():
		finances_view.visible = false
		_update_camera_controls()
	)
	
	standings_view = StandingsViewClass.new()
	standings_view.visible = false
	add_child(standings_view)
	standings_view.closed.connect(func():
		standings_view.visible = false
		_update_camera_controls()
	)
	
	stadium_modal = StadiumUpgradeModalClass.new()
	stadium_modal.visible = false
	add_child(stadium_modal)
	stadium_modal.upgrade_started.connect(func():
		world_view.refresh_world()
		update_hud()
		_update_camera_controls()
	)
	stadium_modal.closed.connect(func():
		_update_camera_controls()
	)
	
	match_view = MatchViewClass.new()
	match_view.visible = false
	add_child(match_view)
	match_view.match_finished.connect(_on_match_finished)
	
	# 4. Telas Iniciais (Menu e Wizard)
	create_club_wizard = CreateClubWizardClass.new()
	create_club_wizard.anchor_left = 0.0
	create_club_wizard.anchor_top = 0.0
	create_club_wizard.anchor_right = 1.0
	create_club_wizard.anchor_bottom = 1.0
	create_club_wizard.offset_left = 0.0
	create_club_wizard.offset_top = 0.0
	create_club_wizard.offset_right = 0.0
	create_club_wizard.offset_bottom = 0.0
	create_club_wizard.grow_horizontal = Control.GROW_DIRECTION_BOTH
	create_club_wizard.grow_vertical = Control.GROW_DIRECTION_BOTH
	create_club_wizard.visible = false
	add_child(create_club_wizard)
	create_club_wizard.club_confirmed.connect(_on_career_started)
	create_club_wizard.back_requested.connect(func():
		create_club_wizard.visible = false
		show_main_menu()
	)
	
	main_menu = MainMenuClass.new()
	main_menu.anchor_left = 0.0
	main_menu.anchor_top = 0.0
	main_menu.anchor_right = 1.0
	main_menu.anchor_bottom = 1.0
	main_menu.offset_left = 0.0
	main_menu.offset_top = 0.0
	main_menu.offset_right = 0.0
	main_menu.offset_bottom = 0.0
	main_menu.grow_horizontal = Control.GROW_DIRECTION_BOTH
	main_menu.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(main_menu)
	main_menu.new_career_requested.connect(_on_new_career_requested)
	main_menu.continue_career_requested.connect(_on_continue_career_requested)

func show_main_menu() -> void:
	hud_panel.visible = false
	world_view.visible = false
	main_menu.visible = true
	main_menu.refresh_saves()
	_update_camera_controls()

func _on_new_career_requested() -> void:
	main_menu.visible = false
	var db = DataLoaderClass.load_database("res://data")
	game_state = GameStateClass.create_from_database(db, "club-aurora-fc")
	season_controller = SeasonControllerClass.new(game_state)
	
	create_club_wizard.visible = true
	create_club_wizard.setup(game_state)
	_update_camera_controls()

func _on_continue_career_requested() -> void:
	var loaded_state = SaveManagerClass.load_game("carreira_default")
	if loaded_state != null:
		main_menu.visible = false
		game_state = loaded_state
		season_controller = SeasonControllerClass.new(game_state)
		_start_career_session()
	else:
		_on_new_career_requested()

func _on_career_started(_chosen_club_id: String) -> void:
	create_club_wizard.visible = false
	_start_career_session()

func _start_career_session() -> void:
	hud_panel.visible = true
	world_view.visible = true
	world_view.load_club_world(game_state)
	update_hud()
	_update_camera_controls()
	# Salva o progresso inicial
	SaveManagerClass.save_game(game_state, "carreira_default")

func update_hud() -> void:
	if game_state == null:
		return
	var club = game_state.get_user_club()
	if club != null:
		club_name_label.text = "Clube: %s" % club.name
		balance_label.text = "Saldo: R$ %d" % club.get_balance()
	round_label.text = "Rodada: %d/%d" % [game_state.current_round, game_state.total_rounds]
	if season_controller != null and season_controller.is_season_finished():
		advance_round_btn.text = "🏆 Temporada Concluída"
		advance_round_btn.disabled = true
	else:
		advance_round_btn.text = "⚽ Jogar Rodada %d" % game_state.current_round
		advance_round_btn.disabled = false

func _on_world_facility_selected(facility_id: String) -> void:
	var fac = game_state.get_facility(facility_id)
	if fac != null and str(fac.type) == "STADIUM":
		stadium_modal.open_for_stadium(game_state, facility_id)
		_update_camera_controls()

func _on_squad_button_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	squad_view.setup(game_state)
	squad_view.visible = true
	_update_camera_controls()

func _on_finances_button_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	finances_view.setup(game_state)
	finances_view.visible = true
	_update_camera_controls()

func _on_standings_button_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	standings_view.setup(game_state)
	standings_view.visible = true
	_update_camera_controls()

func _on_save_button_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	var err = SaveManagerClass.save_game(game_state, "carreira_default")
	if err == OK:
		EventBusClass.get_instance().toast_requested.emit("Jogo salvo com sucesso!", "SUCCESS")

## Executa a rodada: Simula a partida do usuario ao vivo (ou todas instantaneamente)
func _on_advance_round_pressed() -> void:
	if season_controller == null or season_controller.is_season_finished():
		return
		
	AudioServiceClass.get_instance().play_whistle()
	var fixtures = season_controller.advance_to_match_day()
	var user_club_id = str(game_state.user_club_id)
	
	# Procura o confronto do jogador
	var user_fixture := {}
	var other_fixtures := []
	for fix in fixtures:
		if fix.get("home") == user_club_id or fix.get("away") == user_club_id:
			user_fixture = fix
		else:
			other_fixtures.append(fix)
			
	if not user_fixture.is_empty():
		# Disputa ao vivo com o MatchView
		var h_id = str(user_fixture.get("home"))
		var a_id = str(user_fixture.get("away"))
		var user_is_home = (h_id == user_club_id)
		
		var h_c = game_state.get_club(h_id)
		var a_c = game_state.get_club(a_id)
		var h_players = []
		for pid in h_c.squad:
			h_players.append(game_state.get_player(pid))
		var a_players = []
		for pid in a_c.squad:
			a_players.append(game_state.get_player(pid))
			
		var rng = game_state.create_match_rng("%s_vs_%s" % [h_id, a_id], game_state.current_round)
		var sim = MatchSimulationClass.new(h_c, a_c, h_players, a_players, rng)
		
		match_view.setup(sim, user_is_home)
		match_view.visible = true
		_update_camera_controls()
	else:
		# Se o clube nao tiver jogo nesta rodada, simula tudo direto
		season_controller.simulate_full_round()
		update_hud()
		world_view.refresh_world()
		_update_camera_controls()

func _on_match_finished(user_match_res: Dictionary) -> void:
	# Simula as demais partidas da rodada instantaneamente
	var comp = game_state.get_active_competition()
	var fixtures = comp.get_fixtures_for_round(game_state.current_round)
	var all_results: Array[Dictionary] = []
	
	for fix in fixtures:
		var h_id = str(fix.get("home"))
		var a_id = str(fix.get("away"))
		if (h_id == user_match_res.get("home_club_id") and a_id == user_match_res.get("away_club_id")):
			all_results.append({
				"home": h_id,
				"away": a_id,
				"home_goals": int(user_match_res.get("home_score", 0)),
				"away_goals": int(user_match_res.get("away_score", 0))
			})
		else:
			var sim_res = MatchSimulationClass.run_instant(game_state, h_id, a_id, "%s_vs_%s" % [h_id, a_id], game_state.current_round)
			all_results.append({
				"home": h_id,
				"away": a_id,
				"home_goals": sim_res["home_score"],
				"away_goals": sim_res["away_score"]
			})
			
	season_controller.record_round_results(all_results)
	season_controller.process_finances()
	season_controller.process_facility_tick()
	season_controller.process_recovery_and_advancement()
	
	match_view.visible = false
	update_hud()
	world_view.refresh_world()
	_update_camera_controls()
	
	# Salva o jogo atomicamente apos a rodada
	SaveManagerClass.save_game(game_state, "carreira_default")

## Retorna se o usuario esta na tela principal da sede (estadio e campo) sem janelas modais
func is_world_active() -> bool:
	return world_view != null \
		and world_view.visible \
		and not (main_menu != null and main_menu.visible) \
		and not (create_club_wizard != null and create_club_wizard.visible) \
		and not (squad_view != null and squad_view.visible) \
		and not (finances_view != null and finances_view.visible) \
		and not (standings_view != null and standings_view.visible) \
		and not (stadium_modal != null and stadium_modal.visible) \
		and not (match_view != null and match_view.visible)

## Atualiza a ativacao dos controles de camera (zoom e pan) de acordo com a tela ativa
func _update_camera_controls() -> void:
	if world_view != null:
		world_view.set_controls_enabled(is_world_active())
