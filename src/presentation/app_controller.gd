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
const ClubDashboardViewClass = preload("res://src/presentation/ui/dashboard/club_dashboard_view.gd")
const WorldViewClass = preload("res://src/presentation/world_2d/world_view.gd")
const SquadViewClass = preload("res://src/presentation/ui/squad/squad_view.gd")
const FinancesViewClass = preload("res://src/presentation/ui/finances/finances_view.gd")
const StandingsViewClass = preload("res://src/presentation/ui/standings/standings_view.gd")
const StadiumUpgradeModalClass = preload("res://src/presentation/ui/stadium/stadium_upgrade_modal.gd")
const MatchViewClass = preload("res://src/presentation/match_view/match_view.gd")
const MatchSimulationClass = preload("res://src/core/match/match_simulation.gd")
const ActionModalClass = preload("res://src/presentation/ui/common/action_modal.gd")

var game_state: RefCounted
var season_controller: RefCounted

var main_menu: MainMenu
var create_club_wizard: CreateClubWizard
var club_dashboard_view: Control
var world_view: WorldView
var squad_view: SquadView
var finances_view: FinancesView
var standings_view: StandingsView
var stadium_modal: StadiumUpgradeModal
var match_view: MatchView
var exit_modal: ActionModal

var current_in_game_view: String = "dashboard"

var hud_panel: PanelContainer
var club_name_label: Label
var round_label: Label
var balance_label: Label
var advance_round_btn: Button

var _nav_dashboard_btn: Button
var _nav_squad_btn: Button
var _nav_finances_btn: Button
var _nav_standings_btn: Button
var _nav_world_btn: Button
var _nav_save_btn: Button
var _nav_menu_btn: Button

func _ready() -> void:
	_build_ui()
	show_main_menu()

func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# 1. Mundo Isométrico 2D (Camada de base)
	world_view = WorldViewClass.new()
	world_view.visible = false
	add_child(world_view)
	world_view.facility_selected.connect(_on_world_facility_selected)
	
	# 2. Tela Principal do Clube (Dashboard Integrado)
	club_dashboard_view = ClubDashboardViewClass.new()
	club_dashboard_view.visible = false
	add_child(club_dashboard_view)
	club_dashboard_view.play_round_requested.connect(_on_advance_round_pressed)
	club_dashboard_view.navigate_requested.connect(_switch_in_game_view)
	
	# 3. Telas Dedicadas (Abaixo da barra superior fixa)
	squad_view = SquadViewClass.new()
	squad_view.visible = false
	add_child(squad_view)
	squad_view.tactics_saved.connect(func():
		EventBusClass.get_instance().toast_requested.emit("Táticas salvas com sucesso!", "SUCCESS")
		_switch_in_game_view("dashboard")
	)
	squad_view.closed.connect(func():
		_switch_in_game_view("dashboard")
	)
	
	finances_view = FinancesViewClass.new()
	finances_view.visible = false
	add_child(finances_view)
	finances_view.finances_saved.connect(func():
		EventBusClass.get_instance().toast_requested.emit("Finanças salvas com sucesso!", "SUCCESS")
		update_hud()
		_switch_in_game_view("dashboard")
	)
	finances_view.closed.connect(func():
		_switch_in_game_view("dashboard")
	)
	
	standings_view = StandingsViewClass.new()
	standings_view.visible = false
	add_child(standings_view)
	standings_view.closed.connect(func():
		_switch_in_game_view("dashboard")
	)
	
	stadium_modal = StadiumUpgradeModalClass.new()
	stadium_modal.visible = false
	stadium_modal.z_index = 15
	add_child(stadium_modal)
	stadium_modal.upgrade_started.connect(func():
		world_view.refresh_world()
		update_hud()
		if club_dashboard_view != null:
			club_dashboard_view.refresh()
		_update_camera_controls()
	)
	stadium_modal.closed.connect(func():
		_update_camera_controls()
	)
	
	match_view = MatchViewClass.new()
	match_view.visible = false
	match_view.z_index = 25
	add_child(match_view)
	match_view.match_finished.connect(_on_match_finished)
	
	# 4. HUD / Menu Fixo Superior de Gestão (Persistente em jogo)
	hud_panel = PanelContainer.new()
	hud_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_panel.custom_minimum_size = Vector2(0, 52)
	hud_panel.z_index = 10
	var hud_st = StyleBoxFlat.new()
	hud_st.bg_color = Color(0.06, 0.08, 0.12, 0.98)
	hud_st.border_width_bottom = 2
	hud_st.border_color = Color("#1E293B")
	hud_st.content_margin_left = 16
	hud_st.content_margin_right = 16
	hud_st.content_margin_top = 6
	hud_st.content_margin_bottom = 6
	hud_panel.add_theme_stylebox_override("panel", hud_st)
	add_child(hud_panel)
	
	var hud_hbox = HBoxContainer.new()
	hud_hbox.add_theme_constant_override("separation", 8)
	hud_panel.add_child(hud_hbox)
	
	# Identidade do Clube no HUD
	var shield_icon = Label.new()
	shield_icon.text = "🛡️"
	hud_hbox.add_child(shield_icon)
	
	club_name_label = Label.new()
	club_name_label.text = "Clube: --"
	club_name_label.add_theme_font_size_override("font_size", 14)
	club_name_label.add_theme_color_override("font_color", Color("#F8FAFC"))
	hud_hbox.add_child(club_name_label)
	
	hud_hbox.add_child(VSeparator.new())
	
	round_label = Label.new()
	round_label.text = "Rodada: 1/14"
	round_label.add_theme_font_size_override("font_size", 12)
	round_label.add_theme_color_override("font_color", Color("#94A3B8"))
	hud_hbox.add_child(round_label)
	
	hud_hbox.add_child(VSeparator.new())
	
	balance_label = Label.new()
	balance_label.text = "Saldo: R$ 0"
	balance_label.add_theme_font_size_override("font_size", 13)
	balance_label.add_theme_color_override("font_color", Color("#22C55E"))
	hud_hbox.add_child(balance_label)
	
	var spacer_left = Control.new()
	spacer_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud_hbox.add_child(spacer_left)
	
	# Abas do Menu Fixo (Navegação Central)
	_nav_dashboard_btn = _create_nav_tab("🏠 Clube", "dashboard")
	hud_hbox.add_child(_nav_dashboard_btn)
	
	_nav_squad_btn = _create_nav_tab("📋 Elenco", "squad")
	hud_hbox.add_child(_nav_squad_btn)
	
	_nav_finances_btn = _create_nav_tab("💰 Finanças", "finances")
	hud_hbox.add_child(_nav_finances_btn)
	
	_nav_standings_btn = _create_nav_tab("📊 Tabela", "standings")
	hud_hbox.add_child(_nav_standings_btn)
	
	_nav_world_btn = _create_nav_tab("🏟️ Sede", "world")
	hud_hbox.add_child(_nav_world_btn)
	
	var spacer_right = Control.new()
	spacer_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud_hbox.add_child(spacer_right)
	
	# Ações Rápidas à Direita
	_nav_save_btn = Button.new()
	_nav_save_btn.text = "💾 Salvar"
	_nav_save_btn.custom_minimum_size = Vector2(76, 34)
	_nav_save_btn.focus_mode = Control.FOCUS_NONE
	var save_st = StyleBoxFlat.new()
	save_st.bg_color = Color("#1E293B")
	save_st.corner_radius_top_left = 6
	save_st.corner_radius_top_right = 6
	save_st.corner_radius_bottom_left = 6
	save_st.corner_radius_bottom_right = 6
	save_st.content_margin_left = 10
	save_st.content_margin_right = 10
	_nav_save_btn.add_theme_stylebox_override("normal", save_st)
	_nav_save_btn.pressed.connect(_on_save_button_pressed)
	hud_hbox.add_child(_nav_save_btn)
	
	hud_hbox.add_child(VSeparator.new())
	
	advance_round_btn = Button.new()
	advance_round_btn.text = "⚽ Jogar Rodada 1"
	advance_round_btn.custom_minimum_size = Vector2(130, 34)
	advance_round_btn.focus_mode = Control.FOCUS_NONE
	var adv_st = StyleBoxFlat.new()
	adv_st.bg_color = Color("#16A34A")
	adv_st.corner_radius_top_left = 6
	adv_st.corner_radius_top_right = 6
	adv_st.corner_radius_bottom_left = 6
	adv_st.corner_radius_bottom_right = 6
	adv_st.content_margin_left = 12
	adv_st.content_margin_right = 12
	advance_round_btn.add_theme_stylebox_override("normal", adv_st)
	advance_round_btn.pressed.connect(_on_advance_round_pressed)
	hud_hbox.add_child(advance_round_btn)
	
	hud_hbox.add_child(VSeparator.new())
	
	_nav_menu_btn = Button.new()
	_nav_menu_btn.text = "🚪 Menu"
	_nav_menu_btn.custom_minimum_size = Vector2(72, 34)
	_nav_menu_btn.focus_mode = Control.FOCUS_NONE
	var menu_st = StyleBoxFlat.new()
	menu_st.bg_color = Color("#1E293B")
	menu_st.corner_radius_top_left = 6
	menu_st.corner_radius_top_right = 6
	menu_st.corner_radius_bottom_left = 6
	menu_st.corner_radius_bottom_right = 6
	menu_st.content_margin_left = 8
	menu_st.content_margin_right = 8
	_nav_menu_btn.add_theme_stylebox_override("normal", menu_st)
	_nav_menu_btn.pressed.connect(_on_exit_to_menu_pressed)
	hud_hbox.add_child(_nav_menu_btn)
	
	# 5. Modal de Confirmação de Saída
	exit_modal = ActionModalClass.new()
	exit_modal.visible = false
	exit_modal.z_index = 50
	add_child(exit_modal)
	exit_modal.confirmed.connect(func():
		if game_state != null:
			SaveManagerClass.save_game(game_state, "carreira_default")
		exit_modal.close()
		show_main_menu()
	)
	
	# 6. Telas Iniciais (Menu e Wizard)
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
	create_club_wizard.z_index = 30
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
	main_menu.z_index = 40
	add_child(main_menu)
	main_menu.new_career_requested.connect(_on_new_career_requested)
	main_menu.continue_career_requested.connect(_on_continue_career_requested)

func _create_nav_tab(title: String, view_id: String) -> Button:
	var btn = Button.new()
	btn.text = title
	btn.custom_minimum_size = Vector2(96, 34)
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_size_override("font_size", 12)
	btn.pressed.connect(func():
		AudioServiceClass.get_instance().play_click()
		_switch_in_game_view(view_id)
	)
	return btn

func _update_nav_tabs_highlight() -> void:
	var tabs = {
		"dashboard": _nav_dashboard_btn,
		"squad": _nav_squad_btn,
		"finances": _nav_finances_btn,
		"standings": _nav_standings_btn,
		"world": _nav_world_btn
	}
	
	for view_id in tabs:
		var btn: Button = tabs[view_id]
		if btn == null:
			continue
		var is_active = (view_id == current_in_game_view)
		var st = StyleBoxFlat.new()
		st.corner_radius_top_left = 6
		st.corner_radius_top_right = 6
		st.corner_radius_bottom_left = 6
		st.corner_radius_bottom_right = 6
		st.content_margin_left = 12
		st.content_margin_right = 12
		st.content_margin_top = 4
		st.content_margin_bottom = 4
		
		if is_active:
			st.bg_color = Color("#2563EB")
			st.border_width_bottom = 2
			st.border_color = Color("#60A5FA")
			btn.add_theme_color_override("font_color", Color.WHITE)
		else:
			st.bg_color = Color(0.11, 0.14, 0.20, 0.6)
			st.border_width_bottom = 1
			st.border_color = Color("#1E293B")
			btn.add_theme_color_override("font_color", Color("#94A3B8"))
			
		btn.add_theme_stylebox_override("normal", st)
		
		var hover_st = st.duplicate()
		if not is_active:
			hover_st.bg_color = Color(0.18, 0.22, 0.32, 0.9)
			hover_st.border_color = Color("#3B82F6")
		btn.add_theme_stylebox_override("hover", hover_st)

func _switch_in_game_view(target_view: String) -> void:
	current_in_game_view = target_view
	
	if club_dashboard_view != null:
		club_dashboard_view.visible = (target_view == "dashboard")
		if target_view == "dashboard":
			club_dashboard_view.refresh()
			
	if squad_view != null:
		squad_view.visible = (target_view == "squad")
		if target_view == "squad" and game_state != null:
			squad_view.setup(game_state)
			
	if finances_view != null:
		finances_view.visible = (target_view == "finances")
		if target_view == "finances" and game_state != null:
			finances_view.setup(game_state)
			
	if standings_view != null:
		standings_view.visible = (target_view == "standings")
		if target_view == "standings" and game_state != null:
			standings_view.setup(game_state)
			
	if world_view != null:
		world_view.visible = true
		if target_view == "world":
			world_view.refresh_world()
			
	_update_nav_tabs_highlight()
	_update_camera_controls()

func show_main_menu() -> void:
	hud_panel.visible = false
	if world_view != null:
		world_view.visible = false
	if club_dashboard_view != null:
		club_dashboard_view.visible = false
	if squad_view != null:
		squad_view.visible = false
	if finances_view != null:
		finances_view.visible = false
	if standings_view != null:
		standings_view.visible = false
	if stadium_modal != null:
		stadium_modal.visible = false
	if match_view != null:
		match_view.visible = false
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
	club_dashboard_view.setup(game_state)
	_switch_in_game_view("dashboard")
	update_hud()
	SaveManagerClass.save_game(game_state, "carreira_default")

func update_hud() -> void:
	if game_state == null:
		return
	var club = game_state.get_user_club()
	if club != null:
		club_name_label.text = "%s" % club.name
		balance_label.text = "Saldo: R$ %d" % club.get_balance()
	round_label.text = "Rodada: %d/%d" % [game_state.current_round, game_state.total_rounds]
	if season_controller != null and season_controller.is_season_finished():
		advance_round_btn.text = "🏆 Concluída"
		advance_round_btn.disabled = true
	else:
		advance_round_btn.text = "⚽ Jogar Rodada %d" % game_state.current_round
		advance_round_btn.disabled = false
	if club_dashboard_view != null and club_dashboard_view.visible:
		club_dashboard_view.refresh()

func _on_exit_to_menu_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	if exit_modal != null:
		exit_modal.open("Salvar e Sair?", "Salvar e Sair para o Menu", "Continuar Jogando")

func _on_world_facility_selected(facility_id: String) -> void:
	var fac = game_state.get_facility(facility_id)
	if fac != null and str(fac.type) == "STADIUM":
		stadium_modal.open_for_stadium(game_state, facility_id)
		_update_camera_controls()

func _on_squad_button_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	_switch_in_game_view("squad")

func _on_finances_button_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	_switch_in_game_view("finances")

func _on_standings_button_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	_switch_in_game_view("standings")

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
		_switch_in_game_view(current_in_game_view)
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
	if club_dashboard_view != null:
		club_dashboard_view.refresh()
	world_view.refresh_world()
	_switch_in_game_view(current_in_game_view)
	_update_camera_controls()
	
	# Salva o jogo atomicamente apos a rodada
	SaveManagerClass.save_game(game_state, "carreira_default")

## Retorna se o usuario esta na tela principal da sede (estadio e campo) sem janelas modais
func is_world_active() -> bool:
	return current_in_game_view == "world" \
		and world_view != null \
		and world_view.visible \
		and not (main_menu != null and main_menu.visible) \
		and not (create_club_wizard != null and create_club_wizard.visible) \
		and not (club_dashboard_view != null and club_dashboard_view.visible) \
		and not (squad_view != null and squad_view.visible) \
		and not (finances_view != null and finances_view.visible) \
		and not (standings_view != null and standings_view.visible) \
		and not (stadium_modal != null and stadium_modal.visible) \
		and not (match_view != null and match_view.visible)

## Atualiza a ativacao dos controles de camera (zoom e pan) de acordo com a tela ativa
func _update_camera_controls() -> void:
	if world_view != null:
		world_view.set_controls_enabled(is_world_active())
