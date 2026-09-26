class_name IsometricGridHelper
extends RefCounted

const DEFAULT_TILE_WIDTH: float = 64.0
const DEFAULT_TILE_HEIGHT: float = 32.0

## Converte coordenada de grade (gx, gy) para o vertice superior em coordenadas de mundo
static func grid_to_world_top(grid_pos: Vector2i, tile_size: Vector2 = Vector2(DEFAULT_TILE_WIDTH, DEFAULT_TILE_HEIGHT)) -> Vector2:
	var half_w = tile_size.x * 0.5
	var half_h = tile_size.y * 0.5
	var wx = float(grid_pos.x - grid_pos.y) * half_w
	var wy = float(grid_pos.x + grid_pos.y) * half_h
	return Vector2(wx, wy)

## Converte coordenada de grade para o centro geometrico do losango do tile
static func grid_to_world_center(grid_pos: Vector2i, tile_size: Vector2 = Vector2(DEFAULT_TILE_WIDTH, DEFAULT_TILE_HEIGHT)) -> Vector2:
	var top = grid_to_world_top(grid_pos, tile_size)
	return Vector2(top.x, top.y + tile_size.y * 0.5)

## Converte coordenada de grade para mundo (padrao: centro)
static func grid_to_world(grid_pos: Vector2i, tile_size: Vector2 = Vector2(DEFAULT_TILE_WIDTH, DEFAULT_TILE_HEIGHT)) -> Vector2:
	return grid_to_world_center(grid_pos, tile_size)

## Converte coordenada de mundo para a coordenada de grade correspondente
static func world_to_grid(world_pos: Vector2, tile_size: Vector2 = Vector2(DEFAULT_TILE_WIDTH, DEFAULT_TILE_HEIGHT)) -> Vector2i:
	var half_w = tile_size.x * 0.5
	var half_h = tile_size.y * 0.5
	var u = world_pos.x / half_w
	var v = world_pos.y / half_h
	var gx = floori((u + v) * 0.5)
	var gy = floori((v - u) * 0.5)
	return Vector2i(gx, gy)

## Retorna o vertice inferior da base de ocupacao no solo (utilizado como pivô de Y-Sort)
static func get_footprint_bottom_pivot(grid_pos: Vector2i, footprint: Vector2i, tile_size: Vector2 = Vector2(DEFAULT_TILE_WIDTH, DEFAULT_TILE_HEIGHT)) -> Vector2:
	var half_w = tile_size.x * 0.5
	var half_h = tile_size.y * 0.5
	var end_x = grid_pos.x + footprint.x
	var end_y = grid_pos.y + footprint.y
	var wx = float(end_x - end_y) * half_w
	var wy = float(end_x + end_y) * half_h
	return Vector2(wx, wy)

## Retorna o centro geometrico da base de ocupacao no solo
static func get_footprint_center(grid_pos: Vector2i, footprint: Vector2i, tile_size: Vector2 = Vector2(DEFAULT_TILE_WIDTH, DEFAULT_TILE_HEIGHT)) -> Vector2:
	var half_w = tile_size.x * 0.5
	var half_h = tile_size.y * 0.5
	var cx = (float(grid_pos.x) + float(footprint.x) * 0.5) - (float(grid_pos.y) + float(footprint.y) * 0.5)
	var cy = (float(grid_pos.x) + float(footprint.x) * 0.5) + (float(grid_pos.y) + float(footprint.y) * 0.5)
	return Vector2(cx * half_w, cy * half_h)

## Retorna os 4 vertices em coordenadas de mundo do losango da pegada (Topo, Direita, Base, Esquerda)
static func get_footprint_polygon(grid_pos: Vector2i, footprint: Vector2i, tile_size: Vector2 = Vector2(DEFAULT_TILE_WIDTH, DEFAULT_TILE_HEIGHT)) -> PackedVector2Array:
	var half_w = tile_size.x * 0.5
	var half_h = tile_size.y * 0.5
	var gx = float(grid_pos.x)
	var gy = float(grid_pos.y)
	var w = float(footprint.x)
	var h = float(footprint.y)
	
	var top = Vector2((gx - gy) * half_w, (gx + gy) * half_h)
	var right = Vector2(((gx + w) - gy) * half_w, ((gx + w) + gy) * half_h)
	var bottom = Vector2(((gx + w) - (gy + h)) * half_w, ((gx + w) + (gy + h)) * half_h)
	var left = Vector2((gx - (gy + h)) * half_w, (gx + (gy + h)) * half_h)
	
	return PackedVector2Array([top, right, bottom, left])

## Retorna o poligono local relativo ao pivô inferior (onde o vertice inferior eh (0, 0))
static func get_footprint_local_polygon(footprint: Vector2i, tile_size: Vector2 = Vector2(DEFAULT_TILE_WIDTH, DEFAULT_TILE_HEIGHT)) -> PackedVector2Array:
	var half_w = tile_size.x * 0.5
	var half_h = tile_size.y * 0.5
	var w = float(footprint.x)
	var h = float(footprint.y)
	
	var bottom = Vector2(0, 0)
	var right = Vector2(h * half_w, -h * half_h)
	var top = Vector2((h - w) * half_w, -(w + h) * half_h)
	var left = Vector2(-w * half_w, -w * half_h)
	
	return PackedVector2Array([bottom, right, top, left])

## Verifica se um ponto no mundo esta contido dentro do poligono do footprint
static func is_point_in_footprint(world_point: Vector2, grid_pos: Vector2i, footprint: Vector2i, tile_size: Vector2 = Vector2(DEFAULT_TILE_WIDTH, DEFAULT_TILE_HEIGHT)) -> bool:
	var poly = get_footprint_polygon(grid_pos, footprint, tile_size)
	return Geometry2D.is_point_in_polygon(world_point, poly)
