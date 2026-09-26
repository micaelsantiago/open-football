class_name FinancesView
extends Control

signal finances_saved()

var game_state: RefCounted
var club_id: String = ""

var _balance_label: Label
var _sponsor_label: Label
var _wages_label: Label
var _maintenance_label: Label
var _net_label: Label
var _ticket_slider: HSlider
var _ticket_value_label: Label
var _save_btn: Button

func _ready() -> void:
	_build_ui_structure()

func _build_ui_structure() -> void:
	if _balance_label != null:
		return
		
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var main_panel = PanelContainer.new()
	main_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_panel)
	
	var vbox = VBoxContainer.new()
	main_panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "Balanço Financeiro e Preço do Ingresso"
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)
	
	vbox.add_child(HSeparator.new())
	
	# Metricas de saldo
	var grid = GridContainer.new()
	grid.columns = 2
	vbox.add_child(grid)
	
	var lbl_b = Label.new()
	lbl_b.text = "Saldo em Caixa:"
	grid.add_child(lbl_b)
	_balance_label = Label.new()
	_balance_label.add_theme_color_override("font_color", Color.GOLD)
	grid.add_child(_balance_label)
	
	var lbl_sp = Label.new()
	lbl_sp.text = "(+) Patrocínio Semanal:"
	grid.add_child(lbl_sp)
	_sponsor_label = Label.new()
	_sponsor_label.add_theme_color_override("font_color", Color.FOREST_GREEN)
	grid.add_child(_sponsor_label)
	
	var lbl_w = Label.new()
	lbl_w.text = "(-) Folha Salarial do Elenco:"
	grid.add_child(lbl_w)
	_wages_label = Label.new()
	_wages_label.add_theme_color_override("font_color", Color.CRIMSON)
	grid.add_child(_wages_label)
	
	var lbl_m = Label.new()
	lbl_m.text = "(-) Manutenção de Instalações:"
	grid.add_child(lbl_m)
	_maintenance_label = Label.new()
	_maintenance_label.add_theme_color_override("font_color", Color.CORAL)
	grid.add_child(_maintenance_label)
	
	var lbl_net = Label.new()
	lbl_net.text = "(=) Projeção Líquida por Rodada:"
	grid.add_child(lbl_net)
	_net_label = Label.new()
	grid.add_child(_net_label)
	
	vbox.add_child(HSeparator.new())
	
	# Controle de preco do ingresso
	var ticket_title = Label.new()
	ticket_title.text = "Gestão de Bilheteria (Jogos em Casa)"
	ticket_title.add_theme_font_size_override("font_size", 14)
	vbox.add_child(ticket_title)
	
	var ticket_hbox = HBoxContainer.new()
	vbox.add_child(ticket_hbox)
	
	var t_lbl = Label.new()
	t_lbl.text = "Preço do Ingresso: "
	ticket_hbox.add_child(t_lbl)
	
	_ticket_slider = HSlider.new()
	_ticket_slider.min_value = 5
	_ticket_slider.max_value = 100
	_ticket_slider.step = 1
	_ticket_slider.custom_minimum_size = Vector2(240, 24)
	_ticket_slider.value_changed.connect(_on_ticket_slider_changed)
	ticket_hbox.add_child(_ticket_slider)
	
	_ticket_value_label = Label.new()
	_ticket_value_label.text = "R$ 20"
	ticket_hbox.add_child(_ticket_value_label)
	
	vbox.add_child(HSeparator.new())
	
	_save_btn = Button.new()
	_save_btn.text = "Salvar Ajustes Financeiros"
	_save_btn.pressed.connect(_on_save_pressed)
	vbox.add_child(_save_btn)

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
		
	var bal = club.get_balance()
	_balance_label.text = "R$ %d" % bal
	
	var sp = int(club.finances.get("weekly_sponsor", 0))
	_sponsor_label.text = "R$ %d" % sp
	
	var wages = game_state.calculate_club_wage_bill(club_id)
	_wages_label.text = "R$ %d" % wages
	
	var maint := 0
	for fid in game_state.facilities:
		var fac = game_state.facilities[fid]
		if fac.club_id == club_id:
			maint += fac.get_maintenance_cost()
	_maintenance_label.text = "R$ %d" % maint
	
	var net = sp - (wages + maint)
	_net_label.text = "R$ %d" % net
	if net >= 0:
		_net_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
	else:
		_net_label.add_theme_color_override("font_color", Color.CRIMSON)
		
	var tp = club.get_ticket_price()
	_ticket_slider.value = tp
	_ticket_value_label.text = "R$ %d" % tp

func _on_ticket_slider_changed(value: float) -> void:
	_ticket_value_label.text = "R$ %d" % int(value)

func _on_save_pressed() -> void:
	if game_state == null:
		return
	var club = game_state.get_club(club_id)
	if club != null:
		club.set_ticket_price(int(_ticket_slider.value))
		finances_saved.emit()
