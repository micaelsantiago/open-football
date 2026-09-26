class_name SquadView
extends Control

const PlayerCardClass = preload("res://src/presentation/ui/common/player_card.gd")
const DataTableClass = preload("res://src/presentation/ui/common/data_table.gd")

signal tactics_saved()

var game_state: RefCounted
var club_id: String = ""

var _mentality_option: OptionButton
var _starters_container: VBoxContainer
var _subs_container: VBoxContainer
var _save_btn: Button

func _ready() -> void:
	_build_ui_structure()

func _build_ui_structure() -> void:
	if _mentality_option != null:
		return
		
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var main_panel = PanelContainer.new()
	main_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_panel)
	
	var main_vbox = VBoxContainer.new()
	main_panel.add_child(main_vbox)
	
	# Top bar
	var top_bar = HBoxContainer.new()
	main_vbox.add_child(top_bar)
	
	var title = Label.new()
	title.text = "Escalação e Táticas do Clube"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 18)
	top_bar.add_child(title)
	
	var ment_label = Label.new()
	ment_label.text = "Postura Tática: "
	top_bar.add_child(ment_label)
	
	_mentality_option = OptionButton.new()
	_mentality_option.add_item("Equilibrada (BALANCED)", 0)
	_mentality_option.add_item("Ofensiva (OFFENSIVE)", 1)
	_mentality_option.add_item("Defensiva (DEFENSIVE)", 2)
	top_bar.add_child(_mentality_option)
	
	_save_btn = Button.new()
	_save_btn.text = "Salvar Táticas"
	_save_btn.pressed.connect(_on_save_pressed)
	top_bar.add_child(_save_btn)
	
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
