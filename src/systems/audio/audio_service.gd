class_name AudioService
extends Node

static var _instance: AudioService

var _player: AudioStreamPlayer

func _init() -> void:
	if _instance == null:
		_instance = self

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.name = "FXPlayer"
	add_child(_player)

static func get_instance() -> AudioService:
	if _instance == null:
		_instance = AudioService.new()
	return _instance

## Toca apito de arbitro
func play_whistle() -> void:
	_play_procedural_tone(2400.0, 0.18, 0.6)

## Toca clique tatil de interface
func play_click() -> void:
	_play_procedural_tone(1200.0, 0.04, 0.4)

## Toca som de comemoracao de gol
func play_goal() -> void:
	_play_procedural_tone(880.0, 0.45, 0.8)

## Toca som de conclusao de obra / reforma
func play_upgrade() -> void:
	_play_procedural_tone(1760.0, 0.35, 0.7)

func _play_procedural_tone(freq: float, duration: float, volume: float = 0.5) -> void:
	if _player == null:
		return
	var sample_rate := 22050
	var total_frames := int(sample_rate * duration)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	
	var data := PackedByteArray()
	data.resize(total_frames)
	
	for i in range(total_frames):
		var t = float(i) / float(sample_rate)
		# Envoltoria linear simples de ataque e decaimento
		var env = 1.0 - (float(i) / float(total_frames))
		var sample = sin(2.0 * PI * freq * t) * env * volume
		# Converte para 8-bit unsigned (0 a 255, 128 = silencio)
		data[i] = clampi(int(128.0 + sample * 127.0), 0, 255)
		
	stream.data = data
	_player.stream = stream
	if _player.is_inside_tree():
		_player.play()
