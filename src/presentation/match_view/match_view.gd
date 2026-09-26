class_name MatchView
extends Control

const MatchSimulationClass = preload("res://src/core/match/match_simulation.gd")
const MatchEventClass = preload("res://src/core/match/match_event.gd")
const EventBusClass = preload("res://src/systems/event_bus/event_bus.gd")

signal match_finished(result: Dictionary)
signal tick_advanced(minute: int)

var simulation: RefCounted # MatchSimulation
var user_is_home: bool = true

var is_paused: bool = false
var playback_speed: float = 1.0 # 1.0x ou 2.0x
var tick_interval: float = 0.40 # ~12s por partida no 1x
var _time_accumulator: float = 0.0

var feed_messages: Array = []

# Nós de interface
var _home_name_label: Label
var _away_name_label: Label
var _score_label: Label
var _clock_label: Label

var _possession_bar: ProgressBar
var _possession_label: Label
var _shots_label: Label

var _commentary_feed: RichTextLabel

var _pause_btn: Button
var _speed_btn: Button
var _skip_btn: Button
var _tactics_option: OptionButton

func _ready() -> void:
	_build_ui_structure()

func _build_ui_structure() -> void:
	if _score_label != null:
		return
		
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var main_panel = PanelContainer.new()
	main_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_panel)
	
	var vbox = VBoxContainer.new()
	main_panel.add_child(vbox)
	
	# 1. Placar e Cronometro
	var score_panel = PanelContainer.new()
	vbox.add_child(score_panel)
	
	var score_hbox = HBoxContainer.new()
	score_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	score_panel.add_child(score_hbox)
	
	_home_name_label = Label.new()
	_home_name_label.text = "MANDANTE"
	_home_name_label.add_theme_font_size_override("font_size", 18)
	_home_name_label.custom_minimum_size = Vector2(220, 0)
	_home_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_hbox.add_child(_home_name_label)
	
	_score_label = Label.new()
	_score_label.text = " [ 0 - 0 ] "
	_score_label.add_theme_font_size_override("font_size", 24)
	_score_label.custom_minimum_size = Vector2(140, 0)
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_hbox.add_child(_score_label)
	
	_away_name_label = Label.new()
	_away_name_label.text = "VISITANTE"
	_away_name_label.add_theme_font_size_override("font_size", 18)
	_away_name_label.custom_minimum_size = Vector2(220, 0)
	_away_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	score_hbox.add_child(_away_name_label)
	
	_clock_label = Label.new()
	_clock_label.text = "00'"
	_clock_label.add_theme_font_size_override("font_size", 18)
	_clock_label.add_theme_color_override("font_color", Color.GOLD)
	_clock_label.custom_minimum_size = Vector2(80, 0)
	_clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_hbox.add_child(_clock_label)
	
	vbox.add_child(HSeparator.new())
	
	# 2. Barra de Posse de Bola e Finalizacoes
	var stats_vbox = VBoxContainer.new()
	vbox.add_child(stats_vbox)
	
	var poss_hbox = HBoxContainer.new()
	stats_vbox.add_child(poss_hbox)
	
	_possession_label = Label.new()
	_possession_label.text = "Posse: 50% vs 50%"
	_possession_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	poss_hbox.add_child(_possession_label)
	
	_shots_label = Label.new()
	_shots_label.text = "Finalizações: 0 (0 no gol) vs 0 (0 no gol)"
	_shots_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	poss_hbox.add_child(_shots_label)
	
	_possession_bar = ProgressBar.new()
	_possession_bar.custom_minimum_size = Vector2(0, 14)
	_possession_bar.value = 50.0
	_possession_bar.show_percentage = false
	stats_vbox.add_child(_possession_bar)
	
	vbox.add_child(HSeparator.new())
	
	# 3. Feed de Narracao em Tempo Real
	var feed_panel = PanelContainer.new()
	feed_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(feed_panel)
	
	_commentary_feed = RichTextLabel.new()
	_commentary_feed.bbcode_enabled = true
	_commentary_feed.scroll_following = true
	_commentary_feed.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_commentary_feed.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	feed_panel.add_child(_commentary_feed)
	
	vbox.add_child(HSeparator.new())
	
	# 4. Barra de Controles e Intervencao Tatica
	var ctrl_hbox = HBoxContainer.new()
	vbox.add_child(ctrl_hbox)
	
	_pause_btn = Button.new()
	_pause_btn.text = "⏸️ Pausar"
	_pause_btn.pressed.connect(toggle_pause)
	ctrl_hbox.add_child(_pause_btn)
	
	_speed_btn = Button.new()
	_speed_btn.text = "⏩ 1x"
	_speed_btn.pressed.connect(toggle_speed)
	ctrl_hbox.add_child(_speed_btn)
	
	_skip_btn = Button.new()
	_skip_btn.text = "⏭️ Pular para o Final"
	_skip_btn.pressed.connect(skip_to_end)
	ctrl_hbox.add_child(_skip_btn)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ctrl_hbox.add_child(spacer)
	
	var tact_lbl = Label.new()
	tact_lbl.text = "Mudar Postura: "
	ctrl_hbox.add_child(tact_lbl)
	
	_tactics_option = OptionButton.new()
	_tactics_option.add_item("Equilibrada (BALANCED)", 0)
	_tactics_option.add_item("Ofensiva (OFFENSIVE)", 1)
	_tactics_option.add_item("Defensiva (DEFENSIVE)", 2)
	_tactics_option.item_selected.connect(_on_tactics_changed)
	ctrl_hbox.add_child(_tactics_option)

func setup(p_sim: RefCounted, p_user_is_home: bool = true) -> void:
	_build_ui_structure()
	simulation = p_sim
	user_is_home = p_user_is_home
	is_paused = false
	_time_accumulator = 0.0
	feed_messages.clear()
	
	_home_name_label.text = simulation.get_home_name().to_upper()
	_away_name_label.text = simulation.get_away_name().to_upper()
	_commentary_feed.clear()
	update_display()

func _process(delta: float) -> void:
	if simulation == null or simulation.is_finished or is_paused:
		return
		
	_time_accumulator += delta * playback_speed
	var current_step_time = tick_interval
	
	while _time_accumulator >= current_step_time and not simulation.is_finished:
		_time_accumulator -= current_step_time
		step_tick()

func step_tick() -> void:
	if simulation == null or simulation.is_finished:
		return
		
	var new_events = simulation.tick()
	for evt in new_events:
		_append_event_to_feed(evt)
		
	update_display()
	tick_advanced.emit(simulation.current_minute)
	
	if simulation.is_finished:
		_on_match_concluded()

func update_display() -> void:
	if simulation == null:
		return
		
	_score_label.text = " [ %d - %d ] " % [simulation.home_score, simulation.away_score]
	_clock_label.text = "%d'" % simulation.current_minute
	
	var poss = simulation.get_possession_percentages()
	_possession_bar.value = float(poss["home"])
	_possession_label.text = "Posse: %s %d%% vs %d%% %s" % [simulation.get_home_name(), poss["home"], poss["away"], simulation.get_away_name()]
	_shots_label.text = "Finalizações: %d (%d) vs %d (%d)" % [
		simulation.home_shots, simulation.home_shots_on_target,
		simulation.away_shots, simulation.away_shots_on_target
	]

func _append_event_to_feed(evt: RefCounted) -> void:
	var desc = str(evt.description)
	feed_messages.append(desc)
	var type = int(evt.type)
	
	match type:
		MatchEventClass.Type.GOAL:
			_commentary_feed.append_text("[b][color=#2ECC71]%s[/color][/b]\n" % desc)
		MatchEventClass.Type.YELLOW_CARD, MatchEventClass.Type.RED_CARD:
			_commentary_feed.append_text("[color=#F39C12]%s[/color]\n" % desc)
		MatchEventClass.Type.KICKOFF, MatchEventClass.Type.HALF_TIME, MatchEventClass.Type.FULL_TIME:
			_commentary_feed.append_text("[b][color=#3498DB]%s[/color][/b]\n" % desc)
		MatchEventClass.Type.WOODWORK:
			_commentary_feed.append_text("[b][color=#E67E22]%s[/color][/b]\n" % desc)
		_:
			_commentary_feed.append_text("[color=#BDC3C7]%s[/color]\n" % desc)

func toggle_pause() -> void:
	is_paused = not is_paused
	_pause_btn.text = "▶️ Continuar" if is_paused else "⏸️ Pausar"

func toggle_speed() -> void:
	if playback_speed == 1.0:
		playback_speed = 2.0
		_speed_btn.text = "⏩ 2x"
	else:
		playback_speed = 1.0
		_speed_btn.text = "⏩ 1x"

func skip_to_end() -> void:
	if simulation == null or simulation.is_finished:
		return
	while not simulation.is_finished:
		step_tick()

func _on_tactics_changed(idx: int) -> void:
	if simulation == null:
		return
	var new_ment = "BALANCED"
	if idx == 1:
		new_ment = "OFFENSIVE"
	elif idx == 2:
		new_ment = "DEFENSIVE"
		
	if user_is_home:
		simulation.set_home_mentality(new_ment)
	else:
		simulation.set_away_mentality(new_ment)

func _on_match_concluded() -> void:
	var res = simulation.simulate_full_match()
	_clock_label.text = "Fim"
	_clock_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
	EventBusClass.get_instance().match_ended.emit(res)
	match_finished.emit(res)
