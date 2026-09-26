class_name WorldCamera2D
extends Camera2D

const IsometricGridHelperClass = preload("res://src/presentation/world_2d/grid/isometric_grid_helper.gd")

@export var pan_speed: float = 600.0
@export var zoom_speed: float = 0.12
@export var min_zoom: float = 0.4
@export var max_zoom: float = 2.5
@export var zoom_smoothness: float = 8.0

var _is_panning: bool = false
var _target_zoom: float = 1.0

func _ready() -> void:
	_target_zoom = zoom.x

func _process(delta: float) -> void:
	# Movimentacao continua por teclado (WASD / Setas)
	var move_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if move_dir != Vector2.ZERO:
		position += move_dir * (pan_speed / maxf(0.01, zoom.x)) * delta
		
	# Interpolacao suave de zoom
	if not is_equal_approx(zoom.x, _target_zoom):
		var new_z = move_toward(zoom.x, _target_zoom, zoom_smoothness * delta)
		zoom = Vector2(new_z, new_z)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		# Pan com botao direito ou botao do meio do mouse
		if mb.button_index == MOUSE_BUTTON_RIGHT or mb.button_index == MOUSE_BUTTON_MIDDLE:
			_is_panning = mb.is_pressed()
			
		# Zoom com roda do mouse
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_zoom = clampf(_target_zoom + zoom_speed, min_zoom, max_zoom)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_zoom = clampf(_target_zoom - zoom_speed, min_zoom, max_zoom)
			
	elif event is InputEventMouseMotion and _is_panning:
		var mm := event as InputEventMouseMotion
		position -= mm.relative / maxf(0.01, zoom.x)

## Centraliza a camera instantaneamente ou suavemente em um ponto do mundo
func focus_on_world_position(target: Vector2, smooth: bool = false) -> void:
	if smooth:
		var tween = create_tween()
		tween.tween_property(self, "position", target, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		position = target

## Centraliza a camera em uma coordenada da grade isometrica
func focus_on_grid(grid_pos: Vector2i, smooth: bool = false) -> void:
	var world_target = IsometricGridHelperClass.grid_to_world_center(grid_pos)
	focus_on_world_position(world_target, smooth)
