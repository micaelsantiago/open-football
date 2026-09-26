class_name BuildingNode2D
extends Node2D

const IsometricGridHelperClass = preload("res://src/presentation/world_2d/grid/isometric_grid_helper.gd")

signal building_clicked(facility_id: String)
signal building_hover_started(facility_id: String)
signal building_hover_ended(facility_id: String)

@export var facility_id: String = ""

var facility_data: RefCounted = null
var footprint_size: Vector2i = Vector2i(2, 2)
var building_height: float = 48.0
var primary_color: Color = Color("#2D72D2")

var _is_hovered: bool = false
var _area: Area2D
var _collision_poly: CollisionPolygon2D
var _sprite: Sprite2D

func _ready() -> void:
	_setup_interaction_area()
	queue_redraw()

func setup(facility: RefCounted, club_color: Color = Color("#2D72D2")) -> void:
	facility_data = facility
	facility_id = str(facility.id)
	primary_color = club_color
	
	var lvl_data = facility.get_current_level_data()
	var vis = lvl_data.get("visual", {})
	var fw = int(vis.get("footprint_width", 2))
	var fh = int(vis.get("footprint_height", 2))
	footprint_size = Vector2i(fw, fh)
	
	# Ajusta altura visual conforme o tamanho e nivel
	building_height = 36.0 + (footprint_size.x * 8.0) + (facility.current_level * 10.0)
	
	# Posiciona o no no vertice inferior da base (pivô Y-Sort)
	var grid_pos = Vector2i(facility.grid_x, facility.grid_y)
	position = IsometricGridHelperClass.get_footprint_bottom_pivot(grid_pos, footprint_size)
	
	_setup_interaction_area()
	update_visuals()

func update_visuals() -> void:
	if facility_data != null:
		var lvl_data = facility_data.get_current_level_data()
		var texture_path = str(lvl_data.get("visual", {}).get("texture_path", ""))
		if not texture_path.is_empty() and ResourceLoader.exists(texture_path):
			if _sprite == null:
				_sprite = Sprite2D.new()
				add_child(_sprite)
			_sprite.texture = load(texture_path)
			_sprite.centered = false
			_sprite.position = Vector2(-_sprite.texture.get_width() * 0.5, -_sprite.texture.get_height())
			
	queue_redraw()

func _setup_interaction_area() -> void:
	if _area == null:
		_area = Area2D.new()
		_area.name = "ClickArea"
		add_child(_area)
		_collision_poly = CollisionPolygon2D.new()
		_area.add_child(_collision_poly)
		_area.mouse_entered.connect(_on_mouse_entered)
		_area.mouse_exited.connect(_on_mouse_exited)
		_area.input_event.connect(_on_input_event)
		
	# Calcula poligono de colisao abrangendo a base e a elevacao vertical do predio
	var base_poly = IsometricGridHelperClass.get_footprint_local_polygon(footprint_size)
	# Vertices: [Bottom(0,0), Right, Top, Left]
	var bottom = base_poly[0]
	var right = base_poly[1]
	var top = base_poly[2]
	var left = base_poly[3]
	
	var top_elevated = top + Vector2(0, -building_height)
	var right_elevated = right + Vector2(0, -building_height)
	var left_elevated = left + Vector2(0, -building_height)
	
	var hit_poly = PackedVector2Array([
		bottom,
		right,
		right_elevated,
		top_elevated,
		left_elevated,
		left
	])
	_collision_poly.polygon = hit_poly

func _on_mouse_entered() -> void:
	_is_hovered = true
	building_hover_started.emit(facility_id)
	queue_redraw()

func _on_mouse_exited() -> void:
	_is_hovered = false
	building_hover_ended.emit(facility_id)
	queue_redraw()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.is_pressed():
			building_clicked.emit(facility_id)

func _draw() -> void:
	var base_poly = IsometricGridHelperClass.get_footprint_local_polygon(footprint_size)
	var bottom = base_poly[0]
	var right = base_poly[1]
	var top = base_poly[2]
	var left = base_poly[3]
	
	var h_offset = Vector2(0, -building_height)
	var bottom_top = bottom + h_offset
	var right_top = right + h_offset
	var top_top = top + h_offset
	var left_top = left + h_offset
	
	var hover_boost = 0.15 if _is_hovered else 0.0
	
	# Cores arquiteturais 2.5D
	var wall_left_color = Color(0.35 + hover_boost, 0.38 + hover_boost, 0.42 + hover_boost)
	var wall_right_color = Color(0.50 + hover_boost, 0.54 + hover_boost, 0.58 + hover_boost)
	var roof_color = primary_color.lightened(0.1 + hover_boost)
	var outline_color = Color(0.1, 0.12, 0.15) if not _is_hovered else Color.YELLOW
	
	# 1. Parede esquerda
	var left_wall_poly = PackedVector2Array([bottom, left, left_top, bottom_top])
	draw_colored_polygon(left_wall_poly, wall_left_color)
	draw_polyline(left_wall_poly, outline_color, 1.5)
	
	# 2. Parede direita
	var right_wall_poly = PackedVector2Array([bottom, right, right_top, bottom_top])
	draw_colored_polygon(right_wall_poly, wall_right_color)
	draw_polyline(right_wall_poly, outline_color, 1.5)
	
	# 3. Teto / Cobertura
	var roof_poly = PackedVector2Array([bottom_top, right_top, top_top, left_top])
	draw_colored_polygon(roof_poly, roof_color)
	draw_polyline(roof_poly, outline_color, 1.5)
	
	# 4. Detalhe visual de campo de futebol no teto se for estadio
	if facility_data != null and str(facility_data.type) == "STADIUM":
		var pitch_color = Color(0.15, 0.65, 0.25)
		var pitch_center = (bottom_top + top_top) * 0.5
		var pitch_poly = PackedVector2Array([
			pitch_center + (bottom_top - pitch_center) * 0.7,
			pitch_center + (right_top - pitch_center) * 0.7,
			pitch_center + (top_top - pitch_center) * 0.7,
			pitch_center + (left_top - pitch_center) * 0.7
		])
		draw_colored_polygon(pitch_poly, pitch_color)
		draw_polyline(pitch_poly, Color.WHITE, 1.0)
		
	# 5. Indicador de obras (andaimes com faixas amarelas e pretas)
	if facility_data != null and facility_data.is_under_construction:
		var scaffold_color = Color(0.9, 0.7, 0.1, 0.8)
		draw_line(left, left_top + Vector2(0, -10), scaffold_color, 3.0)
		draw_line(right, right_top + Vector2(0, -10), scaffold_color, 3.0)
		draw_line(bottom, bottom_top + Vector2(0, -10), scaffold_color, 3.0)
		draw_line(left_top, right_top, Color(0.95, 0.8, 0.2, 0.9), 2.0)
		
	# 6. Texto com nome e nivel no topo
	if facility_data != null:
		var font = ThemeDB.fallback_font
		var label_str = "%s (Nív. %d)" % [facility_data.name, facility_data.current_level]
		if facility_data.is_under_construction:
			label_str += " [EM OBRAS: %dr]" % facility_data.rounds_remaining
		var txt_pos = top_top + Vector2(-font.get_string_size(label_str).x * 0.5, -12)
		draw_string(font, txt_pos + Vector2(1, 1), label_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.BLACK)
		draw_string(font, txt_pos, label_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.WHITE if not _is_hovered else Color.YELLOW)
