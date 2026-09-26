class_name ActionModal
extends Control

signal confirmed()
signal cancelled()
signal closed()

var _dimmer: ColorRect
var _dialog_panel: PanelContainer
var _title_label: Label
var _content_container: VBoxContainer
var _confirm_btn: Button
var _cancel_btn: Button
var _close_btn: Button

func _ready() -> void:
	_build_ui_structure()
	visible = false

func _build_ui_structure() -> void:
	if _dialog_panel != null:
		return
		
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	_dimmer = ColorRect.new()
	_dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dimmer.color = Color(0.05, 0.05, 0.08, 0.65)
	add_child(_dimmer)
	
	var center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	center_container.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(center_container)
	
	_dialog_panel = PanelContainer.new()
	_dialog_panel.custom_minimum_size = Vector2(460, 280)
	center_container.add_child(_dialog_panel)
	
	var main_vbox = VBoxContainer.new()
	_dialog_panel.add_child(main_vbox)
	
	# Top bar com titulo e botao fechar
	var top_bar = HBoxContainer.new()
	main_vbox.add_child(top_bar)
	
	_title_label = Label.new()
	_title_label.text = "Janela de Ação"
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.add_theme_font_size_override("font_size", 16)
	top_bar.add_child(_title_label)
	
	_close_btn = Button.new()
	_close_btn.text = " X "
	_close_btn.pressed.connect(close)
	top_bar.add_child(_close_btn)
	
	main_vbox.add_child(HSeparator.new())
	
	# Container do conteudo customizado
	_content_container = VBoxContainer.new()
	_content_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(_content_container)
	
	main_vbox.add_child(HSeparator.new())
	
	# Barra de acoes inferiores
	var btn_hbox = HBoxContainer.new()
	btn_hbox.alignment = BoxContainer.ALIGNMENT_END
	main_vbox.add_child(btn_hbox)
	
	_cancel_btn = Button.new()
	_cancel_btn.text = "Cancelar"
	_cancel_btn.pressed.connect(func():
		cancelled.emit()
		close()
	)
	btn_hbox.add_child(_cancel_btn)
	
	_confirm_btn = Button.new()
	_confirm_btn.text = "Confirmar"
	_confirm_btn.pressed.connect(func():
		confirmed.emit()
		close()
	)
	btn_hbox.add_child(_confirm_btn)

func open(title: String, confirm_text: String = "Confirmar", cancel_text: String = "Cancelar") -> void:
	_build_ui_structure()
	_title_label.text = title
	_confirm_btn.text = confirm_text
	_cancel_btn.text = cancel_text
	visible = true

func close() -> void:
	visible = false
	closed.emit()

func get_content_container() -> VBoxContainer:
	_build_ui_structure()
	return _content_container
