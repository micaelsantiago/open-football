class_name StadiumUpgradeModal
extends Control

const ActionModalClass = preload("res://src/presentation/ui/common/action_modal.gd")
const EventBusClass = preload("res://src/systems/event_bus/event_bus.gd")
const AudioServiceClass = preload("res://src/systems/audio/audio_service.gd")

signal upgrade_started()
signal closed()

var game_state: RefCounted
var stadium_id: String = ""

var _modal: ActionModal
var _info_label: Label
var _status_label: Label

func _ready() -> void:
	_build_ui_structure()

func _build_ui_structure() -> void:
	if _modal != null:
		return
		
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	_modal = ActionModalClass.new()
	add_child(_modal)
	_modal.confirmed.connect(_on_confirm_upgrade)
	_modal.cancelled.connect(func():
		visible = false
		closed.emit()
	)
	_modal.closed.connect(func():
		visible = false
		closed.emit()
	)
	
	var content = _modal.get_content_container()
	
	_info_label = Label.new()
	_info_label.text = "Informações da Reforma..."
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_info_label)
	
	content.add_child(HSeparator.new())
	
	_status_label = Label.new()
	_status_label.text = ""
	content.add_child(_status_label)

func open_for_stadium(p_game_state: RefCounted, p_stadium_id: String = "") -> void:
	_build_ui_structure()
	visible = true
	game_state = p_game_state
	
	if not p_stadium_id.is_empty():
		stadium_id = p_stadium_id
	else:
		var club = game_state.get_user_club()
		stadium_id = str(club.facilities.get("stadium_id", ""))
		
	refresh()
	_modal.open("Reforma e Expansão do Estádio", "Iniciar Obras", "Fechar")

func refresh() -> void:
	if game_state == null:
		return
		
	var stadium = game_state.get_facility(stadium_id)
	var club = game_state.get_user_club()
	if stadium == null or club == null:
		return
		
	var current_lvl_data = stadium.get_current_level_data()
	var next_lvl_data = stadium.get_next_level_data()
	
	var info = "🏟️ ESTÁDIO ATUAL: %s\n" % stadium.name
	info += "• Nível: %d (%s)\n" % [stadium.current_level, current_lvl_data.get("name", "")]
	info += "• Capacidade: %d torcedores\n" % stadium.get_current_capacity()
	info += "• Custo de Manutenção: R$ %d / rodada\n\n" % stadium.get_maintenance_cost()
	
	if stadium.is_under_construction:
		info += "⚠️ STATUS: OBRAS EM ANDAMENTO!\n"
		info += "Restam %d rodadas para conclusão das obras do Nível %d." % [stadium.rounds_remaining, stadium.target_level]
		_status_label.text = "Aguarde a conclusão das obras ativas."
		_status_label.add_theme_color_override("font_color", Color.GOLD)
		_modal._confirm_btn.disabled = true
	elif next_lvl_data.is_empty():
		info += "✨ NÍVEL MÁXIMO ATINGIDO!\nO estádio já opera em sua capacidade arquitetural máxima."
		_status_label.text = "Sem novas ampliações disponíveis no momento."
		_status_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
		_modal._confirm_btn.disabled = true
	else:
		var cost = int(next_lvl_data.get("upgrade_cost", 150000))
		var duration = int(next_lvl_data.get("construction_time_rounds", 4))
		var new_cap = int(next_lvl_data.get("capacity", 8500))
		
		info += "🚀 PROJETO DE EXPANSÃO (NÍVEL %d):\n" % int(next_lvl_data.get("level", 2))
		info += "• Nova Capacidade: %d torcedores (+%d)\n" % [new_cap, (new_cap - stadium.get_current_capacity())]
		info += "• Duração da Obra: %d rodadas\n" % duration
		info += "• Custo do Projeto: R$ %d\n" % cost
		info += "• Seu Saldo Atual: R$ %d\n" % club.get_balance()
		
		if club.can_afford(cost):
			_status_label.text = "✅ Saldo suficiente para contratar a construtora."
			_status_label.add_theme_color_override("font_color", Color.FOREST_GREEN)
			_modal._confirm_btn.disabled = false
		else:
			_status_label.text = "❌ Saldo insuficiente! Acumule mais bilheteria para financiar."
			_status_label.add_theme_color_override("font_color", Color.CRIMSON)
			_modal._confirm_btn.disabled = true
			
	_info_label.text = info

func _on_confirm_upgrade() -> void:
	if game_state == null:
		return
	var stadium = game_state.get_facility(stadium_id)
	var club = game_state.get_user_club()
	if stadium == null or club == null:
		return
		
	var next_lvl = stadium.get_next_level_data()
	var cost = int(next_lvl.get("upgrade_cost", 150000))
	
	if club.debit(cost):
		stadium.start_upgrade()
		EventBusClass.get_instance().facility_upgrade_started.emit(stadium.id, stadium.target_level)
		AudioServiceClass.get_instance().play_upgrade()
		upgrade_started.emit()
