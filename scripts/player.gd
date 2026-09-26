extends CharacterBody2D
class_name Player

@export var move_speed: float = 280.0
@export var acceleration: float = 1600.0
@export var friction: float = 1400.0
@export var kick_force: float = 520.0
@export var kick_range: float = 46.0

var facing_direction: Vector2 = Vector2.RIGHT
var kick_cooldown: float = 0.0
var _kick_flash_timer: float = 0.0
var initial_position: Vector2 = Vector2.ZERO

signal ball_kicked

func _ready() -> void:
	add_to_group("players")
	initial_position = global_position
	_ensure_input_action("move_left", [KEY_A, KEY_LEFT])
	_ensure_input_action("move_right", [KEY_D, KEY_RIGHT])
	_ensure_input_action("move_up", [KEY_W, KEY_UP])
	_ensure_input_action("move_down", [KEY_S, KEY_DOWN])
	_ensure_input_action("kick", [KEY_SPACE, KEY_ENTER])

func _ensure_input_action(action_name: String, keys: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
		for key in keys:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action_name, ev)

func _physics_process(delta: float) -> void:
	if kick_cooldown > 0.0:
		kick_cooldown -= delta
	if _kick_flash_timer > 0.0:
		_kick_flash_timer -= delta
		queue_redraw()

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * move_speed, acceleration * delta)
		facing_direction = input_vector.normalized()
		queue_redraw()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()
	_handle_ball_collisions()

	if Input.is_action_just_pressed("kick") and kick_cooldown <= 0.0:
		_try_kick_ball()

func _handle_ball_collisions() -> void:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is RigidBody2D and collider.is_in_group("ball"):
			var push_dir := -collision.get_normal()
			collider.apply_central_impulse(push_dir * 140.0)

func _try_kick_ball() -> void:
	var balls := get_tree().get_nodes_in_group("ball")
	if balls.is_empty():
		return
	var ball := balls[0] as RigidBody2D
	if not is_instance_valid(ball):
		return

	var dist := global_position.distance_to(ball.global_position)
	if dist <= kick_range:
		var dir := (ball.global_position - global_position).normalized()
		if dir == Vector2.ZERO:
			dir = facing_direction
		ball.apply_central_impulse(dir * kick_force)
		kick_cooldown = 0.25
		_kick_flash_timer = 0.15
		ball_kicked.emit()
		queue_redraw()

func reset_position(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	facing_direction = Vector2.RIGHT
	queue_redraw()

func _draw() -> void:
	var radius := 18.0
	# Sombra
	draw_circle(Vector2(2, 4), radius, Color(0, 0, 0, 0.25))

	# Efeito visual de chute
	if _kick_flash_timer > 0.0:
		draw_arc(Vector2.ZERO, radius + 8.0, 0, TAU, 32, Color(1, 0.9, 0.2, 0.8), 3.0, true)

	# Corpo do jogador (Camisa Azul)
	draw_circle(Vector2.ZERO, radius, Color(0.16, 0.46, 0.92))
	# Contorno branco da camisa
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color.WHITE, 2.0, true)

	# Faixa branca central de uniforme
	draw_circle(Vector2.ZERO, 6.0, Color.WHITE)
	draw_circle(Vector2.ZERO, 3.5, Color(0.16, 0.46, 0.92))

	# Indicador da direção para onde o jogador está virado
	var pointer_tip := facing_direction * (radius + 6.0)
	var side_offset := Vector2(-facing_direction.y, facing_direction.x) * 4.0
	var pointer_base1 := facing_direction * (radius - 2.0) + side_offset
	var pointer_base2 := facing_direction * (radius - 2.0) - side_offset
	var triangle := PackedVector2Array([pointer_tip, pointer_base1, pointer_base2])
	draw_colored_polygon(triangle, Color(1.0, 0.85, 0.1))
