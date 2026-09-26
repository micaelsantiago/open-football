class_name CreateClubWizard
extends Control

const ClubDataClass = preload("res://src/core/club/club_data.gd")
const FacilityDataClass = preload("res://src/core/facility/facility_data.gd")

signal club_confirmed(chosen_club_id: String)

var game_state: RefCounted

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

func _ready() -> void:
	_build_ui_structure()

func _build_ui_structure() -> void:
	if _tab_container != null:
		return
		
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var main_panel = PanelContainer.new()
	main_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_panel)
	
	var vbox = VBoxContainer.new()
	main_panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "Início de Carreira — Escolha ou Crie seu Clube"
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)
	
	vbox.add_child(HSeparator.new())
	
	_tab_container = TabContainer.new()
	_tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_tab_container)
	
	# Aba 1: Comandar Clube Existente
	var tab_existing = HBoxContainer.new()
	tab_existing.name = "Comandar Clube Existente"
	_tab_container.add_child(tab_existing)
	
	_existing_clubs_list = ItemList.new()
	_existing_clubs_list.custom_minimum_size = Vector2(280, 0)
	_existing_clubs_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_existing_clubs_list.item_selected.connect(_on_existing_club_selected)
	tab_existing.add_child(_existing_clubs_list)
	
	var prev_vbox = VBoxContainer.new()
	prev_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_existing.add_child(prev_vbox)
	
	_club_preview_label = Label.new()
	_club_preview_label.text = "Selecione um clube ao lado para ver os detalhes."
	_club_preview_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	prev_vbox.add_child(_club_preview_label)
	
	_confirm_existing_btn = Button.new()
	_confirm_existing_btn.text = "Assumir o Comando Deste Clube"
	_confirm_existing_btn.pressed.connect(_on_confirm_existing_pressed)
	prev_vbox.add_child(_confirm_existing_btn)
	
	# Aba 2: Fundar Novo Clube (Create-a-Club)
	var tab_new = VBoxContainer.new()
	tab_new.name = "Fundar Novo Clube (Create-a-Club)"
	_tab_container.add_child(tab_new)
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_new.add_child(grid)
	
	grid.add_child(Label.new()) # placeholder
	var desc = Label.new()
	desc.text = "Funde sua própria agremiação esportiva e personalize sua identidade:"
	grid.add_child(desc)
	
	grid.add_child(Label.new())
	grid.add_child(HSeparator.new())
	
	var l1 = Label.new()
	l1.text = "Nome do Clube:"
	grid.add_child(l1)
	_name_edit = LineEdit.new()
	_name_edit.text = "Serra Dourada Futebol Clube"
	grid.add_child(_name_edit)
	
	var l2 = Label.new()
	l2.text = "Sigla (3 letras):"
	grid.add_child(l2)
	_short_name_edit = LineEdit.new()
	_short_name_edit.text = "SDF"
	_short_name_edit.max_length = 5
	grid.add_child(_short_name_edit)
	
	var l3 = Label.new()
	l3.text = "Cidade:"
	grid.add_child(l3)
	_city_edit = LineEdit.new()
	_city_edit.text = "Serra Alta"
	grid.add_child(_city_edit)
	
	var l4 = Label.new()
	l4.text = "Nome do Estádio:"
	grid.add_child(l4)
	_stadium_name_edit = LineEdit.new()
	_stadium_name_edit.text = "Arena da Serra"
	grid.add_child(_stadium_name_edit)
	
	var l5 = Label.new()
	l5.text = "Cor Primária:"
	grid.add_child(l5)
	_color_primary_btn = ColorPickerButton.new()
	_color_primary_btn.color = Color("#E6A100")
	grid.add_child(_color_primary_btn)
	
	var l6 = Label.new()
	l6.text = "Cor Secundária:"
	grid.add_child(l6)
	_color_secondary_btn = ColorPickerButton.new()
	_color_secondary_btn.color = Color("#111111")
	grid.add_child(_color_secondary_btn)
	
	_confirm_new_btn = Button.new()
	_confirm_new_btn.text = "Fundar Clube e Iniciar Carreira"
	_confirm_new_btn.pressed.connect(_on_confirm_new_pressed)
	tab_new.add_child(_confirm_new_btn)

func setup(p_game_state: RefCounted) -> void:
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
	var cid = str(_existing_clubs_list.get_item_metadata(index))
	var club = game_state.get_club(cid)
	if club != null:
		var info = "CLUBE: %s (%s)\n" % [club.name, club.short_name]
		info += "Fundação: %d | Cidade: %s (%s)\n" % [club.founded_year, club.city, club.country]
		info += "Reputação: %d/100 | Saldo Inicial: R$ %d\n" % [club.reputation, club.get_balance()]
		info += "Tamanho do Elenco: %d atletas\n\n" % club.squad.size()
		info += "Cores: Primária %s | Secundária %s" % [club.colors.get("primary", ""), club.colors.get("secondary", "")]
		_club_preview_label.text = info

func _on_confirm_existing_pressed() -> void:
	var sel = _existing_clubs_list.get_selected_items()
	if sel.is_empty():
		return
	var cid = str(_existing_clubs_list.get_item_metadata(sel[0]))
	if game_state != null:
		game_state.user_club_id = cid
	club_confirmed.emit(cid)

func _on_confirm_new_pressed() -> void:
	if game_state == null:
		return
		
	# Assume o primeiro clube (ex: Aurora FC) e customiza seus dados conforme o wizard do jogador
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
		
		# Atualiza nome do estadio
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
