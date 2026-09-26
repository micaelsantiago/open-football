extends RigidBody2D
class_name Ball

var initial_position: Vector2 = Vector2.ZERO
var _need_reset: bool = false
var _reset_target: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("ball")
	initial_position = global_position
	gravity_scale = 0.0
	linear_damp = 1.35
	angular_damp = 2.0
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY

func reset_to(pos: Vector2) -> void:
	_reset_target = pos
	_need_reset = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _need_reset:
		state.transform = Transform2D(0.0, _reset_target)
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		_need_reset = false

func kick(impulse: Vector2) -> void:
	apply_central_impulse(impulse)

func _draw() -> void:
	var radius := 12.0
	# Sombra
	draw_circle(Vector2(2, 4), radius, Color(0, 0, 0, 0.25))
	# Bola branca
	draw_circle(Vector2.ZERO, radius, Color(0.97, 0.97, 0.97))
	# Padrão de gomos pretos da bola clássica
	draw_circle(Vector2.ZERO, 3.8, Color(0.15, 0.15, 0.18))
	for i in range(5):
		var angle = i * TAU / 5.0
		var spot_pos = Vector2(cos(angle), sin(angle)) * 8.0
		draw_circle(spot_pos, 2.4, Color(0.15, 0.15, 0.18))
	# Borda externa
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color(0.1, 0.1, 0.1), 1.5, true)
