extends CharacterBody2D
class_name Bot

@export var move_speed: float = 230.0
@export var kick_force: float = 480.0
@export var kick_range: float = 46.0

var facing_direction: Vector2 = Vector2.LEFT
var kick_cooldown: float = 0.0
var _kick_flash_timer: float = 0.0
var target_goal_pos: Vector2 = Vector2(96, 324) # Gol do jogador (esquerda)
var own_goal_pos: Vector2 = Vector2(1056, 324)   # Gol do bot (direita)

func _ready() -> void:
	add_to_group("bots")

func _physics_process(delta: float) -> void:
	if kick_cooldown > 0.0:
		kick_cooldown -= delta
	if _kick_flash_timer > 0.0:
		_kick_flash_timer -= delta
		queue_redraw()

	var balls := get_tree().get_nodes_in_group("ball")
	if balls.is_empty():
		move_and_slide()
		return

	var ball := balls[0] as RigidBody2D
	if not is_instance_valid(ball):
		move_and_slide()
		return

	var ball_pos := ball.global_position
	var dist_to_ball := global_position.distance_to(ball_pos)

	# Lógica da IA:
	# Se a bola estiver atrás do bot (perto do próprio gol), recua para defender
	var desired_pos := ball_pos
	if ball_pos.x > global_position.x + 10.0:
		# Posiciona-se entre a bola e o próprio gol
		desired_pos = ball_pos.lerp(own_goal_pos, 0.3)
	else:
		# Vai na direção da bola para empurrar/chutar em direção ao gol adversário
		desired_pos = ball_pos

	var move_dir := (desired_pos - global_position).normalized()
	velocity = velocity.move_toward(move_dir * move_speed, 1200.0 * delta)

	if move_dir != Vector2.ZERO:
		facing_direction = move_dir
		queue_redraw()

	move_and_slide()
	_handle_ball_collisions()

	# Chute do Bot quando próximo da bola
	if dist_to_ball <= kick_range and kick_cooldown <= 0.0:
		_kick_towards_goal(ball)

func _handle_ball_collisions() -> void:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is RigidBody2D and collider.is_in_group("ball"):
			var push_dir := -collision.get_normal()
			collider.apply_central_impulse(push_dir * 130.0)

func _kick_towards_goal(ball: RigidBody2D) -> void:
	# Mira no gol do jogador com pequena variação na altura
	var target := target_goal_pos + Vector2(0, randf_range(-40.0, 40.0))
	var kick_dir := (target - ball.global_position).normalized()
	ball.apply_central_impulse(kick_dir * kick_force)
	kick_cooldown = 0.5
	_kick_flash_timer = 0.15
	queue_redraw()

func reset_position(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	facing_direction = Vector2.LEFT
	kick_cooldown = 0.5
	queue_redraw()

func _draw() -> void:
	var radius := 18.0
	# Sombra
	draw_circle(Vector2(2, 4), radius, Color(0, 0, 0, 0.25))

	# Flash do chute
	if _kick_flash_timer > 0.0:
		draw_arc(Vector2.ZERO, radius + 8.0, 0, TAU, 32, Color(1, 0.4, 0.2, 0.8), 3.0, true)

	# Corpo do Bot (Camisa Vermelha)
	draw_circle(Vector2.ZERO, radius, Color(0.88, 0.22, 0.22))
	# Contorno branco
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color.WHITE, 2.0, true)

	# Detalhe do uniforme
	draw_circle(Vector2.ZERO, 6.0, Color.WHITE)
	draw_circle(Vector2.ZERO, 3.5, Color(0.88, 0.22, 0.22))

	# Indicador da direção
	var pointer_tip := facing_direction * (radius + 6.0)
	var side_offset := Vector2(-facing_direction.y, facing_direction.x) * 4.0
	var pointer_base1 := facing_direction * (radius - 2.0) + side_offset
	var pointer_base2 := facing_direction * (radius - 2.0) - side_offset
	var triangle := PackedVector2Array([pointer_tip, pointer_base1, pointer_base2])
	draw_colored_polygon(triangle, Color(1.0, 0.85, 0.1))
