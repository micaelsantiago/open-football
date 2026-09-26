extends Node2D

@onready var ball: RigidBody2D = $Ball
@onready var player: CharacterBody2D = $Player
@onready var bot: CharacterBody2D = $Bot
@onready var score_label: Label = $CanvasLayer/HUD/ScoreLabel
@onready var timer_label: Label = $CanvasLayer/HUD/TimerLabel
@onready var banner_panel: ColorRect = $CanvasLayer/HUD/BannerPanel
@onready var banner_label: Label = $CanvasLayer/HUD/BannerPanel/BannerLabel
@onready var info_label: Label = $CanvasLayer/HUD/InfoLabel
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

const SPAWN_BALL := Vector2(576, 324)
const SPAWN_PLAYER := Vector2(400, 324)
const SPAWN_BOT := Vector2(752, 324)

var player_score: int = 0
var bot_score: int = 0
var match_time: float = 90.0
var is_celebrating: bool = false
var match_over: bool = false

# Streams de áudio procedurais
var sfx_kick: AudioStreamWAV
var sfx_goal: AudioStreamWAV
var sfx_whistle: AudioStreamWAV

func _ready() -> void:
	_setup_audio()
	_update_scoreboard()
	banner_panel.visible = false

	# Conecta gols
	$Goals/LeftGoalArea.body_entered.connect(_on_left_goal_entered)
	$Goals/RightGoalArea.body_entered.connect(_on_right_goal_entered)
	player.ball_kicked.connect(play_kick_sfx)

	# Apito inicial
	play_whistle_sfx()

var _frame_count: int = 0

func _process(delta: float) -> void:
	_frame_count += 1
	if _frame_count == 5 and "--take-screenshot" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		img.save_png("screenshot.png")
		print("SCREENSHOT_SAVED_SUCCESSFULLY")
		get_tree().quit()

	if not match_over and not is_celebrating:
		match_time -= delta
		if match_time <= 0.0:
			match_time = 0.0
			_end_match()
		_update_timer_label()

	if Input.is_physical_key_pressed(KEY_R):
		_restart_match()

func _update_timer_label() -> void:
	var minutes := int(match_time) / 60
	var seconds := int(match_time) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func _update_scoreboard() -> void:
	score_label.text = "AZUL  %d  x  %d  VERMELHO" % [player_score, bot_score]

func _on_left_goal_entered(body: Node2D) -> void:
	if body.is_in_group("ball") and not is_celebrating and not match_over:
		# Bola entrou no gol esquerdo (Gol do Bot)
		bot_score += 1
		_trigger_goal("GOL DO ADVERSÁRIO (VERMELHO)!", Color(1.0, 0.4, 0.4))

func _on_right_goal_entered(body: Node2D) -> void:
	if body.is_in_group("ball") and not is_celebrating and not match_over:
		# Bola entrou no gol direito (Gol do Jogador)
		player_score += 1
		_trigger_goal("GOOOOOOOL DO JOGADOR (AZUL)!", Color(0.35, 0.85, 1.0))

func _trigger_goal(text: String, color: Color) -> void:
	is_celebrating = true
	_update_scoreboard()
	play_goal_sfx()

	banner_label.text = text
	banner_label.add_theme_color_override("font_color", color)
	banner_panel.visible = true

	await get_tree().create_timer(1.8).timeout

	if not match_over:
		banner_panel.visible = false
		_reset_positions()
		play_whistle_sfx()
		is_celebrating = false

func _reset_positions() -> void:
	ball.reset_to(SPAWN_BALL)
	player.reset_position(SPAWN_PLAYER)
	bot.reset_position(SPAWN_BOT)

func _end_match() -> void:
	match_over = true
	play_whistle_sfx()
	var result_text := ""
	var result_color := Color.WHITE
	if player_score > bot_score:
		result_text = "FIM DE JOGO: VITÓRIA DO JOGADOR!\n[Pressione R para reiniciar]"
		result_color = Color(0.4, 1.0, 0.4)
	elif bot_score > player_score:
		result_text = "FIM DE JOGO: O BOT VENCEU!\n[Pressione R para reiniciar]"
		result_color = Color(1.0, 0.4, 0.4)
	else:
		result_text = "FIM DE JOGO: EMPATE!\n[Pressione R para reiniciar]"
		result_color = Color(1.0, 0.9, 0.3)

	banner_label.text = result_text
	banner_label.add_theme_color_override("font_color", result_color)
	banner_panel.visible = true

func _restart_match() -> void:
	player_score = 0
	bot_score = 0
	match_time = 90.0
	match_over = false
	is_celebrating = false
	banner_panel.visible = false
	_update_scoreboard()
	_reset_positions()
	play_whistle_sfx()

# ================= ÁUDIO PROCEDURAL =================
func _setup_audio() -> void:
	sfx_kick = _generate_tone(180.0, 0.08, 0.7)
	sfx_whistle = _generate_whistle(880.0, 0.35)
	sfx_goal = _generate_goal_fanfare()

func _generate_tone(freq: float, duration: float, decay: float) -> AudioStreamWAV:
	var rate := 22050
	var samples := int(rate * duration)
	var data := PackedByteArray()
	data.resize(samples)
	for i in range(samples):
		var t := float(i) / float(rate)
		var env := pow(1.0 - (float(i) / float(samples)), decay)
		var wave := sin(TAU * freq * t) * env
		data[i] = int(clampf(wave * 120.0 + 128.0, 0.0, 255.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_8_BITS
	s.mix_rate = rate
	s.data = data
	return s

func _generate_whistle(freq: float, duration: float) -> AudioStreamWAV:
	var rate := 22050
	var samples := int(rate * duration)
	var data := PackedByteArray()
	data.resize(samples)
	for i in range(samples):
		var t := float(i) / float(rate)
		var mod := sin(TAU * 25.0 * t) * 40.0
		var wave := sin(TAU * (freq + mod) * t) * 0.7
		data[i] = int(clampf(wave * 120.0 + 128.0, 0.0, 255.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_8_BITS
	s.mix_rate = rate
	s.data = data
	return s

func _generate_goal_fanfare() -> AudioStreamWAV:
	var rate := 22050
	var duration := 0.6
	var samples := int(rate * duration)
	var data := PackedByteArray()
	data.resize(samples)
	for i in range(samples):
		var t := float(i) / float(rate)
		var pitch := 523.25 if t < 0.2 else (659.25 if t < 0.4 else 783.99)
		var env := 1.0 - (fmod(t, 0.2) / 0.2)
		var wave := sin(TAU * pitch * t) * env * 0.75
		data[i] = int(clampf(wave * 120.0 + 128.0, 0.0, 255.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_8_BITS
	s.mix_rate = rate
	s.data = data
	return s

func play_kick_sfx() -> void:
	if audio_player and sfx_kick:
		audio_player.stream = sfx_kick
		audio_player.play()

func play_whistle_sfx() -> void:
	if audio_player and sfx_whistle:
		audio_player.stream = sfx_whistle
		audio_player.play()

func play_goal_sfx() -> void:
	if audio_player and sfx_goal:
		audio_player.stream = sfx_goal
		audio_player.play()
