extends Node2D
class_name Pitch

# Dimensões do campo (para resolução 1152 x 648)
const FIELD_LEFT = 96.0
const FIELD_RIGHT = 1056.0
const FIELD_TOP = 64.0
const FIELD_BOTTOM = 584.0
const CENTER_X = 576.0
const CENTER_Y = 324.0

const GOAL_TOP = 260.0
const GOAL_BOTTOM = 388.0
const GOAL_DEPTH = 60.0

func _draw() -> void:
	# Fundo geral (grama externa)
	draw_rect(Rect2(0, 0, 1152, 648), Color(0.16, 0.46, 0.22))

	# Faixas verticais de grama (efeito de gramado cortado padrão estádio)
	var stripe_count := 12
	var stripe_w := (FIELD_RIGHT - FIELD_LEFT) / stripe_count
	var color_dark := Color(0.20, 0.54, 0.26)
	var color_light := Color(0.23, 0.60, 0.30)

	for i in range(stripe_count):
		var col = color_light if i % 2 == 0 else color_dark
		draw_rect(Rect2(FIELD_LEFT + i * stripe_w, FIELD_TOP, stripe_w, FIELD_BOTTOM - FIELD_TOP), col)

	var line_color := Color(1.0, 1.0, 1.0, 0.88)
	var line_w := 3.0

	# Linhas laterais e de fundo
	draw_rect(Rect2(FIELD_LEFT, FIELD_TOP, FIELD_RIGHT - FIELD_LEFT, FIELD_BOTTOM - FIELD_TOP), line_color, false, line_w)

	# Linha do meio de campo
	draw_line(Vector2(CENTER_X, FIELD_TOP), Vector2(CENTER_X, FIELD_BOTTOM), line_color, line_w)

	# Círculo central e ponto central
	draw_arc(Vector2(CENTER_X, CENTER_Y), 75.0, 0, TAU, 64, line_color, line_w)
	draw_circle(Vector2(CENTER_X, CENTER_Y), 4.0, line_color)

	# Grande área esquerda e direita
	var penalty_w := 150.0
	var penalty_h := 300.0
	var penalty_top := CENTER_Y - penalty_h / 2.0
	draw_rect(Rect2(FIELD_LEFT, penalty_top, penalty_w, penalty_h), line_color, false, line_w)
	draw_rect(Rect2(FIELD_RIGHT - penalty_w, penalty_top, penalty_w, penalty_h), line_color, false, line_w)

	# Pequena área esquerda e direita
	var box_w := 60.0
	var box_h := 180.0
	var box_top := CENTER_Y - box_h / 2.0
	draw_rect(Rect2(FIELD_LEFT, box_top, box_w, box_h), line_color, false, line_w)
	draw_rect(Rect2(FIELD_RIGHT - box_w, box_top, box_w, box_h), line_color, false, line_w)

	# Marca do pênalti
	draw_circle(Vector2(FIELD_LEFT + 105.0, CENTER_Y), 3.5, line_color)
	draw_circle(Vector2(FIELD_RIGHT - 105.0, CENTER_Y), 3.5, line_color)

	# Meia-lua da grande área (arcos)
	draw_arc(Vector2(FIELD_LEFT + 105.0, CENTER_Y), 55.0, -0.9, 0.9, 32, line_color, line_w)
	draw_arc(Vector2(FIELD_RIGHT - 105.0, CENTER_Y), 55.0, PI - 0.9, PI + 0.9, 32, line_color, line_w)

	# Escanteios
	var corner_r := 16.0
	draw_arc(Vector2(FIELD_LEFT, FIELD_TOP), corner_r, 0, PI * 0.5, 16, line_color, line_w)
	draw_arc(Vector2(FIELD_LEFT, FIELD_BOTTOM), corner_r, -PI * 0.5, 0, 16, line_color, line_w)
	draw_arc(Vector2(FIELD_RIGHT, FIELD_TOP), corner_r, PI * 0.5, PI, 16, line_color, line_w)
	draw_arc(Vector2(FIELD_RIGHT, FIELD_BOTTOM), corner_r, PI, PI * 1.5, 16, line_color, line_w)

	# Redes e traves
	_draw_goal_net(Rect2(FIELD_LEFT - GOAL_DEPTH, GOAL_TOP, GOAL_DEPTH, GOAL_BOTTOM - GOAL_TOP), true)
	_draw_goal_net(Rect2(FIELD_RIGHT, GOAL_TOP, GOAL_DEPTH, GOAL_BOTTOM - GOAL_TOP), false)

func _draw_goal_net(rect: Rect2, is_left: bool) -> void:
	# Fundo da rede
	draw_rect(rect, Color(0.12, 0.35, 0.16, 0.8))

	# Linhas da rede (quadriculado)
	var net_color := Color(0.9, 0.9, 0.9, 0.35)
	var step := 12.0
	var x := rect.position.x
	while x <= rect.end.x:
		draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), net_color, 1.0)
		x += step

	var y := rect.position.y
	while y <= rect.end.y:
		draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), net_color, 1.0)
		y += step

	# Traves (linhas brancas espessas)
	var post_color := Color(1.0, 1.0, 1.0, 1.0)
	var post_w := 4.0
	# Fundo do gol
	if is_left:
		draw_line(rect.position, Vector2(rect.position.x, rect.end.y), post_color, post_w)
	else:
		draw_line(Vector2(rect.end.x, rect.position.y), rect.end, post_color, post_w)
	# Teto e chão do gol
	draw_line(rect.position, Vector2(rect.end.x, rect.position.y), post_color, post_w)
	draw_line(Vector2(rect.position.x, rect.end.y), rect.end, post_color, post_w)
