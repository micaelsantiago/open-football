class_name StandingsView
extends Control

const DataTableClass = preload("res://src/presentation/ui/common/data_table.gd")
const EventBusClass = preload("res://src/systems/event_bus/event_bus.gd")

signal closed()

var game_state: RefCounted
var competition_id: String = ""

var _title_label: Label
var _data_table: DataTable
var _leader_label: Label

func _ready() -> void:
	_ensure_full_rect()
	_build_ui_structure()
	EventBusClass.get_instance().match_ended.connect(func(_res): refresh())

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
	if _data_table != null:
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
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	main_panel.add_child(vbox)
	
	var top_hbox = HBoxContainer.new()
	top_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(top_hbox)
	
	_title_label = Label.new()
	_title_label.text = "📊 TABELA DE CLASSIFICAÇÃO"
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.add_theme_font_size_override("font_size", 18)
	_title_label.add_theme_color_override("font_color", Color("#F8FAFC"))
	top_hbox.add_child(_title_label)
	
	_leader_label = Label.new()
	_leader_label.text = "Líder: --"
	_leader_label.add_theme_color_override("font_color", Color.GOLD)
	top_hbox.add_child(_leader_label)
	
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
	top_hbox.add_child(close_btn)

	vbox.add_child(HSeparator.new())
	
	_data_table = DataTableClass.new()
	_data_table.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_data_table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(_data_table)
	
	_setup_columns()

func _setup_columns() -> void:
	_data_table.set_columns([
		{ "id": "pos", "title": "#", "width": 40, "align": HORIZONTAL_ALIGNMENT_CENTER },
		{ "id": "club_name", "title": "Clube", "width": 220, "align": HORIZONTAL_ALIGNMENT_LEFT },
		{ "id": "played", "title": "J", "width": 45, "align": HORIZONTAL_ALIGNMENT_CENTER },
		{ "id": "won", "title": "V", "width": 45, "align": HORIZONTAL_ALIGNMENT_CENTER },
		{ "id": "drawn", "title": "E", "width": 45, "align": HORIZONTAL_ALIGNMENT_CENTER },
		{ "id": "lost", "title": "D", "width": 45, "align": HORIZONTAL_ALIGNMENT_CENTER },
		{ "id": "goals_for", "title": "GP", "width": 50, "align": HORIZONTAL_ALIGNMENT_CENTER },
		{ "id": "goals_against", "title": "GC", "width": 50, "align": HORIZONTAL_ALIGNMENT_CENTER },
		{ "id": "goal_difference", "title": "SG", "width": 50, "align": HORIZONTAL_ALIGNMENT_CENTER },
		{ "id": "points", "title": "Pts", "width": 60, "align": HORIZONTAL_ALIGNMENT_CENTER }
	])

func setup(p_game_state: RefCounted, p_comp_id: String = "") -> void:
	_build_ui_structure()
	game_state = p_game_state
	competition_id = p_comp_id if not p_comp_id.is_empty() else str(game_state.get("default_competition_id"))
	refresh()

func refresh() -> void:
	if game_state == null:
		return
		
	var comp = game_state.get_competition(competition_id)
	if comp == null:
		comp = game_state.get_active_competition()
	if comp == null:
		return
		
	_title_label.text = "Tabela de Classificação — %s (Rodada %d/%d)" % [comp.name, game_state.current_round, game_state.total_rounds]
	
	var sorted_standings = comp.get_sorted_standings()
	var rows: Array = []
	var user_club_id = str(game_state.user_club_id)
	
	for i in range(sorted_standings.size()):
		var st = sorted_standings[i]
		var cid = str(st.get("club_id", ""))
		var club = game_state.get_club(cid)
		var c_name = club.name if club != null else cid
		if cid == user_club_id:
			c_name = "★ %s (Você)" % c_name
			
		rows.append({
			"pos": "%dº" % (i + 1),
			"club_name": c_name,
			"played": str(st.get("played", 0)),
			"won": str(st.get("won", 0)),
			"drawn": str(st.get("drawn", 0)),
			"lost": str(st.get("lost", 0)),
			"goals_for": str(st.get("goals_for", 0)),
			"goals_against": str(st.get("goals_against", 0)),
			"goal_difference": "%+d" % int(st.get("goal_difference", 0)),
			"points": str(st.get("points", 0))
		})
		
	_data_table.set_rows(rows)
	
	var leader_id = comp.get_leader_club_id()
	var leader_club = game_state.get_club(leader_id)
	if leader_club != null:
		_leader_label.text = "Líder: %s (%s pts)" % [leader_club.name, rows[0]["points"] if not rows.is_empty() else "0"]
