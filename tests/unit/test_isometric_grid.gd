class_name TestIsometricGrid
extends RefCounted

const DataLoader = preload("res://src/systems/data_loader/data_loader.gd")
const GameStateClass = preload("res://src/core/state/game_state.gd")
const FacilityDataClass = preload("res://src/core/facility/facility_data.gd")
const IsometricGridHelperClass = preload("res://src/presentation/world_2d/grid/isometric_grid_helper.gd")
const BuildingNode2DClass = preload("res://src/presentation/world_2d/building/building_node_2d.gd")
const WorldViewClass = preload("res://src/presentation/world_2d/world_view.gd")

static func run_all_tests() -> bool:
	print("\n=== [TEST SUITE] TestIsometricGrid ===")
	var all_passed := true
	
	all_passed = test_grid_to_world_conversions() and all_passed
	all_passed = test_footprint_pivots_and_centers() and all_passed
	all_passed = test_footprint_local_polygon() and all_passed
	all_passed = test_point_in_footprint() and all_passed
	all_passed = test_building_node_setup() and all_passed
	all_passed = test_world_view_loading() and all_passed
	
	if all_passed:
		print("=== [TEST SUITE] TestIsometricGrid: TODOS OS TESTES PASSARAM! ===\n")
	else:
		push_error("=== [TEST SUITE] TestIsometricGrid: FALHA EM TESTES! ===")
		
	return all_passed

static func test_grid_to_world_conversions() -> bool:
	var test_points := [
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(0, 1),
		Vector2i(5, 5),
		Vector2i(12, 8),
		Vector2i(-4, 6)
	]
	
	for gp in test_points:
		var center = IsometricGridHelperClass.grid_to_world_center(gp)
		var back_to_grid = IsometricGridHelperClass.world_to_grid(center)
		assert(back_to_grid == gp, "Falha na conversao reversa de %s: obtido %s" % [str(gp), str(back_to_grid)])
		
	print("[PASS] test_grid_to_world_conversions: Conversoes bidirecionais grid <-> world 2:1 exatas")
	return true

static func test_footprint_pivots_and_centers() -> bool:
	var grid_pos := Vector2i(12, 8)
	var footprint := Vector2i(4, 4)
	
	var pivot = IsometricGridHelperClass.get_footprint_bottom_pivot(grid_pos, footprint)
	var center = IsometricGridHelperClass.get_footprint_center(grid_pos, footprint)
	
	# Bottom vertex deve estar em (12+4 - (8+4))*32 = 128, (12+4 + 8+4)*16 = 448
	assert(pivot.x == 128.0 and pivot.y == 448.0, "Pivô inferior incorreto: %s" % str(pivot))
	# Center deve estar em (14 - 10)*32 = 128, (14 + 10)*16 = 384
	assert(center.x == 128.0 and center.y == 384.0, "Centro geometrico incorreto: %s" % str(center))
	# O vertice inferior (pivô) deve estar estritamente abaixo do centro para o Y-Sort perfeito
	assert(pivot.y > center.y, "Pivô deve ser o vertice mais ao sul no mapa")
	
	print("[PASS] test_footprint_pivots_and_centers: Vertice inferior da base e pivô Y-Sort validados")
	return true

static func test_footprint_local_polygon() -> bool:
	var footprint := Vector2i(4, 4)
	var local_poly = IsometricGridHelperClass.get_footprint_local_polygon(footprint)
	
	assert(local_poly.size() == 4, "Poligono local deve possuir 4 vertices")
	assert(local_poly[0] == Vector2(0, 0), "Vertice 0 deve ser a origem da base (0, 0)")
	assert(local_poly[1] == Vector2(128, -64), "Vertice 1 (Direita) incorreto: %s" % str(local_poly[1]))
	assert(local_poly[2] == Vector2(0, -128), "Vertice 2 (Topo) incorreto: %s" % str(local_poly[2]))
	assert(local_poly[3] == Vector2(-128, -64), "Vertice 3 (Esquerda) incorreto: %s" % str(local_poly[3]))
	
	print("[PASS] test_footprint_local_polygon: Losango local relativo a base (0, 0) comprovado")
	return true

static func test_point_in_footprint() -> bool:
	var grid_pos := Vector2i(10, 10)
	var footprint := Vector2i(2, 2)
	
	var inside_point = IsometricGridHelperClass.get_footprint_center(grid_pos, footprint)
	var outside_point = inside_point + Vector2(200, 200)
	
	assert(IsometricGridHelperClass.is_point_in_footprint(inside_point, grid_pos, footprint), "Ponto central deveria estar contido")
	assert(not IsometricGridHelperClass.is_point_in_footprint(outside_point, grid_pos, footprint), "Ponto distante nao deveria estar contido")
	
	print("[PASS] test_point_in_footprint: Deteccao geometrica de pontos no footprint validada")
	return true

static func test_building_node_setup() -> bool:
	var fac = FacilityDataClass.new()
	fac.id = "test-stadium"
	fac.type = "STADIUM"
	fac.name = "Estadio Teste"
	fac.grid_x = 12
	fac.grid_y = 8
	fac.current_level = 1
	fac.levels = [{
		"level": 1,
		"name": "Nivel 1",
		"capacity": 3000,
		"visual": { "footprint_width": 4, "footprint_height": 4 }
	}]
	
	var node = BuildingNode2DClass.new()
	node.setup(fac, Color.BLUE)
	
	assert(node.facility_id == "test-stadium", "ID do predio incorreto")
	assert(node.footprint_size == Vector2i(4, 4), "Footprint incorreto")
	var expected_pos = IsometricGridHelperClass.get_footprint_bottom_pivot(Vector2i(12, 8), Vector2i(4, 4))
	assert(node.position == expected_pos, "Posicao do predio nao coincide com o pivô inferior")
	
	node.queue_free()
	print("[PASS] test_building_node_setup: Instanciacao, posicionamento e colisao do BuildingNode2D validados")
	return true

static func test_world_view_loading() -> bool:
	var db = DataLoader.load_database("res://data")
	var state = GameStateClass.create_from_database(db, "club-aurora-fc", 100)
	
	var wv = WorldViewClass.new()
	wv.load_club_world(state, "club-aurora-fc")
	
	assert(wv.layer_entities != null, "layer_entities nao foi inicializada")
	assert(wv.layer_entities.y_sort_enabled, "Y-Sort deve estar obrigatoriamente habilitado na layer de entidades")
	
	var buildings_count = wv.layer_entities.get_child_count()
	assert(buildings_count == 3, "Aurora FC deve possuir exatamente 3 predios na sede (Estadio, CT, Sede), encontrado: %d" % buildings_count)
	
	assert(wv.camera != null, "WorldCamera2D deve estar presente na cena")
	
	wv.queue_free()
	print("[PASS] test_world_view_loading: Cena WorldView com 3 predios e Y-Sort carregada com sucesso")
	return true
