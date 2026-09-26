class_name MainMenu
extends Control

const SaveManagerClass = preload("res://src/systems/save_system/save_manager.gd")
const AudioServiceClass = preload("res://src/systems/audio/audio_service.gd")

signal new_career_requested()
signal continue_career_requested()
signal quit_requested()

# Componentes de interface principais exigidos por contratos e testes
var _new_btn: Button
var _continue_btn: Button
var _quit_btn: Button
var _options_btn: Button
var _credits_btn: Button
var _save_info_label: Label

# Elementos visuais e containers centrais
var _backdrop: Control
var _center_container: CenterContainer
var _main_panel_container: PanelContainer
var _content_vbox: VBoxContainer
var _header_vbox: VBoxContainer
var _shield_logo: Control
var _buttons_vbox: VBoxContainer
var _save_banner_panel: PanelContainer
var _save_banner_content: Control
var _footer_container: HBoxContainer

# Modais flutuantes
var _options_modal: Control
var _credits_modal: Control
var _sound_toggle_btn: CheckButton
var _volume_slider: HSlider
var _volume_percent_label: Label
var _fullscreen_btn: Button

# Armazenamento de estado
var _latest_save_data: Dictionary = {}
var _menu_buttons_list: Array[Button] = []

# ==============================================================================
# 1. CICLO DE VIDA DO NÓ
# ==============================================================================

func _ready() -> void:
	_ensure_full_rect()
	_build_ui_structure()
	refresh_saves()
	if is_inside_tree():
		play_intro_animation()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED or what == NOTIFICATION_ENTER_TREE:
		_ensure_full_rect()
	elif what == NOTIFICATION_VISIBILITY_CHANGED and visible and is_inside_tree():
		_ensure_full_rect()
		refresh_saves()
		play_intro_animation()

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
	if _center_container != null:
		_center_container.anchor_left = 0.0
		_center_container.anchor_top = 0.0
		_center_container.anchor_right = 1.0
		_center_container.anchor_bottom = 1.0
		_center_container.offset_left = 0.0
		_center_container.offset_top = 0.0
		_center_container.offset_right = 0.0
		_center_container.offset_bottom = 0.0
		_center_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
		_center_container.grow_vertical = Control.GROW_DIRECTION_BOTH

# ==============================================================================
# 2. CONSTRUÇÃO DA INTERFACE (LAYOUT 100% CENTRALIZADO NA TELA)
# ==============================================================================

func _build_ui_structure() -> void:
	if _new_btn != null:
		return
		
	_ensure_full_rect()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# --------------------------------------------------------------------------
	# A. Backdrop Esportivo Dinamico com Iluminacao e Campo Isometrico
	# --------------------------------------------------------------------------
	_backdrop = MainMenuBackdrop.new()
	_backdrop.anchor_left = 0.0
	_backdrop.anchor_top = 0.0
	_backdrop.anchor_right = 1.0
	_backdrop.anchor_bottom = 1.0
	_backdrop.offset_left = 0.0
	_backdrop.offset_top = 0.0
	_backdrop.offset_right = 0.0
	_backdrop.offset_bottom = 0.0
	_backdrop.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_backdrop.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(_backdrop)
	
	# --------------------------------------------------------------------------
	# B. CenterContainer Centralizando Todo o Menu na Tela
	# --------------------------------------------------------------------------
	_center_container = CenterContainer.new()
	_center_container.anchor_left = 0.0
	_center_container.anchor_top = 0.0
	_center_container.anchor_right = 1.0
	_center_container.anchor_bottom = 1.0
	_center_container.offset_left = 0.0
	_center_container.offset_top = 0.0
	_center_container.offset_right = 0.0
	_center_container.offset_bottom = 0.0
	_center_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_center_container.grow_vertical = Control.GROW_DIRECTION_BOTH
	_center_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_center_container)
	
	# Painel Flutuante Central com Fundo Fosco e Borda Suave
	_main_panel_container = PanelContainer.new()
	_main_panel_container.custom_minimum_size = Vector2(440, 0)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.11, 0.16, 0.92) # Azul petróleo escuro translúcido
	panel_style.border_color = Color("#3A475C")
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.corner_radius_top_left = 16
	panel_style.corner_radius_top_right = 16
	panel_style.corner_radius_bottom_left = 16
	panel_style.corner_radius_bottom_right = 16
	panel_style.content_margin_left = 28
	panel_style.content_margin_right = 28
	panel_style.content_margin_top = 20
	panel_style.content_margin_bottom = 18
	_main_panel_container.add_theme_stylebox_override("panel", panel_style)
	_center_container.add_child(_main_panel_container)
	
	_content_vbox = VBoxContainer.new()
	_content_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_content_vbox.add_theme_constant_override("separation", 12)
	_main_panel_container.add_child(_content_vbox)
	
	# --------------------------------------------------------------------------
	# C. Cabecalho Centralizado (Brasão Animado + Título + Subtítulo)
	# --------------------------------------------------------------------------
	_header_vbox = VBoxContainer.new()
	_header_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_header_vbox.add_theme_constant_override("separation", 6)
	_content_vbox.add_child(_header_vbox)
	
	# Brasão Procedural Animado no Centro
	var logo_center = CenterContainer.new()
	_header_vbox.add_child(logo_center)
	
	_shield_logo = MainMenuShieldLogo.new()
	_shield_logo.custom_minimum_size = Vector2(56, 66)
	logo_center.add_child(_shield_logo)
	
	# Linha do Título com Badge "ALPHA 0.1"
	var title_row = HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 8)
	_header_vbox.add_child(title_row)
	
	var title_label = Label.new()
	title_label.text = "OPEN FOOTBALL"
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.add_theme_color_override("font_color", Color("#F8FAFC"))
	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.7))
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 2)
	title_row.add_child(title_label)
	
	var alpha_badge = PanelContainer.new()
	var alpha_style = StyleBoxFlat.new()
	alpha_style.bg_color = Color("#EAB308")
	alpha_style.corner_radius_top_left = 4
	alpha_style.corner_radius_top_right = 4
	alpha_style.corner_radius_bottom_left = 4
	alpha_style.corner_radius_bottom_right = 4
	alpha_style.content_margin_left = 6
	alpha_style.content_margin_right = 6
	alpha_style.content_margin_top = 2
	alpha_style.content_margin_bottom = 2
	alpha_badge.add_theme_stylebox_override("panel", alpha_style)
	title_row.add_child(alpha_badge)
	
	var alpha_label = Label.new()
	alpha_label.text = "ALPHA 0.1"
	alpha_label.add_theme_font_size_override("font_size", 10)
	alpha_label.add_theme_color_override("font_color", Color("#0F172A"))
	alpha_badge.add_child(alpha_label)
	
	# Pílulas dos Pilares (Centralizadas)
	var pills_row = HBoxContainer.new()
	pills_row.alignment = BoxContainer.ALIGNMENT_CENTER
	pills_row.add_theme_constant_override("separation", 6)
	_header_vbox.add_child(pills_row)
	pills_row.add_child(_create_pill_badge("⚡ Partidas Rápidas"))
	pills_row.add_child(_create_pill_badge("🏗️ Clube Vivo"))
	pills_row.add_child(_create_pill_badge("🔒 100% Offline"))
	
	# --------------------------------------------------------------------------
	# D. Banner Dinâmico Centralizado de Carreira / Último Save
	# --------------------------------------------------------------------------
	_save_banner_panel = PanelContainer.new()
	_save_banner_panel.custom_minimum_size = Vector2(0, 48)
	var banner_style = StyleBoxFlat.new()
	banner_style.bg_color = Color(0.12, 0.16, 0.23, 0.85)
	banner_style.border_color = Color("#3A475C")
	banner_style.border_width_left = 1
	banner_style.border_width_top = 1
	banner_style.border_width_right = 1
	banner_style.border_width_bottom = 1
	banner_style.corner_radius_top_left = 8
	banner_style.corner_radius_top_right = 8
	banner_style.corner_radius_bottom_left = 8
	banner_style.corner_radius_bottom_right = 8
	banner_style.content_margin_left = 12
	banner_style.content_margin_right = 12
	banner_style.content_margin_top = 6
	banner_style.content_margin_bottom = 6
	_save_banner_panel.add_theme_stylebox_override("panel", banner_style)
	_content_vbox.add_child(_save_banner_panel)
	
	_save_banner_content = VBoxContainer.new()
	_save_banner_panel.add_child(_save_banner_content)
	
	# Label de compatibilidade com testes e contratos
	_save_info_label = Label.new()
	_save_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_save_info_label.add_theme_font_size_override("font_size", 11)
	
	# --------------------------------------------------------------------------
	# E. Lista de Botões Centralizados com Subtítulos Táteis
	# --------------------------------------------------------------------------
	_buttons_vbox = VBoxContainer.new()
	_buttons_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_buttons_vbox.add_theme_constant_override("separation", 6)
	_content_vbox.add_child(_buttons_vbox)
	
	_menu_buttons_list.clear()
	
	# Botão 1: Nova Carreira
	_new_btn = _create_action_button(
		"🌟 Nova Carreira",
		"Funde um novo clube ou assuma um time tradicional",
		Color("#2563EB"),
		Color("#3B82F6")
	)
	_new_btn.pressed.connect(_on_new_pressed)
	_buttons_vbox.add_child(_new_btn)
	_menu_buttons_list.append(_new_btn)
	
	# Botão 2: Continuar Carreira
	_continue_btn = _create_action_button(
		"💾 Continuar Carreira",
		"Retome sua jornada de onde parou",
		Color("#16A34A"),
		Color("#22C55E")
	)
	_continue_btn.pressed.connect(_on_continue_pressed)
	_buttons_vbox.add_child(_continue_btn)
	_menu_buttons_list.append(_continue_btn)
	
	# Botão 3: Opções & Áudio
	_options_btn = _create_action_button(
		"⚙️ Opções & Áudio",
		"Ajustes de som, volume e exibição de tela",
		Color("#1E293B"),
		Color("#334155")
	)
	_options_btn.pressed.connect(_on_options_pressed)
	_buttons_vbox.add_child(_options_btn)
	_menu_buttons_list.append(_options_btn)
	
	# Botão 4: Sobre o Jogo
	_credits_btn = _create_action_button(
		"📖 Sobre o Jogo",
		"Filosofia open source, comunidade e modding",
		Color("#1E293B"),
		Color("#334155")
	)
	_credits_btn.pressed.connect(_on_credits_pressed)
	_buttons_vbox.add_child(_credits_btn)
	_menu_buttons_list.append(_credits_btn)
	
	# Botão 5: Sair do Jogo
	_quit_btn = _create_action_button(
		"🚪 Sair do Jogo",
		"Encerrar a aplicação",
		Color("#1E293B"),
		Color("#991B1B")
	)
	_quit_btn.pressed.connect(_on_quit_pressed)
	_buttons_vbox.add_child(_quit_btn)
	_menu_buttons_list.append(_quit_btn)
	
	# --------------------------------------------------------------------------
	# F. Rodapé Centralizado
	# --------------------------------------------------------------------------
	_footer_container = HBoxContainer.new()
	_footer_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_content_vbox.add_child(_footer_container)
	
	var footer_label = Label.new()
	footer_label.text = "Open Football • Projeto Open Source"
	footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer_label.add_theme_font_size_override("font_size", 10)
	footer_label.add_theme_color_override("font_color", Color("#64748B"))
	_footer_container.add_child(footer_label)
	
	# --------------------------------------------------------------------------
	# G. Modais Flutuantes (Opções e Créditos)
	# --------------------------------------------------------------------------
	_build_options_modal()
	_build_credits_modal()

# ==============================================================================
# 3. ATUALIZAÇÃO DO STATUS DOS SAVES NO BANNER CENTRAL
# ==============================================================================

func refresh_saves() -> void:
	_build_ui_structure()
	var saves = SaveManagerClass.list_saves()
	
	for child in _save_banner_content.get_children():
		child.queue_free()
		
	if saves.is_empty():
		_latest_save_data = {}
		_continue_btn.disabled = true
		_continue_btn.modulate = Color(0.65, 0.65, 0.65, 0.6)
		_save_info_label.text = "Nenhum save encontrado. Inicie uma Nova Carreira!"
		_save_info_label.add_theme_color_override("font_color", Color.GRAY)
		
		# Banner de boas-vindas
		var row = HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 8)
		_save_banner_content.add_child(row)
		
		var icon = Label.new()
		icon.text = "✨"
		row.add_child(icon)
		
		var msg = Label.new()
		msg.text = "Nenhum save ativo. Comece sua trajetória de treinador!"
		msg.add_theme_font_size_override("font_size", 11)
		msg.add_theme_color_override("font_color", Color("#94A3B8"))
		row.add_child(msg)
	else:
		_latest_save_data = saves[0]
		_continue_btn.disabled = false
		_continue_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
		
		var club_name = str(_latest_save_data.get("club_name", "Clube"))
		var cur_round = int(_latest_save_data.get("current_round", 1))
		var tot_rounds = int(_latest_save_data.get("total_rounds", 14))
		
		_save_info_label.text = "Último Save: %s (Rodada %d)" % [club_name, cur_round]
		_save_info_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
		
		# Banner estilizado do clube salvo
		var row = HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 10)
		_save_banner_content.add_child(row)
		
		var badge = Label.new()
		badge.text = "🛡️"
		badge.add_theme_font_size_override("font_size", 14)
		row.add_child(badge)
		
		var text_vbox = VBoxContainer.new()
		row.add_child(text_vbox)
		
		var top_lbl = Label.new()
		top_lbl.text = "CARREIRA: %s" % club_name.to_upper()
		top_lbl.add_theme_font_size_override("font_size", 12)
		top_lbl.add_theme_color_override("font_color", Color("#F8FAFC"))
		text_vbox.add_child(top_lbl)
		
		var sub_lbl = Label.new()
		sub_lbl.text = "Liga Inaugural • Rodada %d de %d" % [cur_round, tot_rounds]
		sub_lbl.add_theme_font_size_override("font_size", 10)
		sub_lbl.add_theme_color_override("font_color", Color("#22C55E"))
		text_vbox.add_child(sub_lbl)

func _create_pill_badge(text: String) -> Control:
	var pill = PanelContainer.new()
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.16, 0.20, 0.28, 0.8)
	st.corner_radius_top_left = 10
	st.corner_radius_top_right = 10
	st.corner_radius_bottom_left = 10
	st.corner_radius_bottom_right = 10
	st.content_margin_left = 7
	st.content_margin_right = 7
	st.content_margin_top = 2
	st.content_margin_bottom = 2
	pill.add_theme_stylebox_override("panel", st)
	
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color("#94A3B8"))
	pill.add_child(lbl)
	return pill

# ==============================================================================
# 4. CRIADOR DE BOTÕES ESTILIZADOS E MICRO-ANIMAÇÕES (HOVER / CLICK)
# ==============================================================================

func _create_action_button(title: String, subtitle: String, base_bg: Color, hover_bg: Color) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(380, 52)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	# Estilo Normal
	var normal_box = StyleBoxFlat.new()
	normal_box.bg_color = base_bg
	normal_box.border_color = Color("#3A475C")
	normal_box.border_width_left = 1
	normal_box.border_width_top = 1
	normal_box.border_width_right = 1
	normal_box.border_width_bottom = 1
	normal_box.corner_radius_top_left = 8
	normal_box.corner_radius_top_right = 8
	normal_box.corner_radius_bottom_left = 8
	normal_box.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", normal_box)
	
	# Estilo Hover
	var hover_box = normal_box.duplicate() as StyleBoxFlat
	hover_box.bg_color = hover_bg
	hover_box.border_color = Color("#60A5FA")
	hover_box.border_width_left = 2
	btn.add_theme_stylebox_override("hover", hover_box)
	
	# Estilo Pressed
	var pressed_box = normal_box.duplicate() as StyleBoxFlat
	pressed_box.bg_color = base_bg.darkened(0.2)
	btn.add_theme_stylebox_override("pressed", pressed_box)
	
	# Estilo Disabled
	var disabled_box = normal_box.duplicate() as StyleBoxFlat
	disabled_box.bg_color = Color(0.12, 0.15, 0.20, 0.6)
	disabled_box.border_color = Color(0.2, 0.24, 0.3)
	btn.add_theme_stylebox_override("disabled", disabled_box)
	
	# Container de Margem Garantindo Padding Real do Conteúdo Interno
	var margin_container = MarginContainer.new()
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin_container.add_theme_constant_override("margin_left", 22)
	margin_container.add_theme_constant_override("margin_right", 18)
	margin_container.add_theme_constant_override("margin_top", 8)
	margin_container.add_theme_constant_override("margin_bottom", 8)
	btn.add_child(margin_container)
	
	var vbox = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	margin_container.add_child(vbox)
	
	var title_lbl = Label.new()
	title_lbl.text = title
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", Color("#F8FAFC"))
	vbox.add_child(title_lbl)
	
	var sub_lbl = Label.new()
	sub_lbl.text = subtitle
	sub_lbl.add_theme_font_size_override("font_size", 10)
	sub_lbl.add_theme_color_override("font_color", Color("#94A3B8"))
	vbox.add_child(sub_lbl)
	
	btn.mouse_entered.connect(func():
		if not btn.disabled:
			AudioServiceClass.get_instance().play_click()
			if is_inside_tree():
				var tw = margin_container.create_tween()
				tw.tween_property(margin_container, "theme_override_constants/margin_left", 28, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	)
	btn.mouse_exited.connect(func():
		if not btn.disabled and is_inside_tree():
			var tw = margin_container.create_tween()
			tw.tween_property(margin_container, "theme_override_constants/margin_left", 22, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	)
	
	return btn

# ==============================================================================
# 5. SISTEMA DE ANIMAÇÕES DE ENTRADA (STAGGERED INTRO)
# ==============================================================================

func play_intro_animation() -> void:
	if not is_inside_tree():
		return
		
	# 1. Animação de Entrada do Painel Central (Escala e Fade)
	if _main_panel_container != null:
		_main_panel_container.modulate.a = 0.0
		_main_panel_container.scale = Vector2(0.96, 0.96)
		_main_panel_container.pivot_offset = _main_panel_container.size * 0.5
		var tw_panel = create_tween()
		tw_panel.set_parallel(true)
		tw_panel.tween_property(_main_panel_container, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw_panel.tween_property(_main_panel_container, "modulate:a", 1.0, 0.35)
		
	# 2. Entrada Escalonada dos Botões (Fade suave)
	for i in range(_menu_buttons_list.size()):
		var b = _menu_buttons_list[i]
		b.modulate.a = 0.0
		var delay = 0.10 + (float(i) * 0.04)
		var tw_btn = create_tween()
		tw_btn.tween_interval(delay)
		tw_btn.tween_property(b, "modulate:a", 1.0, 0.25)

# ==============================================================================
# 6. MODAL DE OPÇÕES & CONFIGURAÇÕES
# ==============================================================================

func _build_options_modal() -> void:
	_options_modal = Control.new()
	_options_modal.anchor_left = 0.0
	_options_modal.anchor_top = 0.0
	_options_modal.anchor_right = 1.0
	_options_modal.anchor_bottom = 1.0
	_options_modal.offset_left = 0.0
	_options_modal.offset_top = 0.0
	_options_modal.offset_right = 0.0
	_options_modal.offset_bottom = 0.0
	_options_modal.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_options_modal.grow_vertical = Control.GROW_DIRECTION_BOTH
	_options_modal.visible = false
	add_child(_options_modal)
	
	var dimmer = ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.05, 0.07, 0.11, 0.8)
	_options_modal.add_child(dimmer)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_options_modal.add_child(center)
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(440, 320)
	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color("#1A202C")
	p_style.border_color = Color("#3A475C")
	p_style.border_width_left = 1
	p_style.border_width_top = 1
	p_style.border_width_right = 1
	p_style.border_width_bottom = 1
	p_style.corner_radius_top_left = 10
	p_style.corner_radius_top_right = 10
	p_style.corner_radius_bottom_left = 10
	p_style.corner_radius_bottom_right = 10
	p_style.content_margin_left = 24
	p_style.content_margin_right = 24
	p_style.content_margin_top = 18
	p_style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", p_style)
	center.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "⚙️ Configurações & Preferências"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color("#F8FAFC"))
	vbox.add_child(title)
	
	vbox.add_child(HSeparator.new())
	
	# Controle de Áudio
	var audio = AudioServiceClass.get_instance()
	_sound_toggle_btn = CheckButton.new()
	_sound_toggle_btn.text = "Efeitos Sonoros Procedurais"
	_sound_toggle_btn.button_pressed = audio.is_sound_enabled()
	_sound_toggle_btn.toggled.connect(func(pressed: bool):
		audio.set_sound_enabled(pressed)
		if pressed:
			audio.play_click()
	)
	vbox.add_child(_sound_toggle_btn)
	
	# Slider de Volume
	var vol_box = HBoxContainer.new()
	vol_box.add_theme_constant_override("separation", 12)
	vbox.add_child(vol_box)
	
	var vol_lbl = Label.new()
	vol_lbl.text = "Volume Geral:"
	vol_lbl.add_theme_font_size_override("font_size", 13)
	vol_box.add_child(vol_lbl)
	
	_volume_slider = HSlider.new()
	_volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_volume_slider.min_value = 0.0
	_volume_slider.max_value = 100.0
	_volume_slider.value = audio.get_master_volume() * 100.0
	_volume_slider.value_changed.connect(func(val: float):
		audio.set_master_volume(val / 100.0)
		_volume_percent_label.text = "%d%%" % int(val)
	)
	vol_box.add_child(_volume_slider)
	
	_volume_percent_label = Label.new()
	_volume_percent_label.text = "%d%%" % int(_volume_slider.value)
	_volume_percent_label.custom_minimum_size = Vector2(40, 0)
	vol_box.add_child(_volume_percent_label)
	
	var test_sound_btn = Button.new()
	test_sound_btn.text = "🔊 Testar Som (Apito de Juiz)"
	test_sound_btn.pressed.connect(func(): audio.play_whistle())
	vbox.add_child(test_sound_btn)
	
	vbox.add_child(HSeparator.new())
	
	# Controle de Tela Cheia
	_fullscreen_btn = Button.new()
	_fullscreen_btn.text = "🖥️ Alternar Modo de Tela Cheia"
	_fullscreen_btn.pressed.connect(func():
		var mode = DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	)
	vbox.add_child(_fullscreen_btn)
	
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	var close_btn = Button.new()
	close_btn.text = "Concluído"
	close_btn.custom_minimum_size = Vector2(0, 36)
	close_btn.pressed.connect(func():
		_options_modal.visible = false
	)
	vbox.add_child(close_btn)

# ==============================================================================
# 7. MODAL DE CRÉDITOS & SOBRE O JOGO
# ==============================================================================

func _build_credits_modal() -> void:
	_credits_modal = Control.new()
	_credits_modal.anchor_left = 0.0
	_credits_modal.anchor_top = 0.0
	_credits_modal.anchor_right = 1.0
	_credits_modal.anchor_bottom = 1.0
	_credits_modal.offset_left = 0.0
	_credits_modal.offset_top = 0.0
	_credits_modal.offset_right = 0.0
	_credits_modal.offset_bottom = 0.0
	_credits_modal.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_credits_modal.grow_vertical = Control.GROW_DIRECTION_BOTH
	_credits_modal.visible = false
	add_child(_credits_modal)
	
	var dimmer = ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.05, 0.07, 0.11, 0.8)
	_credits_modal.add_child(dimmer)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_credits_modal.add_child(center)
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(460, 340)
	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color("#1A202C")
	p_style.border_color = Color("#3A475C")
	p_style.border_width_left = 1
	p_style.border_width_top = 1
	p_style.border_width_right = 1
	p_style.border_width_bottom = 1
	p_style.corner_radius_top_left = 10
	p_style.corner_radius_top_right = 10
	p_style.corner_radius_bottom_left = 10
	p_style.corner_radius_bottom_right = 10
	p_style.content_margin_left = 24
	p_style.content_margin_right = 24
	p_style.content_margin_top = 18
	p_style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", p_style)
	center.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "📖 Sobre o Open Football"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color("#F8FAFC"))
	vbox.add_child(title)
	
	vbox.add_child(HSeparator.new())
	
	var body_txt = Label.new()
	body_txt.text = "O Open Football é um simulador de futebol de código aberto focado em gerenciamento tático ágil e um clube vivo em maquete isométrica.\n\n• Arquitetura Data-Driven via JSON em res://data/\n• Motor 100% offline e independente de servidores\n• Desenvolvido com Godot Engine 4.7"
	body_txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_txt.add_theme_font_size_override("font_size", 12)
	body_txt.add_theme_color_override("font_color", Color("#94A3B8"))
	vbox.add_child(body_txt)
	
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	var close_btn = Button.new()
	close_btn.text = "Fechar"
	close_btn.custom_minimum_size = Vector2(0, 36)
	close_btn.pressed.connect(func():
		_credits_modal.visible = false
	)
	vbox.add_child(close_btn)

# ==============================================================================
# 8. HANDLERS DE AÇÕES E BOTÕES
# ==============================================================================

func _on_new_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	new_career_requested.emit()

func _on_continue_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	continue_career_requested.emit()

func _on_options_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	_options_modal.visible = true

func _on_credits_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	_credits_modal.visible = true

func _on_quit_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	quit_requested.emit()
	if is_inside_tree():
		get_tree().quit()


# ==============================================================================
# 9. SUBCLASSES INTERNAS: BACKDROP COM DIORAMA E ESCUDO PROCEDURAL
# ==============================================================================

## Backdrop com gramado isométrico, holofotes noturnos e partículas sutis
class MainMenuBackdrop extends Control:
	var _time: float = 0.0
	var _particles: Array[Dictionary] = []
	
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		for i in range(24):
			_particles.append({
				"pos": Vector2(randf_range(50.0, 1100.0), randf_range(50.0, 600.0)),
				"speed": randf_range(12.0, 26.0),
				"size": randf_range(1.5, 3.0),
				"alpha": randf_range(0.15, 0.40)
			})
	
	func _process(delta: float) -> void:
		_time += delta
		for p in _particles:
			p.pos.y -= p.speed * delta
			if p.pos.y < -10.0:
				p.pos.y = 660.0
				p.pos.x = randf_range(50.0, 1100.0)
		queue_redraw()
	
	func _draw() -> void:
		var w = size.x
		var h = size.y
		
		# 1. Fundo Base Gradiente Noturno (#090C12 ➔ #111724)
		draw_rect(Rect2(0, 0, w, h), Color(0.06, 0.08, 0.12))
		
		# 2. Diorama Isométrico no Fundo Central Inferior
		var iso_origin = Vector2(w * 0.50, h * 0.72)
		_draw_isometric_mini_pitch(iso_origin)
		
		# 3. Holofotes Noturnos Conicos com leve oscilação cruzando o centro
		var light_sway = sin(_time * 0.8) * 35.0
		var spot1_color = Color(0.25, 0.55, 1.0, 0.035)
		var spot1_poly = PackedVector2Array([
			Vector2(w * 0.88, -20.0),
			Vector2(w * 0.35 + light_sway, h),
			Vector2(w * 0.75 + light_sway, h)
		])
		draw_colored_polygon(spot1_poly, spot1_color)
		
		var spot2_color = Color(0.35, 0.7, 0.9, 0.025)
		var spot2_poly = PackedVector2Array([
			Vector2(w * 0.12, -20.0),
			Vector2(w * 0.25 - light_sway, h),
			Vector2(w * 0.65 - light_sway, h)
		])
		draw_colored_polygon(spot2_poly, spot2_color)
		
		# 4. Partículas flutuantes de ambiente esportivo
		for p in _particles:
			var p_col = Color(0.9, 0.8, 0.4, p.alpha)
			draw_circle(p.pos, p.size, p_col)
	
	func _draw_isometric_mini_pitch(origin: Vector2) -> void:
		var tile_w = 56.0
		var tile_h = 28.0
		var rows = 8
		var cols = 12
		
		var center_offset = Vector2((cols - rows) * tile_w * 0.25, (cols + rows) * tile_h * 0.25)
		var base_origin = origin - center_offset
		
		for r in range(rows):
			for c in range(cols):
				var px = base_origin.x + (c - r) * (tile_w * 0.5)
				var py = base_origin.y + (c + r) * (tile_h * 0.5)
				
				var top = Vector2(px, py)
				var right = Vector2(px + tile_w * 0.5, py + tile_h * 0.5)
				var bottom = Vector2(px, py + tile_h)
				var left = Vector2(px - tile_w * 0.5, py + tile_h * 0.5)
				
				var grass_col = Color("#173F14") if ((r + c) % 2 == 0) else Color("#1D4D1A")
				var diamond = PackedVector2Array([top, right, bottom, left])
				draw_colored_polygon(diamond, grass_col)
		
		var p_top = base_origin
		var p_right = base_origin + Vector2(cols * tile_w * 0.5, cols * tile_h * 0.5)
		var p_bottom = base_origin + Vector2((cols - rows) * tile_w * 0.5, (cols + rows) * tile_h * 0.5)
		var p_left = base_origin + Vector2(-rows * tile_w * 0.5, rows * tile_h * 0.5)
		
		var pitch_border = PackedVector2Array([p_top, p_right, p_bottom, p_left, p_top])
		draw_polyline(pitch_border, Color(1.0, 1.0, 1.0, 0.40), 2.0)
		
		var mid1 = (p_top + p_right) * 0.5
		var mid2 = (p_left + p_bottom) * 0.5
		draw_line(mid1, mid2, Color(1.0, 1.0, 1.0, 0.35), 1.5)
		
		var center = (p_top + p_bottom) * 0.5
		var circle_pts: Array[Vector2] = []
		for a in range(25):
			var rad = float(a) / 24.0 * TAU
			var cx = center.x + cos(rad) * 32.0
			var cy = center.y + sin(rad) * 16.0
			circle_pts.append(Vector2(cx, cy))
		draw_polyline(PackedVector2Array(circle_pts), Color(1.0, 1.0, 1.0, 0.35), 1.5)


## Brasão estilizado desenhado proceduralmente com leve flutuação animada
class MainMenuShieldLogo extends Control:
	var _time: float = 0.0
	
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	func _process(delta: float) -> void:
		_time += delta
		position.y = sin(_time * 2.5) * 3.0
		queue_redraw()
	
	func _draw() -> void:
		var w = size.x
		var h = size.y
		
		var top_left = Vector2(4, 8)
		var top_right = Vector2(w - 4, 8)
		var mid_right = Vector2(w - 4, h * 0.55)
		var bottom_tip = Vector2(w * 0.5, h - 2)
		var mid_left = Vector2(4, h * 0.55)
		
		var shield_poly = PackedVector2Array([
			top_left,
			top_right,
			mid_right,
			bottom_tip,
			mid_left
		])
		
		draw_colored_polygon(shield_poly, Color("#1E3A8A"))
		
		var stripe_poly = PackedVector2Array([
			Vector2(w * 0.2, 8),
			Vector2(w * 0.45, 8),
			Vector2(w * 0.8, h * 0.7),
			Vector2(w * 0.55, h * 0.7)
		])
		draw_colored_polygon(stripe_poly, Color(0.9, 0.95, 1.0, 0.85))
		
		var shield_border = PackedVector2Array([
			top_left,
			top_right,
			mid_right,
			bottom_tip,
			mid_left,
			top_left
		])
		draw_polyline(shield_border, Color("#EAB308"), 3.0)
		
		var b_center = Vector2(w * 0.5, h * 0.50)
		draw_circle(b_center, 9.0, Color.WHITE)
		draw_circle(b_center, 3.5, Color("#0F172A"))
		draw_arc(b_center, 9.0, 0, TAU, 16, Color("#0F172A"), 1.5)
		
		var star_y = 3.0
		draw_circle(Vector2(w * 0.38, star_y), 2.5, Color("#EAB308"))
		draw_circle(Vector2(w * 0.50, star_y - 1.5), 3.0, Color("#EAB308"))
		draw_circle(Vector2(w * 0.62, star_y), 2.5, Color("#EAB308"))
