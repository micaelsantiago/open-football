class_name ClubDashboardView
extends Control

const AudioServiceClass = preload("res://src/systems/audio/audio_service.gd")

signal play_round_requested()
signal navigate_requested(target_view: String)

var game_state: RefCounted

# Containers e Nós de Exibição
var _scroll: ScrollContainer
var _grid: GridContainer

# 1. Card Identidade do Clube
var _club_name_lbl: Label
var _club_city_lbl: Label
var _reputation_lbl: Label
var _shield_preview: Control

# 2. Card Próximo Confronto
var _match_round_lbl: Label
var _matchup_lbl: Label
var _match_venue_lbl: Label
var _play_round_btn: Button

# 3. Card Tabela / Classificação
var _position_lbl: Label
var _standings_summary_vbox: VBoxContainer
var _goto_standings_btn: Button

# 4. Card Finanças
var _balance_lbl: Label
var _sponsor_lbl: Label
var _expenses_lbl: Label
var _ticket_lbl: Label
var _goto_finances_btn: Button

# 5. Card Elenco & Tática
var _avg_overall_lbl: Label
var _formation_lbl: Label
var _mentality_lbl: Label
var _best_player_lbl: Label
var _goto_squad_btn: Button

# 6. Card Estádio & Obras
var _stadium_name_lbl: Label
var _stadium_capacity_lbl: Label
var _stadium_status_lbl: Label
var _stadium_preview: Control
var _goto_stadium_btn: Button

func _ready() -> void:
	_ensure_full_rect()
	_build_ui_structure()

func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		_ensure_full_rect()
	elif what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		refresh()

func _ensure_full_rect() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_top = 52.0 # Respiro para a barra fixa superior (NavBar)
	offset_right = 0.0
	offset_bottom = 0.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH

func _build_ui_structure() -> void:
	if _grid != null:
		return
		
	_ensure_full_rect()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Fundo esportivo noturno
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.07, 0.09, 0.13)
	add_child(bg)
	
	_scroll = ScrollContainer.new()
	_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_scroll)
	
	var margin_box = MarginContainer.new()
	margin_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin_box.add_theme_constant_override("margin_left", 32)
	margin_box.add_theme_constant_override("margin_top", 16)
	margin_box.add_theme_constant_override("margin_right", 32)
	margin_box.add_theme_constant_override("margin_bottom", 24)
	_scroll.add_child(margin_box)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.add_theme_constant_override("separation", 16)
	margin_box.add_child(content_vbox)
	
	# Cabeçalho da Visão Geral
	var header_hbox = HBoxContainer.new()
	content_vbox.add_child(header_hbox)
	
	var title_lbl = Label.new()
	title_lbl.text = "PAINEL GERAL DO CLUBE"
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color("#F8FAFC"))
	header_hbox.add_child(title_lbl)
	
	var spacer_h = Control.new()
	spacer_h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer_h)
	
	var subtitle_lbl = Label.new()
	subtitle_lbl.text = "Temporada 1 • Liga Inaugural"
	subtitle_lbl.add_theme_font_size_override("font_size", 12)
	subtitle_lbl.add_theme_color_override("font_color", Color("#94A3B8"))
	header_hbox.add_child(subtitle_lbl)
	
	# Grade Principal de 3 Colunas x 2 Linhas de Cards
	_grid = GridContainer.new()
	_grid.columns = 3
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 16)
	_grid.add_theme_constant_override("v_separation", 16)
	content_vbox.add_child(_grid)
	
	_build_club_identity_card()
	_build_next_match_card()
	_build_standings_card()
	_build_finances_card()
	_build_squad_card()
	_build_stadium_card()

# ==============================================================================
# CONSTRUÇÃO DOS 6 CARDS ESTRATÉGICOS
# ==============================================================================

func _create_base_card(title: String, icon: String) -> VBoxContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(320, 220)
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.11, 0.14, 0.20, 0.95)
	st.border_color = Color("#3A475C")
	st.border_width_left = 1
	st.border_width_top = 1
	st.border_width_right = 1
	st.border_width_bottom = 1
	st.corner_radius_top_left = 10
	st.corner_radius_top_right = 10
	st.corner_radius_bottom_left = 10
	st.corner_radius_bottom_right = 10
	st.content_margin_left = 16
	st.content_margin_right = 16
	st.content_margin_top = 14
	st.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", st)
	_grid.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)
	
	# Header do Card
	var top = HBoxContainer.new()
	top.add_theme_constant_override("separation", 6)
	vbox.add_child(top)
	
	var ic = Label.new()
	ic.text = icon
	top.add_child(ic)
	
	var t = Label.new()
	t.text = title
	t.add_theme_font_size_override("font_size", 13)
	t.add_theme_color_override("font_color", Color("#EAB308"))
	top.add_child(t)
	
	vbox.add_child(HSeparator.new())
	return vbox

# Card 1: Identidade
func _build_club_identity_card() -> void:
	var vbox = _create_base_card("IDENTIDADE DO CLUBE", "🛡️")
	
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	vbox.add_child(row)
	
	_shield_preview = DashboardShieldPreview.new()
	_shield_preview.custom_minimum_size = Vector2(56, 68)
	row.add_child(_shield_preview)
	
	var text_v = VBoxContainer.new()
	text_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_v)
	
	_club_name_lbl = Label.new()
	_club_name_lbl.text = "Meu Clube"
	_club_name_lbl.add_theme_font_size_override("font_size", 16)
	_club_name_lbl.add_theme_color_override("font_color", Color("#F8FAFC"))
	text_v.add_child(_club_name_lbl)
	
	_club_city_lbl = Label.new()
	_club_city_lbl.text = "Cidade Sede"
	_club_city_lbl.add_theme_font_size_override("font_size", 11)
	_club_city_lbl.add_theme_color_override("font_color", Color("#94A3B8"))
	text_v.add_child(_club_city_lbl)
	
	_reputation_lbl = Label.new()
	_reputation_lbl.text = "Reputação: 50/100"
	_reputation_lbl.add_theme_font_size_override("font_size", 11)
	_reputation_lbl.add_theme_color_override("font_color", Color("#EAB308"))
	text_v.add_child(_reputation_lbl)
	
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	var info_lbl = Label.new()
	info_lbl.text = "Fundado para disputar o título nacional e expandir sua sede física."
	info_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_lbl.add_theme_font_size_override("font_size", 11)
	info_lbl.add_theme_color_override("font_color", Color("#64748B"))
	vbox.add_child(info_lbl)

# Card 2: Próximo Confronto
func _build_next_match_card() -> void:
	var vbox = _create_base_card("PRÓXIMO CONFRONTO", "⚽")
	
	_match_round_lbl = Label.new()
	_match_round_lbl.text = "Rodada 1 de 14"
	_match_round_lbl.add_theme_font_size_override("font_size", 12)
	_match_round_lbl.add_theme_color_override("font_color", Color("#94A3B8"))
	vbox.add_child(_match_round_lbl)
	
	_matchup_lbl = Label.new()
	_matchup_lbl.text = "Meu Clube 🆚 Adversário"
	_matchup_lbl.add_theme_font_size_override("font_size", 15)
	_matchup_lbl.add_theme_color_override("font_color", Color("#F8FAFC"))
	vbox.add_child(_matchup_lbl)
	
	_match_venue_lbl = Label.new()
	_match_venue_lbl.text = "Local: Estádio das Colinas (Em Casa)"
	_match_venue_lbl.add_theme_font_size_override("font_size", 11)
	_match_venue_lbl.add_theme_color_override("font_color", Color("#22C55E"))
	vbox.add_child(_match_venue_lbl)
	
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	_play_round_btn = Button.new()
	_play_round_btn.text = "⚽ Jogar Partida Agora"
	_play_round_btn.custom_minimum_size = Vector2(0, 38)
	var play_st = StyleBoxFlat.new()
	play_st.bg_color = Color("#16A34A")
	play_st.corner_radius_top_left = 6
	play_st.corner_radius_top_right = 6
	play_st.corner_radius_bottom_left = 6
	play_st.corner_radius_bottom_right = 6
	_play_round_btn.add_theme_stylebox_override("normal", play_st)
	_play_round_btn.pressed.connect(func():
		AudioServiceClass.get_instance().play_click()
		play_round_requested.emit()
	)
	vbox.add_child(_play_round_btn)

# Card 3: Tabela
func _build_standings_card() -> void:
	var vbox = _create_base_card("SITUAÇÃO NA TABELA", "📊")
	
	_position_lbl = Label.new()
	_position_lbl.text = "Posição: 1º Lugar • 0 Pts"
	_position_lbl.add_theme_font_size_override("font_size", 14)
	_position_lbl.add_theme_color_override("font_color", Color.GOLD)
	vbox.add_child(_position_lbl)
	
	_standings_summary_vbox = VBoxContainer.new()
	_standings_summary_vbox.add_theme_constant_override("separation", 2)
	vbox.add_child(_standings_summary_vbox)
	
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	_goto_standings_btn = Button.new()
	_goto_standings_btn.text = "Ver Tabela Completa ►"
	_goto_standings_btn.pressed.connect(func():
		AudioServiceClass.get_instance().play_click()
		navigate_requested.emit("standings")
	)
	vbox.add_child(_goto_standings_btn)

# Card 4: Finanças
func _build_finances_card() -> void:
	var vbox = _create_base_card("SAÚDE FINANCEIRA", "💰")
	
	var b_box = HBoxContainer.new()
	vbox.add_child(b_box)
	var b_title = Label.new()
	b_title.text = "Saldo em Caixa: "
	b_title.add_theme_font_size_override("font_size", 12)
	b_box.add_child(b_title)
	_balance_lbl = Label.new()
	_balance_lbl.text = "R$ 0"
	_balance_lbl.add_theme_font_size_override("font_size", 14)
	_balance_lbl.add_theme_color_override("font_color", Color("#22C55E"))
	b_box.add_child(_balance_lbl)
	
	_sponsor_lbl = Label.new()
	_sponsor_lbl.text = "(+) Patrocínio Semanal: R$ 0"
	_sponsor_lbl.add_theme_font_size_override("font_size", 11)
	_sponsor_lbl.add_theme_color_override("font_color", Color("#94A3B8"))
	vbox.add_child(_sponsor_lbl)
	
	_expenses_lbl = Label.new()
	_expenses_lbl.text = "(-) Folha & Obras: R$ 0"
	_expenses_lbl.add_theme_font_size_override("font_size", 11)
	_expenses_lbl.add_theme_color_override("font_color", Color("#F87171"))
	vbox.add_child(_expenses_lbl)
	
	_ticket_lbl = Label.new()
	_ticket_lbl.text = "Ingresso Fixado: R$ 20"
	_ticket_lbl.add_theme_font_size_override("font_size", 11)
	_ticket_lbl.add_theme_color_override("font_color", Color("#EAB308"))
	vbox.add_child(_ticket_lbl)
	
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	_goto_finances_btn = Button.new()
	_goto_finances_btn.text = "Gerenciar Finanças ►"
	_goto_finances_btn.pressed.connect(func():
		AudioServiceClass.get_instance().play_click()
		navigate_requested.emit("finances")
	)
	vbox.add_child(_goto_finances_btn)

# Card 5: Elenco & Tática
func _build_squad_card() -> void:
	var vbox = _create_base_card("ELENCO & TÁTICAS", "📋")
	
	_avg_overall_lbl = Label.new()
	_avg_overall_lbl.text = "Força Média (Titulares): 72 OVR"
	_avg_overall_lbl.add_theme_font_size_override("font_size", 13)
	_avg_overall_lbl.add_theme_color_override("font_color", Color("#F8FAFC"))
	vbox.add_child(_avg_overall_lbl)
	
	_formation_lbl = Label.new()
	_formation_lbl.text = "Esquema: 4-4-2 Tradicional"
	_formation_lbl.add_theme_font_size_override("font_size", 11)
	_formation_lbl.add_theme_color_override("font_color", Color("#94A3B8"))
	vbox.add_child(_formation_lbl)
	
	_mentality_lbl = Label.new()
	_mentality_lbl.text = "Postura: Equilibrada (BALANCED)"
	_mentality_lbl.add_theme_font_size_override("font_size", 11)
	_mentality_lbl.add_theme_color_override("font_color", Color("#60A5FA"))
	vbox.add_child(_mentality_lbl)
	
	_best_player_lbl = Label.new()
	_best_player_lbl.text = "Craque do Time: --"
	_best_player_lbl.add_theme_font_size_override("font_size", 11)
	_best_player_lbl.add_theme_color_override("font_color", Color("#EAB308"))
	vbox.add_child(_best_player_lbl)
	
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	_goto_squad_btn = Button.new()
	_goto_squad_btn.text = "Escalar Time & Táticas ►"
	_goto_squad_btn.pressed.connect(func():
		AudioServiceClass.get_instance().play_click()
		navigate_requested.emit("squad")
	)
	vbox.add_child(_goto_squad_btn)

# Card 6: Estádio & Patrimônio
func _build_stadium_card() -> void:
	var vbox = _create_base_card("ESTÁDIO & SEDE FÍSICA", "🏟️")
	
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	vbox.add_child(row)
	
	_stadium_preview = DashboardStadiumPreview.new()
	_stadium_preview.custom_minimum_size = Vector2(64, 56)
	row.add_child(_stadium_preview)
	
	var text_v = VBoxContainer.new()
	text_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_v)
	
	_stadium_name_lbl = Label.new()
	_stadium_name_lbl.text = "Estádio das Colinas"
	_stadium_name_lbl.add_theme_font_size_override("font_size", 13)
	_stadium_name_lbl.add_theme_color_override("font_color", Color("#F8FAFC"))
	text_v.add_child(_stadium_name_lbl)
	
	_stadium_capacity_lbl = Label.new()
	_stadium_capacity_lbl.text = "Capacidade: 5.000 torcedores"
	_stadium_capacity_lbl.add_theme_font_size_override("font_size", 11)
	_stadium_capacity_lbl.add_theme_color_override("font_color", Color("#94A3B8"))
	text_v.add_child(_stadium_capacity_lbl)
	
	_stadium_status_lbl = Label.new()
	_stadium_status_lbl.text = "Status: Operacional"
	_stadium_status_lbl.add_theme_font_size_override("font_size", 11)
	_stadium_status_lbl.add_theme_color_override("font_color", Color("#22C55E"))
	text_v.add_child(_stadium_status_lbl)
	
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	_goto_stadium_btn = Button.new()
	_goto_stadium_btn.text = "Visitar Sede Isométrica ►"
	_goto_stadium_btn.pressed.connect(func():
		AudioServiceClass.get_instance().play_click()
		navigate_requested.emit("world")
	)
	vbox.add_child(_goto_stadium_btn)

# ==============================================================================
# ATUALIZAÇÃO DOS DADOS DO CLUBE
# ==============================================================================

func setup(p_game_state: RefCounted) -> void:
	_ensure_full_rect()
	_build_ui_structure()
	game_state = p_game_state
	refresh()

func refresh() -> void:
	if game_state == null:
		return
	var club = game_state.get_user_club()
	if club == null:
		return
		
	var c_primary = Color(str(club.colors.get("primary", "#1D4ED8")))
	var c_secondary = Color(str(club.colors.get("secondary", "#FFFFFF")))
	
	# 1. Identidade
	_club_name_lbl.text = club.name
	_club_city_lbl.text = "%s • %s" % [club.city, club.country]
	_reputation_lbl.text = "Reputação: %d / 100" % club.reputation
	if _shield_preview != null:
		_shield_preview.set_colors(c_primary, c_secondary, club.short_name)
		
	# 2. Próximo Confronto
	_match_round_lbl.text = "Rodada %d de %d" % [game_state.current_round, game_state.total_rounds]
	var comp = game_state.get_active_competition()
	var fixtures = comp.get_fixtures_for_round(game_state.current_round) if comp != null else []
	var found_user_match := false
	for fix in fixtures:
		var h_id = str(fix.get("home", ""))
		var a_id = str(fix.get("away", ""))
		if h_id == club.id or a_id == club.id:
			found_user_match = true
			var h_club = game_state.get_club(h_id)
			var a_club = game_state.get_club(a_id)
			var is_home = (h_id == club.id)
			_matchup_lbl.text = "%s 🆚 %s" % [h_club.name if h_club else h_id, a_club.name if a_club else a_id]
			if is_home:
				_match_venue_lbl.text = "Local: Mando de Campo (Em Casa 🏠)"
				_match_venue_lbl.add_theme_color_override("font_color", Color("#22C55E"))
			else:
				_match_venue_lbl.text = "Local: Estádio do Adversário (Fora ✈️)"
				_match_venue_lbl.add_theme_color_override("font_color", Color("#60A5FA"))
			break
	if not found_user_match:
		_matchup_lbl.text = "Fim de Temporada (Sem confrontos)"
		_match_venue_lbl.text = "🏆 Temporada Concluída"
		_play_round_btn.disabled = true
	else:
		_play_round_btn.disabled = false
		_play_round_btn.text = "⚽ Jogar Rodada %d" % game_state.current_round

	# 3. Tabela Resumida
	var standings = comp.get_sorted_standings() if comp != null else []
	for child in _standings_summary_vbox.get_children():
		child.queue_free()
	var user_pos := 1
	for i in range(standings.size()):
		var row = standings[i]
		if str(row.get("club_id", "")) == club.id:
			user_pos = i + 1
			break
	_position_lbl.text = "Posição Atual: %dº Lugar" % user_pos
	
	# Exibe top 3 na mini-tabela
	for i in range(mini(3, standings.size())):
		var r = standings[i]
		var c_id = str(r.get("club_id", ""))
		var target_c = game_state.get_club(c_id)
		var c_name = target_c.name if target_c != null else c_id
		var pts = int(r.get("points", 0))
		var sg = int(r.get("goal_difference", 0))
		var mini_row = Label.new()
		mini_row.text = "%dº %s — %d pts (SG %+d)" % [i + 1, c_name, pts, sg]
		mini_row.add_theme_font_size_override("font_size", 10)
		if c_id == club.id:
			mini_row.add_theme_color_override("font_color", Color.GOLD)
		else:
			mini_row.add_theme_color_override("font_color", Color("#94A3B8"))
		_standings_summary_vbox.add_child(mini_row)

	# 4. Finanças
	_balance_lbl.text = "R$ %d" % club.get_balance()
	var sp = int(club.finances.get("weekly_sponsor", 0))
	_sponsor_lbl.text = "(+) Patrocínio Semanal: R$ %d" % sp
	var wages = game_state.calculate_club_wage_bill(club.id)
	_expenses_lbl.text = "(-) Folha Salarial: R$ %d" % wages
	_ticket_lbl.text = "Preço do Ingresso: R$ %d" % club.get_ticket_price()

	# 5. Elenco
	var tot_ovr := 0
	var count := 0
	var best_name := "--"
	var best_ovr := 0
	for pid in club.squad:
		var p = game_state.get_player(pid)
		if p == null:
			continue
		var ovr = p.calculate_overall()
		if ovr > best_ovr:
			best_ovr = ovr
			best_name = "%s (%d OVR)" % [p.name, ovr]
		if count < 11:
			tot_ovr += ovr
			count += 1
	var avg = int(float(tot_ovr) / float(max(1, count)))
	_avg_overall_lbl.text = "Força Média (Titulares): %d OVR" % avg
	_mentality_lbl.text = "Postura: %s" % str(club.tactics_preset.get("mentality", "BALANCED"))
	_best_player_lbl.text = "Destaque: %s" % best_name

	# 6. Estádio
	var st_id = str(club.facilities.get("stadium_id", ""))
	var stadium = game_state.get_facility(st_id)
	if stadium != null:
		_stadium_name_lbl.text = stadium.name
		_stadium_capacity_lbl.text = "Capacidade: %d lugares (Nív. %d)" % [stadium.get_current_capacity(), stadium.current_level]
		if stadium.is_under_construction:
			_stadium_status_lbl.text = "EM OBRAS: Restam %dr" % stadium.rounds_remaining
			_stadium_status_lbl.add_theme_color_override("font_color", Color.GOLD)
		else:
			_stadium_status_lbl.text = "Status: Operacional"
			_stadium_status_lbl.add_theme_color_override("font_color", Color("#22C55E"))
		if _stadium_preview != null:
			_stadium_preview.set_primary_color(c_primary)


# ==============================================================================
# SUBCLASSES DE PRÉ-VISUALIZAÇÃO COMPACTA
# ==============================================================================

class DashboardShieldPreview extends Control:
	var primary_color: Color = Color("#1D4ED8")
	var secondary_color: Color = Color("#FFFFFF")
	var short_name: String = "CLU"
	
	func set_colors(c1: Color, c2: Color, s_name: String) -> void:
		primary_color = c1
		secondary_color = c2
		short_name = s_name
		queue_redraw()
		
	func _draw() -> void:
		var w = size.x
		var h = size.y
		var poly = PackedVector2Array([
			Vector2(4, 4), Vector2(w - 4, 4),
			Vector2(w - 4, h * 0.58), Vector2(w * 0.5, h - 2),
			Vector2(4, h * 0.58), Vector2(4, 4)
		])
		draw_colored_polygon(poly, primary_color)
		draw_polyline(poly, Color("#EAB308"), 2.0)
		
		# Faixa
		var stripe = PackedVector2Array([
			Vector2(w * 0.3, 4), Vector2(w * 0.6, 4),
			Vector2(w * 0.75, h * 0.6), Vector2(w * 0.45, h * 0.6)
		])
		draw_colored_polygon(stripe, secondary_color)
		
		var font = ThemeDB.fallback_font
		var s_size = font.get_string_size(short_name)
		var s_pos = Vector2((w - s_size.x) * 0.5, h * 0.58)
		draw_string(font, s_pos, short_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.WHITE)


class DashboardStadiumPreview extends Control:
	var primary_color: Color = Color("#1D4ED8")
	
	func set_primary_color(c: Color) -> void:
		primary_color = c
		queue_redraw()
		
	func _draw() -> void:
		var cx = size.x * 0.5
		var cy = size.y * 0.55
		var w = 52.0
		var h = 26.0
		
		var top = Vector2(cx, cy - h * 0.5)
		var right = Vector2(cx + w * 0.5, cy)
		var bottom = Vector2(cx, cy + h * 0.5)
		var left = Vector2(cx - w * 0.5, cy)
		
		var diamond = PackedVector2Array([top, right, bottom, left])
		draw_colored_polygon(diamond, primary_color)
		draw_polyline(diamond, Color.WHITE, 1.2)
		
		var center = Vector2(cx, cy)
		var pitch = PackedVector2Array([
			center + (top - center) * 0.55,
			center + (right - center) * 0.55,
			center + (bottom - center) * 0.55,
			center + (left - center) * 0.55
		])
		draw_colored_polygon(pitch, Color("#16A34A"))
