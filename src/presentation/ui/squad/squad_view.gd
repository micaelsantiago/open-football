class_name SquadView
extends Control

const PlayerCardClass = preload("res://src/presentation/ui/common/player_card.gd")
const DataTableClass = preload("res://src/presentation/ui/common/data_table.gd")

signal tactics_saved()
signal closed()

var game_state: RefCounted
var club_id: String = ""

var _mentality_option: OptionButton
var _starters_container: VBoxContainer
var _subs_container: VBoxContainer
var _save_btn: Button

func _ready() -> void:
	_ensure_full_rect()
	_build_ui_structure()

func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		_ensure_full_rect()

func _ensure_full_rect() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_top = 52.0
	offset_right = 0.0
	offset_bottom = 0.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH

func _build_ui_structure() -> void:
	if _mentality_option != null:
		return
		
	_ensure_full_rect()
	
	var main_panel = PanelContainer.new()
	main_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.07, 0.09, 0.13)
	st.content_margin_left = 24
	st.content_margin_right = 24
	st.content_margin_top = 16
	st.content_margin_bottom = 20
	main_panel.add_theme_stylebox_override("panel", st)
	add_child(main_panel)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 12)
	main_panel.add_child(main_vbox)
	
	# Top bar
	var top_bar = HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 10)
	main_vbox.add_child(top_bar)
	
	var title = Label.new()
	title.text = "📋 ESCALAÇÃO & POSTURA TÁTICA"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color("#F8FAFC"))
	top_bar.add_child(title)
	
	var ment_label = Label.new()
	ment_label.text = "Postura Tática: "
	ment_label.add_theme_color_override("font_color", Color("#94A3B8"))
	top_bar.add_child(ment_label)
	
	_mentality_option = OptionButton.new()
	_mentality_option.add_item("Equilibrada (BALANCED)", 0)
	_mentality_option.add_item("Ofensiva (OFFENSIVE)", 1)
	_mentality_option.add_item("Defensiva (DEFENSIVE)", 2)
	top_bar.add_child(_mentality_option)
	
	_save_btn = Button.new()
	_save_btn.text = "💾 Salvar Táticas"
	var save_st = StyleBoxFlat.new()
	save_st.bg_color = Color("#2563EB")
	save_st.corner_radius_top_left = 6
	save_st.corner_radius_top_right = 6
	save_st.corner_radius_bottom_left = 6
	save_st.corner_radius_bottom_right = 6
	save_st.content_margin_left = 14
	save_st.content_margin_right = 14
	save_st.content_margin_top = 6
	save_st.content_margin_bottom = 6
	_save_btn.add_theme_stylebox_override("normal", save_st)
	_save_btn.pressed.connect(_on_save_pressed)
	top_bar.add_child(_save_btn)
	
	var close_btn = Button.new()
	close_btn.text = " ✖ Voltar ao Painel "
	var close_st = StyleBoxFlat.new()
	close_st.bg_color = Color("#1E293B")
	close_st.corner_radius_top_left = 6
	close_st.corner_radius_top_right = 6
	close_st.corner_radius_bottom_left = 6
	close_st.corner_radius_bottom_right = 6
	close_st.content_margin_left = 14
	close_st.content_margin_right = 14
	close_st.content_margin_top = 6
	close_st.content_margin_bottom = 6
	close_btn.add_theme_stylebox_override("normal", close_st)
	close_btn.pressed.connect(func():
		visible = false
		closed.emit()
	)
	top_bar.add_child(close_btn)

	main_vbox.add_child(HSeparator.new())
	
	# Split columns: Titulares (11) e Reservas
	var hsplit = HBoxContainer.new()
	hsplit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(hsplit)
	
	# Coluna da Esquerda: Titulares
	var left_vbox = VBoxContainer.new()
	left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hsplit.add_child(left_vbox)
	
	var starters_title = Label.new()
	starters_title.text = "Titulares (11)"
	starters_title.add_theme_font_size_override("font_size", 14)
	left_vbox.add_child(starters_title)
	
	var starters_scroll = ScrollContainer.new()
	starters_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(starters_scroll)
	
	_starters_container = VBoxContainer.new()
	_starters_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	starters_scroll.add_child(_starters_container)
	
	hsplit.add_child(VSeparator.new())
	
	# Coluna da Direita: Reservas
	var right_vbox = VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hsplit.add_child(right_vbox)
	
	var subs_title = Label.new()
	subs_title.text = "Banco de Reservas"
	subs_title.add_theme_font_size_override("font_size", 14)
	right_vbox.add_child(subs_title)
	
	var subs_scroll = ScrollContainer.new()
	subs_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(subs_scroll)
	
	_subs_container = VBoxContainer.new()
	_subs_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subs_scroll.add_child(_subs_container)

func setup(p_game_state: RefCounted, p_club_id: String = "") -> void:
	_build_ui_structure()
	game_state = p_game_state
	club_id = p_club_id if not p_club_id.is_empty() else str(game_state.get("user_club_id"))
	refresh()

func refresh() -> void:
	if game_state == null:
		return
		
	var club = game_state.get_club(club_id)
	if club == null:
		return
		
	# Postura tatica
	var ment = str(club.tactics_preset.get("mentality", "BALANCED"))
	if ment == "OFFENSIVE":
		_mentality_option.select(1)
	elif ment == "DEFENSIVE":
		_mentality_option.select(2)
	else:
		_mentality_option.select(0)
		
	# Limpa listas
	for c in _starters_container.get_children():
		c.queue_free()
	for c in _subs_container.get_children():
		c.queue_free()
		
	var squad = club.squad
	for i in range(squad.size()):
		var pid = squad[i]
		var player = game_state.get_player(pid)
		if player == null:
			continue
			
		var card = PlayerCardClass.new()
		if i < 11:
			_starters_container.add_child(card)
		else:
			_subs_container.add_child(card)
		card.setup(player)

func _on_save_pressed() -> void:
	if game_state == null:
		return
	var club = game_state.get_club(club_id)
	if club != null:
		var sel_idx = _mentality_option.selected
		var new_ment = "BALANCED"
		if sel_idx == 1:
			new_ment = "OFFENSIVE"
		elif sel_idx == 2:
			new_ment = "DEFENSIVE"
		club.tactics_preset["mentality"] = new_ment
		tactics_saved.emit()
