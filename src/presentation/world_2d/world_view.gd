class_name WorldView
extends Node2D

const IsometricGridHelperClass = preload("res://src/presentation/world_2d/grid/isometric_grid_helper.gd")
const BuildingNode2DClass = preload("res://src/presentation/world_2d/building/building_node_2d.gd")
const WorldCamera2DClass = preload("res://src/presentation/world_2d/camera/world_camera_2d.gd")

signal facility_selected(facility_id: String)
signal facility_hovered(facility_id: String)

@export var map_width: int = 32
@export var map_height: int = 32

var game_state: RefCounted
var current_club_id: String = ""

var layer_terrain: Node2D
var layer_entities: Node2D
var camera: WorldCamera2D

func _ready() -> void:
	_setup_nodes()

func _setup_nodes() -> void:
	if layer_terrain == null:
		layer_terrain = Node2D.new()
		layer_terrain.name = "Layer_Terrain"
		add_child(layer_terrain)
		
	if layer_entities == null:
		layer_entities = Node2D.new()
		layer_entities.name = "Layer_Entities"
		layer_entities.y_sort_enabled = true
		add_child(layer_entities)
		
	if camera == null:
		camera = WorldCamera2D.new()
		camera.name = "WorldCamera2D"
		add_child(camera)
		if is_inside_tree():
			camera.make_current()

func _enter_tree() -> void:
	if camera != null:
		camera.make_current()

func load_club_world(p_game_state: RefCounted, club_id: String = "") -> void:
	_setup_nodes()
	game_state = p_game_state
	if not club_id.is_empty():
		current_club_id = club_id
	elif game_state != null:
		current_club_id = str(game_state.get("user_club_id"))
		
	refresh_world()

func refresh_world() -> void:
	if game_state == null:
		return
		
	var club = game_state.get_club(current_club_id)
	var club_color = Color("#2D72D2")
	if club != null and club.get("get_primary_color") != null:
		club_color = club.get_primary_color()
		
	# Limpa entidades antigas
	for child in layer_entities.get_children():
		child.queue_free()
		
	# Instancia instalacoes associadas ao clube
	var first_building_pos := Vector2.ZERO
	for fid in game_state.facilities:
		var fac = game_state.facilities[fid]
		if str(fac.club_id) == current_club_id:
			var bld = BuildingNode2DClass.new()
			layer_entities.add_child(bld)
			bld.setup(fac, club_color)
			bld.building_clicked.connect(func(id: String): facility_selected.emit(id))
			bld.building_hover_started.connect(func(id: String): facility_hovered.emit(id))
			
			if first_building_pos == Vector2.ZERO:
				first_building_pos = bld.position
				
	# Centraliza a camera na primeira instalacao
	if first_building_pos != Vector2.ZERO and camera != null:
		camera.focus_on_world_position(first_building_pos + Vector2(0, -60))
	elif camera != null:
		camera.focus_on_grid(Vector2i(12, 10))

func _draw() -> void:
	# Renderiza a malha do terreno com tiles 64x32
	var grass_light = Color(0.28, 0.62, 0.24)
	var grass_dark = Color(0.24, 0.56, 0.20)
	var grid_line = Color(0.22, 0.50, 0.18, 0.4)
	
	for gx in range(0, map_width):
		for gy in range(0, map_height):
			var tile_pos = IsometricGridHelperClass.grid_to_world_top(Vector2i(gx, gy))
			var half_w = IsometricGridHelperClass.DEFAULT_TILE_WIDTH * 0.5
			var half_h = IsometricGridHelperClass.DEFAULT_TILE_HEIGHT * 0.5
			
			var top = tile_pos
			var right = tile_pos + Vector2(half_w, half_h)
			var bottom = tile_pos + Vector2(0, half_h * 2.0)
			var left = tile_pos + Vector2(-half_w, half_h)
			
			var color = grass_light if ((gx + gy) % 2 == 0) else grass_dark
			var diamond = PackedVector2Array([top, right, bottom, left])
			draw_colored_polygon(diamond, color)
			draw_polyline(diamond, grid_line, 1.0)
