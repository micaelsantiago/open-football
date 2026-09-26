class_name PlayerCard
extends PanelContainer

signal card_clicked(player_id: String)

var player_id: String = ""
var player_data: RefCounted

var _pos_label: Label
var _name_label: Label
var _ovr_label: Label
var _condition_bar: ProgressBar
var _status_label: Label
var _button: Button

func _ready() -> void:
	_build_ui_structure()

func _build_ui_structure() -> void:
	if _button != null:
		return
		
	custom_minimum_size = Vector2(260, 56)
	
	_button = Button.new()
	_button.flat = true
	_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_button)
	_button.pressed.connect(func(): card_clicked.emit(player_id))
	
	var hbox = HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_button.add_child(hbox)
	
	# Badge de posicao
	_pos_label = Label.new()
	_pos_label.custom_minimum_size = Vector2(36, 36)
	_pos_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pos_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(_pos_label)
	
	# VBox de info central
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)
	
	_name_label = Label.new()
	_name_label.text = "Atleta"
	info_vbox.add_child(_name_label)
	
	_condition_bar = ProgressBar.new()
	_condition_bar.custom_minimum_size = Vector2(0, 10)
	_condition_bar.max_value = 100
	_condition_bar.show_percentage = false
	info_vbox.add_child(_condition_bar)
	
	_status_label = Label.new()
	_status_label.add_theme_font_size_override("font_size", 10)
	info_vbox.add_child(_status_label)
	
	# Overall badge na direita
	_ovr_label = Label.new()
	_ovr_label.custom_minimum_size = Vector2(40, 36)
	_ovr_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ovr_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ovr_label.add_theme_font_size_override("font_size", 16)
	hbox.add_child(_ovr_label)

func setup(p_data: RefCounted) -> void:
	_build_ui_structure()
	player_data = p_data
	player_id = str(p_data.id)
	
	var pos = str(p_data.primary_position)
	_pos_label.text = pos
	_update_position_badge_color(pos)
	
	_name_label.text = str(p_data.common_name)
	_condition_bar.value = float(p_data.condition)
	
	if p_data.get("calculate_overall") != null:
		var ovr = p_data.calculate_overall()
		_ovr_label.text = str(ovr)
		_update_overall_color(ovr)
	else:
		_ovr_label.text = "--"
		
	if p_data.injured_rounds_remaining > 0:
		_status_label.text = "Lesionado (%dr)" % p_data.injured_rounds_remaining
		_status_label.add_theme_color_override("font_color", Color.CRIMSON)
	elif p_data.is_suspended:
		_status_label.text = "Suspenso"
		_status_label.add_theme_color_override("font_color", Color.ORANGE)
	else:
		_status_label.text = "Pronto para jogar"
		_status_label.add_theme_color_override("font_color", Color.FOREST_GREEN)

func _update_position_badge_color(pos: String) -> void:
	var color := Color.GRAY
	if pos == "GK":
		color = Color("#D9822B") # Amarelo/Dourado
	elif pos in ["CB", "LB", "RB"]:
		color = Color("#1F78B4") # Azul defesa
	elif pos in ["DM", "CM", "AM"]:
		color = Color("#33A02C") # Verde meio-campo
	elif pos in ["LW", "RW", "ST"]:
		color = Color("#E31A1C") # Vermelho ataque
	_pos_label.add_theme_color_override("font_color", color)

func _update_overall_color(ovr: int) -> void:
	if ovr >= 75:
		_ovr_label.add_theme_color_override("font_color", Color.GOLD)
	elif ovr >= 65:
		_ovr_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
	else:
		_ovr_label.add_theme_color_override("font_color", Color.WHITE)
