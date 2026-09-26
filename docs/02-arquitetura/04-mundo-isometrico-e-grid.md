# Arquitetura — Mundo Isométrico e Renderização

> **Documento:** `docs/arquitetura/04-mundo-isometrico-e-renderizacao.md`  
> **Status:** Especificação Técnica / V1  
> **Escopo:** Renderização 2D isométrica, TileMapLayer na Godot 4, profundidade Y-Sort e navegação  

---

## 1. Visão Geral do Mundo 2D

O mundo isométrico (`src/presentation/world_2d/`) é a representação visual da sede física do clube. Ele é responsável por:
1. Renderizar o terreno e a malha viária em projeção 2:1 ($64 \times 32\text{ px}$).
2. Posicionar estruturas multi-tile com profundidade ótica correta (*Y-Sort*).
3. Permitir que o jogador explore o espaço com câmera fluida (arrasto e zoom).
4. Detectar o mouse sobre prédios e disparar eventos de inspeção.

```
                              WorldView (Node2D)
                                      │
       ┌──────────────────────────────┼──────────────────────────────┐
       ▼                              ▼                              ▼
TileMapLayer (Chão)          EntitiesNode (Y-Sort)           WorldCamera2D
• Gramados                   • Estádio Multi-Tile (4x4)      • Pan com mouse
• Ruas de Asfalto            • Campo de Treino (3x3)         • Zoom suave
• Calçadas                   • Sede Administrativa (2x2)     • Limites de mapa
                             • Árvores e Elementos
```

---

## 2. Padrão de Camadas na Godot 4 (`TileMapLayer`)

Seguindo a especificação moderna da Godot 4.3+, a cena do mundo abandona o nó legado monolítico `TileMap` e implementa camadas separadas via **`TileMapLayer`**:

```text
res://src/presentation/world_2d/world_view.tscn
├── Layer_Terrain (TileMapLayer)
│   ├── tile_set = res://assets/world/tilesets/terrain_tileset.tres
│   └── y_sort_enabled = false
│
├── Layer_Roads (TileMapLayer)
│   ├── tile_set = res://assets/world/tilesets/roads_tileset.tres
│   └── y_sort_enabled = false
│
└── Layer_Entities (Node2D)
    ├── y_sort_enabled = true
    ├── StadiumBuilding (BuildingNode2D)
    ├── TrainingCenterBuilding (BuildingNode2D)
    └── HeadquartersBuilding (BuildingNode2D)
```

---

## 3. Estruturas Multi-Tile e Resolução de Profundidade (Y-Sort)

O maior desafio técnico em jogos isométricos com prédios grandes é garantir que o jogador, árvores ou carros passem na frente ou atrás de um prédio sem erros visuais de sobreposição (*z-fighting* ou camadas erradas).

### 3.1 Ponto de Origem e Pivô
Cada instalação é instanciada como uma cena derivada de `BuildingNode2D`. O ponto de origem local `(0, 0)` do nó é fixado **no vértice inferior da base de ocupação no solo**:

```text
                Vértice Superior
                      /\
                     /  \
                    /    \
     Vértice       /      \       Vértice
    Esquerdo      \        /      Direito
                   \      /
                    \    /
                     \  /
                      \/ ◄── PIVÔ LOCAL (0, 0)
                   Vértice
                   Inferior
```

### 3.2 Por que essa convenção é perfeita?
Na Godot, quando `y_sort_enabled = true` está ativo, a engine ordena a renderização com base no valor de `global_position.y` de cada nó. Como o pivô do prédio está na extremidade inferior da sua pegada no chão:
- Qualquer objeto cujo pé esteja em um `Y` menor (mais ao norte no mapa) será desenhado **atrás** do prédio.
- Qualquer objeto cujo pé esteja em um `Y` maior (mais ao sul no mapa) será desenhado **na frente** do prédio.

---

## 4. O Nó do Prédio: `BuildingNode2D`

Cada estrutura física no mapa possui um controlador visual que responde a dados do domínio:

```gdscript
class_name BuildingNode2D
extends Node2D

@export var facility_id: String = ""

@onready var sprite: Sprite2D = $Sprite2D
@onready var click_area: Area2D = $ClickArea
@onready var construction_overlay: Sprite2D = $ConstructionOverlay

var _is_hovered: bool = false
var _facility_data: FacilityData

func setup(facility: FacilityData) -> void:
    _facility_data = facility
    update_visuals()

func update_visuals() -> void:
    if not _facility_data:
        return
        
    # Atualiza sprite baseado no nível atual
    var current_lvl_data = _facility_data.levels[_facility_data.current_level - 1]
    var texture_path = current_lvl_data.get("visual", {}).get("texture_path", "")
    if ResourceLoader.exists(texture_path):
        sprite.texture = load(texture_path)
        
    # Exibe andaimes se estiver em obras
    construction_overlay.visible = _facility_data.is_under_construction

func _on_click_area_mouse_entered() -> void:
    _is_hovered = true
    # Aplica efeito sutil de brilho (outline shader ou modulate)
    sprite.modulate = Color(1.15, 1.15, 1.15, 1.0)
    Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_click_area_mouse_exited() -> void:
    _is_hovered = false
    sprite.modulate = Color.WHITE
    Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _unhandled_input(event: InputEvent) -> void:
    if _is_hovered and event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
            EventBus.facility_selected.emit(facility_id)
            get_viewport().set_input_as_handled()
```

---

## 5. Câmera Isométrica (`WorldCamera2D`)

A câmera permite uma exploração natural do clube. O script `src/presentation/world_2d/camera/world_camera_2d.gd` implementa:

```gdscript
class_name WorldCamera2D
extends Camera2D

@export var pan_speed: float = 600.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

var _is_panning: bool = false
var _target_zoom: float = 1.0

func _process(delta: float) -> void:
    # Movimentação contínua por teclado (WASD ou Setas)
    var move_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if move_dir != Vector2.ZERO:
        position += move_dir * (pan_speed / zoom.x) * delta
        
    # Interpolação suave de zoom
    zoom = zoom.move_toward(Vector2.ONE * _target_zoom, 5.0 * delta)

func _unhandled_input(event: InputEvent) -> void:
    # Pan via arrasto com botão direito do mouse
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
            _is_panning = event.is_pressed()
            
        elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
            _target_zoom = clampf(_target_zoom + zoom_speed, min_zoom, max_zoom)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _target_zoom = clampf(_target_zoom - zoom_speed, min_zoom, max_zoom)
            
    elif event is InputEventMouseMotion and _is_panning:
        position -= event.relative / zoom.x
```

---

## 6. O Teste de Ouro: Transição da Expansão do Estádio

Quando o jogador financia a reforma do estádio (Nível 1 ➔ Nível 2), o fluxo de apresentação ocorre em três tempos:

1. **Início da Obra**: O `BuildingNode2D` ativa o `ConstructionOverlay` (andaimes e caminhões de cimento sobrepostos ao estádio).
2. **Durante as Rodadas**: A cada avanço de rodada, o tooltip do prédio exibe: *"Em reforma: restam X rodadas"*.
3. **Conclusão**: O `BuildingNode2D` escuta o sinal `EventBus.facility_upgrade_completed`:
   - Desativa os andaimes.
   - Substitui a textura pela **Arena de Alvenaria Nível 2**.
   - Spawna um emissor de partículas de confete temporário (`CPUParticles2D`) por 3 segundos.
   - Dispara o som festivo de obra concluída via `AudioService`.
