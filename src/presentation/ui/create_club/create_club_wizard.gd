class_name CreateClubWizard
extends Control

const ClubDataClass = preload("res://src/core/club/club_data.gd")
const FacilityDataClass = preload("res://src/core/facility/facility_data.gd")
const AudioServiceClass = preload("res://src/systems/audio/audio_service.gd")

signal club_confirmed(chosen_club_id: String)
signal back_requested()

var game_state: RefCounted

# Elementos de compatibilidade e contratos existentes
var _tab_container: TabContainer
var _existing_clubs_list: ItemList
var _club_preview_label: Label
var _confirm_existing_btn: Button

# Campos de novo clube
var _name_edit: LineEdit
var _short_name_edit: LineEdit
var _city_edit: LineEdit
var _stadium_name_edit: LineEdit
var _color_primary_btn: ColorPickerButton
var _color_secondary_btn: ColorPickerButton
var _confirm_new_btn: Button

# Elementos da Nova UI Refinada
var _mode_traditional_btn: Button
var _mode_custom_btn: Button
var _traditional_panel: VBoxContainer
var _custom_panel: VBoxContainer

# Elementos do Live Preview
var _preview_club_name_lbl: Label
var _preview_city_lbl: Label
var _preview_shield: Control
var _preview_kit: Control
var _preview_stadium: Control
var _preview_balance_lbl: Label
var _preview_reputation_lbl: Label
var _preview_squad_lbl: Label
var _preview_stadium_lbl: Label

# Estado do Live Preview
var _current_mode: int = 0 # 0 = Tradicional, 1 = Customizado
var _preview_name: String = "Aurora FC"
var _preview_short_name: String = "AUR"
var _preview_city: String = "Serra Alta"
var _preview_stadium_name: String = "Estádio das Colinas"
var _preview_primary_color: Color = Color("#1D4ED8")
var _preview_secondary_color: Color = Color("#FFFFFF")
var _preview_balance: int = 200000
var _preview_reputation: int = 50
var _preview_squad_count: int = 16

# ==============================================================================
# 1. CICLO DE VIDA DO NÓ
# ==============================================================================

func _ready() -> void:
	_ensure_full_rect()
	_build_ui_structure()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED or what == NOTIFICATION_ENTER_TREE:
		_ensure_full_rect()
	elif what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		_ensure_full_rect()
		_update_live_preview()

func _ensure_full_rect() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH

# ==============================================================================
# 2. CONSTRUÇÃO DA INTERFACE (TWO-PANE LAYOUT + LIVE PREVIEW)
# ==============================================================================

func _build_ui_structure() -> void:
	if _existing_clubs_list != null:
		return
		
	_ensure_full_rect()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# --------------------------------------------------------------------------
	# A. Fundo Escuro Esportivo
	# --------------------------------------------------------------------------
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.06, 0.08, 0.12)
	add_child(bg)
	
	# --------------------------------------------------------------------------
	# B. Layout Principal com Margem
	# --------------------------------------------------------------------------
	var margin_box = MarginContainer.new()
	margin_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_box.add_theme_constant_override("margin_left", 36)
	margin_box.add_theme_constant_override("margin_top", 20)
	margin_box.add_theme_constant_override("margin_right", 36)
	margin_box.add_theme_constant_override("margin_bottom", 20)
	add_child(margin_box)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 14)
	margin_box.add_child(main_vbox)
	
	# --------------------------------------------------------------------------
	# C. Barra Superior (TopBar: Botão Voltar + Título Central)
	# --------------------------------------------------------------------------
	var topbar = HBoxContainer.new()
	topbar.add_theme_constant_override("separation", 16)
	main_vbox.add_child(topbar)
	
	var back_btn = Button.new()
	back_btn.text = " ◄ Voltar ao Menu "
	back_btn.custom_minimum_size = Vector2(140, 36)
	var back_st = StyleBoxFlat.new()
	back_st.bg_color = Color(0.14, 0.18, 0.25)
	back_st.border_color = Color("#3A475C")
	back_st.border_width_left = 1
	back_st.border_width_top = 1
	back_st.border_width_right = 1
	back_st.border_width_bottom = 1
	back_st.corner_radius_top_left = 6
	back_st.corner_radius_top_right = 6
	back_st.corner_radius_bottom_left = 6
	back_st.corner_radius_bottom_right = 6
	back_btn.add_theme_stylebox_override("normal", back_st)
	back_btn.pressed.connect(func():
		AudioServiceClass.get_instance().play_click()
		back_requested.emit()
	)
	topbar.add_child(back_btn)
	
	var title_lbl = Label.new()
	title_lbl.text = "NOVA CARREIRA: ESCOLHA SEU DESTINO"
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color("#F8FAFC"))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	topbar.add_child(title_lbl)
	
	var league_badge = PanelContainer.new()
	var badge_st = StyleBoxFlat.new()
	badge_st.bg_color = Color("#EAB308")
	badge_st.corner_radius_top_left = 4
	badge_st.corner_radius_top_right = 4
	badge_st.corner_radius_bottom_left = 4
	badge_st.corner_radius_bottom_right = 4
	badge_st.content_margin_left = 8
	badge_st.content_margin_right = 8
	badge_st.content_margin_top = 2
	badge_st.content_margin_bottom = 2
	league_badge.add_theme_stylebox_override("panel", badge_st)
	topbar.add_child(league_badge)
	
	var badge_lbl = Label.new()
	badge_lbl.text = "LIGA INAUGURAL"
	badge_lbl.add_theme_font_size_override("font_size", 10)
	badge_lbl.add_theme_color_override("font_color", Color("#0F172A"))
	league_badge.add_child(badge_lbl)
	
	# --------------------------------------------------------------------------
	# D. Seletor de Modo (Dois Caminhos)
	# --------------------------------------------------------------------------
	var mode_bar = HBoxContainer.new()
	mode_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_bar.add_theme_constant_override("separation", 12)
	main_vbox.add_child(mode_bar)
	
	_mode_traditional_btn = Button.new()
	_mode_traditional_btn.text = "🛡️ 1. Comandar Clube Tradicional"
	_mode_traditional_btn.custom_minimum_size = Vector2(240, 38)
	_mode_traditional_btn.pressed.connect(func(): _switch_mode(0))
	mode_bar.add_child(_mode_traditional_btn)
	
	_mode_custom_btn = Button.new()
	_mode_custom_btn.text = "✨ 2. Fundar Novo Clube (Create-a-Club)"
	_mode_custom_btn.custom_minimum_size = Vector2(250, 38)
	_mode_custom_btn.pressed.connect(func(): _switch_mode(1))
	mode_bar.add_child(_mode_custom_btn)
	
	# --------------------------------------------------------------------------
	# E. Corpo Dividido em Duas Colunas (Two-Pane Layout)
	# --------------------------------------------------------------------------
	var body_split = HBoxContainer.new()
	body_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_split.add_theme_constant_override("separation", 24)
	main_vbox.add_child(body_split)
	
	# ==========================================================================
	# COLUNA ESQUERDA: CONFIGURAÇÃO / SELEÇÃO
	# ==========================================================================
	var left_panel = PanelContainer.new()
	left_panel.custom_minimum_size = Vector2(490, 0)
	left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var left_st = StyleBoxFlat.new()
	left_st.bg_color = Color(0.10, 0.13, 0.18, 0.90)
	left_st.border_color = Color("#3A475C")
	left_st.border_width_left = 1
	left_st.border_width_top = 1
	left_st.border_width_right = 1
	left_st.border_width_bottom = 1
	left_st.corner_radius_top_left = 10
	left_st.corner_radius_top_right = 10
	left_st.corner_radius_bottom_left = 10
	left_st.corner_radius_bottom_right = 10
	left_st.content_margin_left = 20
	left_st.content_margin_right = 20
	left_st.content_margin_top = 16
	left_st.content_margin_bottom = 16
	left_panel.add_theme_stylebox_override("panel", left_st)
	body_split.add_child(left_panel)
	
	var left_vbox = VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 10)
	left_panel.add_child(left_vbox)
	
	# --- MODO 1: Clube Tradicional ---
	_traditional_panel = VBoxContainer.new()
	_traditional_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_traditional_panel.add_theme_constant_override("separation", 10)
	left_vbox.add_child(_traditional_panel)
	
	var trad_title = Label.new()
	trad_title.text = "Selecione um dos 8 clubes fundadores:"
	trad_title.add_theme_font_size_override("font_size", 13)
	trad_title.add_theme_color_override("font_color", Color("#94A3B8"))
	_traditional_panel.add_child(trad_title)
	
	_existing_clubs_list = ItemList.new()
	_existing_clubs_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_existing_clubs_list.item_selected.connect(_on_existing_club_selected)
	_traditional_panel.add_child(_existing_clubs_list)
	
	_confirm_existing_btn = Button.new()
	_confirm_existing_btn.text = "⚽ Assumir o Comando Deste Clube"
	_confirm_existing_btn.custom_minimum_size = Vector2(0, 44)
	var conf_trad_st = StyleBoxFlat.new()
	conf_trad_st.bg_color = Color("#2563EB")
	conf_trad_st.corner_radius_top_left = 6
	conf_trad_st.corner_radius_top_right = 6
	conf_trad_st.corner_radius_bottom_left = 6
	conf_trad_st.corner_radius_bottom_right = 6
	_confirm_existing_btn.add_theme_stylebox_override("normal", conf_trad_st)
	_confirm_existing_btn.pressed.connect(_on_confirm_existing_pressed)
	_traditional_panel.add_child(_confirm_existing_btn)
	
	# --- MODO 2: Fundar Novo Clube ---
	_custom_panel = VBoxContainer.new()
	_custom_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_custom_panel.add_theme_constant_override("separation", 10)
	_custom_panel.visible = false
	left_vbox.add_child(_custom_panel)
	
	var form_scroll = ScrollContainer.new()
	form_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_custom_panel.add_child(form_scroll)
	
	var form_vbox = VBoxContainer.new()
	form_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	form_vbox.add_theme_constant_override("separation", 10)
	form_scroll.add_child(form_vbox)
	
	# Seção 1: Identidade
	form_vbox.add_child(_create_section_header("1. Identidade da Agremiação"))
	
	form_vbox.add_child(_create_field_label("Nome do Clube:"))
	_name_edit = LineEdit.new()
	_name_edit.text = "Serra Dourada Futebol Clube"
	_name_edit.text_changed.connect(func(_t: String): _on_custom_field_changed())
	form_vbox.add_child(_name_edit)
	
	var row_id = HBoxContainer.new()
	row_id.add_theme_constant_override("separation", 12)
	form_vbox.add_child(row_id)
	
	var sigla_vbox = VBoxContainer.new()
	sigla_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_id.add_child(sigla_vbox)
	sigla_vbox.add_child(_create_field_label("Sigla (3-5 letras):"))
	_short_name_edit = LineEdit.new()
	_short_name_edit.text = "SDF"
	_short_name_edit.max_length = 5
	_short_name_edit.text_changed.connect(func(_t: String): _on_custom_field_changed())
	sigla_vbox.add_child(_short_name_edit)
	
	var city_vbox = VBoxContainer.new()
	city_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_id.add_child(city_vbox)
	city_vbox.add_child(_create_field_label("Cidade Sede:"))
	_city_edit = LineEdit.new()
	_city_edit.text = "Serra Alta"
	_city_edit.text_changed.connect(func(_t: String): _on_custom_field_changed())
	city_vbox.add_child(_city_edit)
	
	# Seção 2: Estádio
	form_vbox.add_child(_create_section_header("2. Estádio da Fundação"))
	form_vbox.add_child(_create_field_label("Nome do Estádio:"))
	_stadium_name_edit = LineEdit.new()
	_stadium_name_edit.text = "Arena da Serra"
	_stadium_name_edit.text_changed.connect(func(_t: String): _on_custom_field_changed())
	form_vbox.add_child(_stadium_name_edit)
	
	# Seção 3: Cores Oficiais
	form_vbox.add_child(_create_section_header("3. Cores Oficiais & Uniforme"))
	var colors_row = HBoxContainer.new()
	colors_row.add_theme_constant_override("separation", 16)
	form_vbox.add_child(colors_row)
	
	var c1_box = VBoxContainer.new()
	c1_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	colors_row.add_child(c1_box)
	c1_box.add_child(_create_field_label("Cor Primária:"))
	_color_primary_btn = ColorPickerButton.new()
	_color_primary_btn.color = Color("#E6A100")
	_color_primary_btn.color_changed.connect(func(_c: Color): _on_custom_field_changed())
	c1_box.add_child(_color_primary_btn)
	
	var c2_box = VBoxContainer.new()
	c2_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	colors_row.add_child(c2_box)
	c2_box.add_child(_create_field_label("Cor Secundária:"))
	_color_secondary_btn = ColorPickerButton.new()
	_color_secondary_btn.color = Color("#111111")
	_color_secondary_btn.color_changed.connect(func(_c: Color): _on_custom_field_changed())
	c2_box.add_child(_color_secondary_btn)
	
	# Paletas Esportivas Recomendadas em 1 Clique
	form_vbox.add_child(_create_field_label("Paletas Prontas (Clique para aplicar):"))
	var palettes_grid = GridContainer.new()
	palettes_grid.columns = 3
	palettes_grid.add_theme_constant_override("h_separation", 6)
	palettes_grid.add_theme_constant_override("v_separation", 6)
	form_vbox.add_child(palettes_grid)
	
	palettes_grid.add_child(_create_palette_btn("🔵 Celeste", Color("#1D4ED8"), Color("#FFFFFF")))
	palettes_grid.add_child(_create_palette_btn("🔴 Rubro-Negro", Color("#DC2626"), Color("#111827")))
	palettes_grid.add_child(_create_palette_btn("🟢 Esmeralda", Color("#16A34A"), Color("#FFFFFF")))
	palettes_grid.add_child(_create_palette_btn("🟡 Canarinho", Color("#FBBF24"), Color("#1E3A8A")))
	palettes_grid.add_child(_create_palette_btn("🟣 Grená", Color("#831843"), Color("#EAB308")))
	palettes_grid.add_child(_create_palette_btn("⚫ Alvinegro", Color("#18181B"), Color("#F8FAFC")))
	
	_confirm_new_btn = Button.new()
	_confirm_new_btn.text = "🚀 Fundar Clube e Iniciar Carreira"
	_confirm_new_btn.custom_minimum_size = Vector2(0, 44)
	var conf_new_st = StyleBoxFlat.new()
	conf_new_st.bg_color = Color("#16A34A")
	conf_new_st.corner_radius_top_left = 6
	conf_new_st.corner_radius_top_right = 6
	conf_new_st.corner_radius_bottom_left = 6
	conf_new_st.corner_radius_bottom_right = 6
	_confirm_new_btn.add_theme_stylebox_override("normal", conf_new_st)
	_confirm_new_btn.pressed.connect(_on_confirm_new_pressed)
	_custom_panel.add_child(_confirm_new_btn)
	
	# ==========================================================================
	# COLUNA DIREITA: LIVE PREVIEW (ESCUDO + CAMISA + ESTÁDIO)
	# ==========================================================================
	var right_panel = PanelContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var right_st = StyleBoxFlat.new()
	right_st.bg_color = Color(0.10, 0.13, 0.18, 0.90)
	right_st.border_color = Color("#3A475C")
	right_st.border_width_left = 1
	right_st.border_width_top = 1
	right_st.border_width_right = 1
	right_st.border_width_bottom = 1
	right_st.corner_radius_top_left = 10
	right_st.corner_radius_top_right = 10
	right_st.corner_radius_bottom_left = 10
	right_st.corner_radius_bottom_right = 10
	right_st.content_margin_left = 24
	right_st.content_margin_right = 24
	right_st.content_margin_top = 16
	right_st.content_margin_bottom = 16
	right_panel.add_theme_stylebox_override("panel", right_st)
	body_split.add_child(right_panel)
	
	var right_vbox = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 14)
	right_panel.add_child(right_vbox)
	
	var preview_header = HBoxContainer.new()
	right_vbox.add_child(preview_header)
	
	var prev_tag = Label.new()
	prev_tag.text = "PRÉ-VISUALIZAÇÃO EM TEMPO REAL"
	prev_tag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prev_tag.add_theme_font_size_override("font_size", 12)
	prev_tag.add_theme_color_override("font_color", Color("#EAB308"))
	preview_header.add_child(prev_tag)
	
	# Título do Clube em Destaque
	var club_header_box = VBoxContainer.new()
	club_header_box.add_theme_constant_override("separation", 2)
	right_vbox.add_child(club_header_box)
	
	_preview_club_name_lbl = Label.new()
	_preview_club_name_lbl.text = "AURORA FUTEBOL CLUBE"
	_preview_club_name_lbl.add_theme_font_size_override("font_size", 20)
	_preview_club_name_lbl.add_theme_color_override("font_color", Color("#F8FAFC"))
	club_header_box.add_child(_preview_club_name_lbl)
	
	_preview_city_lbl = Label.new()
	_preview_city_lbl.text = "Serra Alta • Brasil"
	_preview_city_lbl.add_theme_font_size_override("font_size", 12)
	_preview_city_lbl.add_theme_color_override("font_color", Color("#94A3B8"))
	club_header_box.add_child(_preview_city_lbl)
	
	right_vbox.add_child(HSeparator.new())
	
	# Área Visual dos 3 Componentes Vivos (Escudo, Camisa, Estádio)
	var visual_showcase = HBoxContainer.new()
	visual_showcase.alignment = BoxContainer.ALIGNMENT_CENTER
	visual_showcase.add_theme_constant_override("separation", 24)
	right_vbox.add_child(visual_showcase)
	
	# 1. Escudo
	var shield_box = VBoxContainer.new()
	shield_box.alignment = BoxContainer.ALIGNMENT_CENTER
	visual_showcase.add_child(shield_box)
	_preview_shield = ClubShieldPreview.new()
	_preview_shield.custom_minimum_size = Vector2(80, 96)
	shield_box.add_child(_preview_shield)
	var shield_cap = Label.new()
	shield_cap.text = "Escudo Oficial"
	shield_cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shield_cap.add_theme_font_size_override("font_size", 10)
	shield_cap.add_theme_color_override("font_color", Color("#94A3B8"))
	shield_box.add_child(shield_cap)
	
	# 2. Camisa
	var kit_box = VBoxContainer.new()
	kit_box.alignment = BoxContainer.ALIGNMENT_CENTER
	visual_showcase.add_child(kit_box)
	_preview_kit = ClubKitPreview.new()
	_preview_kit.custom_minimum_size = Vector2(80, 96)
	kit_box.add_child(_preview_kit)
	var kit_cap = Label.new()
	kit_cap.text = "Uniforme Titular"
	kit_cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kit_cap.add_theme_font_size_override("font_size", 10)
	kit_cap.add_theme_color_override("font_color", Color("#94A3B8"))
	kit_box.add_child(kit_cap)
	
	# 3. Estádio
	var stadium_box = VBoxContainer.new()
	stadium_box.alignment = BoxContainer.ALIGNMENT_CENTER
	visual_showcase.add_child(stadium_box)
	_preview_stadium = ClubStadiumPreview.new()
	_preview_stadium.custom_minimum_size = Vector2(96, 96)
	stadium_box.add_child(_preview_stadium)
	var stadium_cap = Label.new()
	stadium_cap.text = "Estádio Isométrico"
	stadium_cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stadium_cap.add_theme_font_size_override("font_size", 10)
	stadium_cap.add_theme_color_override("font_color", Color("#94A3B8"))
	stadium_box.add_child(stadium_cap)
	
	right_vbox.add_child(HSeparator.new())
	
	# Grade com 4 Cards de Métricas
	var metrics_grid = GridContainer.new()
	metrics_grid.columns = 2
	metrics_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	metrics_grid.add_theme_constant_override("h_separation", 12)
	metrics_grid.add_theme_constant_override("v_separation", 10)
	right_vbox.add_child(metrics_grid)
	
	_preview_balance_lbl = _create_metric_card(metrics_grid, "💰 Saldo em Caixa Inicial:", "R$ 200.000", Color("#16A34A"))
	_preview_reputation_lbl = _create_metric_card(metrics_grid, "⭐ Reputação do Clube:", "50 / 100", Color("#EAB308"))
	_preview_squad_lbl = _create_metric_card(metrics_grid, "👥 Elenco Disponível:", "16 Atletas", Color("#F8FAFC"))
	_preview_stadium_lbl = _create_metric_card(metrics_grid, "🏟️ Estádio da Equipe:", "Capacidade: 3.000", Color("#F8FAFC"))
	
	# Label de compatibilidade com testes anteriores
	_club_preview_label = Label.new()
	_club_preview_label.visible = false
	add_child(_club_preview_label)
	
	_update_mode_buttons()

func _create_section_header(title: String) -> Control:
	var lbl = Label.new()
	lbl.text = title
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color("#EAB308"))
	return lbl

func _create_field_label(text: String) -> Control:
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color("#94A3B8"))
	return lbl

func _create_metric_card(parent: Container, title: String, default_val: String, val_color: Color) -> Label:
	var p = PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.14, 0.18, 0.25, 0.85)
	st.corner_radius_top_left = 6
	st.corner_radius_top_right = 6
	st.corner_radius_bottom_left = 6
	st.corner_radius_bottom_right = 6
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	p.add_theme_stylebox_override("panel", st)
	parent.add_child(p)
	
	var v = VBoxContainer.new()
	p.add_child(v)
	
	var t = Label.new()
	t.text = title
	t.add_theme_font_size_override("font_size", 10)
	t.add_theme_color_override("font_color", Color("#94A3B8"))
	v.add_child(t)
	
	var val_lbl = Label.new()
	val_lbl.text = default_val
	val_lbl.add_theme_font_size_override("font_size", 13)
	val_lbl.add_theme_color_override("font_color", val_color)
	v.add_child(val_lbl)
	
	return val_lbl

func _create_palette_btn(title: String, c1: Color, c2: Color) -> Button:
	var btn = Button.new()
	btn.text = title
	btn.custom_minimum_size = Vector2(0, 30)
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.16, 0.20, 0.28)
	st.border_color = c1
	st.border_width_left = 3
	st.corner_radius_top_left = 4
	st.corner_radius_top_right = 4
	st.corner_radius_bottom_left = 4
	st.corner_radius_bottom_right = 4
	st.content_margin_left = 8
	btn.add_theme_stylebox_override("normal", st)
	btn.pressed.connect(func():
		AudioServiceClass.get_instance().play_click()
		_color_primary_btn.color = c1
		_color_secondary_btn.color = c2
		_on_custom_field_changed()
	)
	return btn

# ==============================================================================
# 3. ALTERNÂNCIA DE MODOS (TRADICIONAL VS CUSTOMIZADO)
# ==============================================================================

func _switch_mode(mode: int) -> void:
	AudioServiceClass.get_instance().play_click()
	_current_mode = mode
	_traditional_panel.visible = (_current_mode == 0)
	_custom_panel.visible = (_current_mode == 1)
	_update_mode_buttons()
	
	if _current_mode == 0 and _existing_clubs_list.get_selected_items().size() > 0:
		_on_existing_club_selected(_existing_clubs_list.get_selected_items()[0])
	else:
		_on_custom_field_changed()

func _update_mode_buttons() -> void:
	var active_st = StyleBoxFlat.new()
	active_st.bg_color = Color("#2563EB")
	active_st.border_color = Color("#60A5FA")
	active_st.border_width_left = 1
	active_st.border_width_top = 1
	active_st.border_width_right = 1
	active_st.border_width_bottom = 1
	active_st.corner_radius_top_left = 6
	active_st.corner_radius_top_right = 6
	active_st.corner_radius_bottom_left = 6
	active_st.corner_radius_bottom_right = 6
	
	var inactive_st = StyleBoxFlat.new()
	inactive_st.bg_color = Color("#1A202C")
	inactive_st.border_color = Color("#3A475C")
	inactive_st.border_width_left = 1
	inactive_st.border_width_top = 1
	inactive_st.border_width_right = 1
	inactive_st.border_width_bottom = 1
	inactive_st.corner_radius_top_left = 6
	inactive_st.corner_radius_top_right = 6
	inactive_st.corner_radius_bottom_left = 6
	inactive_st.corner_radius_bottom_right = 6
	
	if _current_mode == 0:
		_mode_traditional_btn.add_theme_stylebox_override("normal", active_st)
		_mode_custom_btn.add_theme_stylebox_override("normal", inactive_st)
	else:
		_mode_traditional_btn.add_theme_stylebox_override("normal", inactive_st)
		_mode_custom_btn.add_theme_stylebox_override("normal", active_st)

# ==============================================================================
# 4. CARGA DE DADOS E SINCRONIZAÇÃO
# ==============================================================================

func setup(p_game_state: RefCounted) -> void:
	_ensure_full_rect()
	_build_ui_structure()
	game_state = p_game_state
	refresh_existing_clubs()

func refresh_existing_clubs() -> void:
	if game_state == null:
		return
		
	_existing_clubs_list.clear()
	for cid in game_state.clubs:
		var club = game_state.clubs[cid]
		_existing_clubs_list.add_item("%s (%s)" % [club.name, club.short_name])
		_existing_clubs_list.set_item_metadata(_existing_clubs_list.get_item_count() - 1, cid)
		
	if _existing_clubs_list.get_item_count() > 0:
		_existing_clubs_list.select(0)
		_on_existing_club_selected(0)

func _on_existing_club_selected(index: int) -> void:
	if game_state == null:
		return
	var cid = str(_existing_clubs_list.get_item_metadata(index))
	var club = game_state.get_club(cid)
	if club != null:
		_preview_name = club.name
		_preview_short_name = club.short_name
		_preview_city = "%s • %s" % [club.city, club.country]
		_preview_primary_color = Color(str(club.colors.get("primary", "#1D4ED8")))
		_preview_secondary_color = Color(str(club.colors.get("secondary", "#FFFFFF")))
		_preview_balance = club.get_balance()
		_preview_reputation = club.reputation
		_preview_squad_count = club.squad.size()
		
		# Busca estádio
		var st_id = str(club.facilities.get("stadium_id", ""))
		var stadium = game_state.get_facility(st_id)
		if stadium != null:
			_preview_stadium_name = stadium.name
		else:
			_preview_stadium_name = "Estádio Municipal"
			
		_update_live_preview()

func _on_custom_field_changed() -> void:
	_preview_name = _name_edit.text.strip_edges()
	_preview_short_name = _short_name_edit.text.strip_edges().to_upper()
	_preview_city = "%s • Brasil" % _city_edit.text.strip_edges()
	_preview_stadium_name = _stadium_name_edit.text.strip_edges()
	_preview_primary_color = _color_primary_btn.color
	_preview_secondary_color = _color_secondary_btn.color
	_preview_balance = 200000
	_preview_reputation = 45
	_preview_squad_count = 16
	_update_live_preview()

func _update_live_preview() -> void:
	if _preview_club_name_lbl == null:
		return
		
	_preview_club_name_lbl.text = _preview_name.to_upper()
	_preview_city_lbl.text = _preview_city
	_preview_balance_lbl.text = "R$ %d" % _preview_balance
	_preview_reputation_lbl.text = "%d / 100" % _preview_reputation
	_preview_squad_lbl.text = "%d Atletas" % _preview_squad_count
	_preview_stadium_lbl.text = "%s (Nív. 1)" % _preview_stadium_name
	
	if _preview_shield != null:
		_preview_shield.set_colors(_preview_primary_color, _preview_secondary_color, _preview_short_name)
	if _preview_kit != null:
		_preview_kit.set_colors(_preview_primary_color, _preview_secondary_color)
	if _preview_stadium != null:
		_preview_stadium.set_primary_color(_preview_primary_color)
		
	# Atualiza label oculta de compatibilidade
	if _club_preview_label != null:
		_club_preview_label.text = "CLUBE: %s (%s)\nReputação: %d | Saldo: R$ %d" % [
			_preview_name, _preview_short_name, _preview_reputation, _preview_balance
		]

# ==============================================================================
# 5. CONFIRMAÇÕES DE INÍCIO DE CARREIRA
# ==============================================================================

func _on_confirm_existing_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	var sel = _existing_clubs_list.get_selected_items()
	if sel.is_empty():
		return
	var cid = str(_existing_clubs_list.get_item_metadata(sel[0]))
	if game_state != null:
		game_state.user_club_id = cid
	club_confirmed.emit(cid)

func _on_confirm_new_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	if game_state == null:
		return
		
	var target_club_id = str(game_state.user_club_id)
	var club = game_state.get_club(target_club_id)
	if club == null and not game_state.clubs.is_empty():
		club = game_state.clubs.values()[0]
		target_club_id = str(club.id)
		
	if club != null:
		club.name = _name_edit.text.strip_edges()
		club.short_name = _short_name_edit.text.strip_edges()
		club.city = _city_edit.text.strip_edges()
		club.colors["primary"] = "#" + _color_primary_btn.color.to_html(false)
		club.colors["secondary"] = "#" + _color_secondary_btn.color.to_html(false)
		
		var stadium_id = str(club.facilities.get("stadium_id", ""))
		if stadium_id.is_empty():
			stadium_id = "facility-estadio-%s" % club.id
			club.facilities["stadium_id"] = stadium_id
		var stadium = game_state.get_facility(stadium_id)
		if stadium == null:
			stadium = FacilityDataClass.new()
			stadium.id = stadium_id
			stadium.club_id = club.id
			stadium.type = "STADIUM"
			stadium.grid_x = 12
			stadium.grid_y = 8
			stadium.current_level = 1
			stadium.levels = [{
				"level": 1, "name": "Estádio Comunitário", "capacity": 3000,
				"maintenance_cost_per_round": 1200, "upgrade_cost": 0, "construction_time_rounds": 0,
				"visual": { "footprint_width": 4, "footprint_height": 4 }
			}]
			game_state.facilities[stadium_id] = stadium
		stadium.name = _stadium_name_edit.text.strip_edges()
			
	game_state.user_club_id = target_club_id
	club_confirmed.emit(target_club_id)


# ==============================================================================
# 6. SUBCLASSES DE PRÉ-VISUALIZAÇÃO VETORIAL AO VIVO
# ==============================================================================

## Escudo do Clube desenhado proceduralmente com sigla dinâmica
class ClubShieldPreview extends Control:
	var primary_color: Color = Color("#1D4ED8")
	var secondary_color: Color = Color("#FFFFFF")
	var short_name: String = "AUR"
	
	func set_colors(c1: Color, c2: Color, s_name: String) -> void:
		primary_color = c1
		secondary_color = c2
		short_name = s_name
		queue_redraw()
	
	func _draw() -> void:
		var w = size.x
		var h = size.y
		
		var top_l = Vector2(4, 6)
		var top_r = Vector2(w - 4, 6)
		var mid_r = Vector2(w - 4, h * 0.58)
		var bot_tip = Vector2(w * 0.5, h - 4)
		var mid_l = Vector2(4, h * 0.58)
		
		var shield_poly = PackedVector2Array([top_l, top_r, mid_r, bot_tip, mid_l])
		
		# Fundo Primário
		draw_colored_polygon(shield_poly, primary_color)
		
		# Metade ou Faixa Secundária
		var stripe_poly = PackedVector2Array([
			Vector2(w * 0.25, 6),
			Vector2(w * 0.55, 6),
			Vector2(w * 0.75, h * 0.65),
			Vector2(w * 0.45, h * 0.65)
		])
		draw_colored_polygon(stripe_poly, secondary_color)
		
		# Borda Externa
		var border_pts = PackedVector2Array([top_l, top_r, mid_r, bot_tip, mid_l, top_l])
		draw_polyline(border_pts, Color("#EAB308"), 2.5)
		
		# Sigla no Centro
		var font = ThemeDB.fallback_font
		var txt_size = font.get_string_size(short_name)
		var txt_pos = Vector2((w - txt_size.x) * 0.5, h * 0.55)
		draw_string(font, txt_pos + Vector2(1, 1), short_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.BLACK)
		draw_string(font, txt_pos, short_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.WHITE)


## Uniforme Titular (Camisa + Calção) desenhado em pixel art limpa
class ClubKitPreview extends Control:
	var primary_color: Color = Color("#1D4ED8")
	var secondary_color: Color = Color("#FFFFFF")
	
	func set_colors(c1: Color, c2: Color) -> void:
		primary_color = c1
		secondary_color = c2
		queue_redraw()
	
	func _draw() -> void:
		var cx = size.x * 0.5
		
		# 1. Corpo da Camisa (34 x 42 px)
		var body_rect = Rect2(cx - 17, 16, 34, 42)
		draw_rect(body_rect, primary_color)
		draw_rect(body_rect, Color(0.1, 0.1, 0.1), false, 1.5)
		
		# Faixa central no peito
		draw_rect(Rect2(cx - 6, 16, 12, 42), secondary_color)
		
		# Mangas
		var sleeve_l = PackedVector2Array([
			Vector2(cx - 17, 16),
			Vector2(cx - 30, 28),
			Vector2(cx - 24, 34),
			Vector2(cx - 17, 26)
		])
		draw_colored_polygon(sleeve_l, primary_color)
		draw_polyline(sleeve_l, Color(0.1, 0.1, 0.1), 1.0)
		
		var sleeve_r = PackedVector2Array([
			Vector2(cx + 17, 16),
			Vector2(cx + 30, 28),
			Vector2(cx + 24, 34),
			Vector2(cx + 17, 26)
		])
		draw_colored_polygon(sleeve_r, primary_color)
		draw_polyline(sleeve_r, Color(0.1, 0.1, 0.1), 1.0)
		
		# Gola
		draw_circle(Vector2(cx, 16), 5.0, secondary_color)
		
		# 2. Calção (28 x 22 px)
		var shorts_rect = Rect2(cx - 14, 60, 28, 22)
		draw_rect(shorts_rect, secondary_color)
		draw_rect(shorts_rect, Color(0.1, 0.1, 0.1), false, 1.5)
		draw_line(Vector2(cx, 68), Vector2(cx, 82), Color(0.1, 0.1, 0.1), 1.5)


## Miniatura isométrica do Estádio com teto na cor primária
class ClubStadiumPreview extends Control:
	var primary_color: Color = Color("#1D4ED8")
	
	func set_primary_color(c: Color) -> void:
		primary_color = c
		queue_redraw()
	
	func _draw() -> void:
		var cx = size.x * 0.5
		var cy = size.y * 0.55
		var w = 72.0
		var h = 36.0
		
		# 1. Base do Estádio (Losango Isométrico)
		var top = Vector2(cx, cy - h * 0.5)
		var right = Vector2(cx + w * 0.5, cy)
		var bottom = Vector2(cx, cy + h * 0.5)
		var left = Vector2(cx - w * 0.5, cy)
		
		var base_poly = PackedVector2Array([top, right, bottom, left])
		draw_colored_polygon(base_poly, primary_color.darkened(0.2))
		draw_polyline(base_poly, Color("#111827"), 1.5)
		
		# 2. Arquibancada / Cobertura Elevada (-18 px)
		var elev = Vector2(0, -18)
		var t_elev = top + elev
		var r_elev = right + elev
		var b_elev = bottom + elev
		var l_elev = left + elev
		
		# Paredes externas
		var wall_l = PackedVector2Array([left, bottom, b_elev, l_elev])
		draw_colored_polygon(wall_l, primary_color.darkened(0.4))
		draw_polyline(wall_l, Color("#111827"), 1.0)
		
		var wall_r = PackedVector2Array([bottom, right, r_elev, b_elev])
		draw_colored_polygon(wall_r, primary_color.darkened(0.3))
		draw_polyline(wall_r, Color("#111827"), 1.0)
		
		# Cobertura Superior
		var roof_poly = PackedVector2Array([t_elev, r_elev, b_elev, l_elev])
		draw_colored_polygon(roof_poly, primary_color)
		draw_polyline(roof_poly, Color.WHITE, 1.5)
		
		# 3. Campo de Gramado no Centro da Cobertura
		var pitch_scale = 0.55
		var p_center = (t_elev + b_elev) * 0.5
		var pitch_poly = PackedVector2Array([
			p_center + (t_elev - p_center) * pitch_scale,
			p_center + (r_elev - p_center) * pitch_scale,
			p_center + (b_elev - p_center) * pitch_scale,
			p_center + (l_elev - p_center) * pitch_scale
		])
		draw_colored_polygon(pitch_poly, Color("#16A34A"))
		draw_polyline(pitch_poly, Color.WHITE, 1.0)
