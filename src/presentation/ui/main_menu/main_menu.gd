class_name MainMenu
extends Control

const SaveManagerClass = preload("res://src/systems/save_system/save_manager.gd")
const AudioServiceClass = preload("res://src/systems/audio/audio_service.gd")

signal new_career_requested()
signal continue_career_requested()
signal quit_requested()

var _new_btn: Button
var _continue_btn: Button
var _quit_btn: Button
var _save_info_label: Label

func _ready() -> void:
	_build_ui_structure()
	refresh_saves()

func _build_ui_structure() -> void:
	if _new_btn != null:
		return
		
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.08, 0.12, 0.18)
	add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(400, 320)
	center.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "⚽ OPEN FOOTBALL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color.GOLD)
	vbox.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Simulador de Treinador & Gestão Isométrica"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 12)
	vbox.add_child(subtitle)
	
	vbox.add_child(HSeparator.new())
	
	_new_btn = Button.new()
	_new_btn.text = "🌟 Nova Carreira"
	_new_btn.custom_minimum_size = Vector2(0, 36)
	_new_btn.pressed.connect(_on_new_pressed)
	vbox.add_child(_new_btn)
	
	_continue_btn = Button.new()
	_continue_btn.text = "💾 Continuar Carreira"
	_continue_btn.custom_minimum_size = Vector2(0, 36)
	_continue_btn.pressed.connect(_on_continue_pressed)
	vbox.add_child(_continue_btn)
	
	_quit_btn = Button.new()
	_quit_btn.text = "🚪 Sair do Jogo"
	_quit_btn.custom_minimum_size = Vector2(0, 36)
	_quit_btn.pressed.connect(_on_quit_pressed)
	vbox.add_child(_quit_btn)
	
	vbox.add_child(HSeparator.new())
	
	_save_info_label = Label.new()
	_save_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_save_info_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_save_info_label)

func refresh_saves() -> void:
	var saves = SaveManagerClass.list_saves()
	if saves.is_empty():
		_continue_btn.disabled = true
		_save_info_label.text = "Nenhum save encontrado. Inicie uma Nova Carreira!"
		_save_info_label.add_theme_color_override("font_color", Color.GRAY)
	else:
		_continue_btn.disabled = false
		var latest = saves[0]
		_save_info_label.text = "Último Save: %s (Rodada %d)" % [latest.get("club_name", "Clube"), latest.get("current_round", 1)]
		_save_info_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)

func _on_new_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	new_career_requested.emit()

func _on_continue_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	continue_career_requested.emit()

func _on_quit_pressed() -> void:
	AudioServiceClass.get_instance().play_click()
	quit_requested.emit()
	if is_inside_tree():
		get_tree().quit()
