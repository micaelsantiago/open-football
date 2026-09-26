# Arquitetura — Visão Geral e Padrões de Projeto

> **Documento:** `docs/arquitetura/01-visao-geral-e-padroes.md`  
> **Status:** Especificação Técnica / V1  
> **Escopo:** Princípios de engenharia, padrões de projeto em Godot 4 e boas práticas de código  

---

## 1. Princípios Arquiteturais Centrais

O **Open Football** adota uma variação pragmática da **Arquitetura Hexagonal (Ports & Adapters)** adaptada para jogos na Godot 4.

```
				  ┌──────────────────────────────────────────────┐
				  │           CAMADA DE APRESENTAÇÃO             │
				  │   • Cenas da Godot (Control, Node2D)         │
				  │   • TileMapLayer do Mundo Isométrico         │
				  │   • HUD, Janelas de Gestão e Modais          │
				  └───────────────────────▲──────────────────────┘
										  │ [Chamadas de Métodos & Sinais]
										  ▼
				  ┌──────────────────────────────────────────────┐
				  │             CAMADA DE APLICAÇÃO              │
				  │   • GameManager (Orquestrador da Sessão)     │
				  │   • MatchRunner (Execução de Partidas)       │
				  │   • SaveService (Controle de Persistência)   │
				  │   • EventBus (Barramento Global de Sinais)   │
				  └───────────────────────▲──────────────────────┘
										  │ [Manipula instâncias puras]
										  ▼
				  ┌──────────────────────────────────────────────┐
				  │              CAMADA DE DOMÍNIO               │
				  │   • Club, Player, Facility, Competition      │
				  │   • MatchSimulation, Calendar, Standings     │
				  │   • 100% RefCounted (Zero dependência de nós)│
				  └──────────────────────────────────────────────┘
```

### Regras Invioláveis de Dependência
1. **O Domínio desconhece a Engine**: Nenhuma classe dentro de `src/core/` pode importar ou herdar de classes visuais da Godot (`Node`, `Node2D`, `Control`, `CanvasItem`, `Sprite2D`).
2. **Direção Única de Dependência**: A Apresentação depende da Aplicação; a Aplicação depende do Domínio. O Domínio **nunca** depende de ninguém acima dele.
3. **Imutabilidade de Comunicação Externa**: O Domínio não expõe referências mutáveis internas diretamente para a UI sem controle; dados são expostos através de métodos de consulta ou DTOs (dicionários e structs leves).

---

## 2. Injeção de Dependências vs Autoloads (Singletons)

Na Godot, o uso excessivo de *Autoloads* (Singletons globais) é a causa número um de código espaguete, testes impossíveis e acoplamento descontrolado.

### 2.1 Política Estrita de Autoloads
Apenas **4 Autoloads globais** são permitidos em todo o projeto:

| Autoload | Responsabilidade | O que NÃO deve fazer |
| :--- | :--- | :--- |
| `EventBus` | Barramento de eventos transversais desacoplados. | Não armazena estado de jogo ou lógica de negócios. |
| `GameManager` | Mantém a referência da sessão ativa (`GameState`). | Não desenha telas nem manipula nós diretamente. |
| `AudioService` | Toca efeitos sonoros e músicas globais. | Não decide regras de jogo; apenas responde a chamadas. |
| `ConfigService` | Carrega configurações de vídeo, áudio e idioma. | Não armazena dados de carreiras salvas. |

### 2.2 Injeção de Dependência Local (DI)
Em todos os outros cenários, as dependências devem ser passadas explicitamente pelo construtor (`_init`) ou por métodos de configuração (`setup`):

```gdscript
# CORRETO: Dependência injetada explicitamente
class_name MatchRunner
extends RefCounted

var _match_sim: MatchSimulation
var _event_bus: Object

func _init(match_sim: MatchSimulation, event_bus: Object) -> void:
	_match_sim = match_sim
	_event_bus = event_bus

# ERRADO: Dependência mágica acessada via singleton oculto
func play_match() -> void:
	GlobalData.current_match.simulate() # ACOPLAMENTO PERIGOSO!
```

---

## 3. Gestão de Memória: `RefCounted` vs `Node`

Para garantir alta performance, baixo consumo de RAM e ausência de *memory leaks*:

### 3.1 Quando usar `RefCounted` (Padrão para 90% do código)
- Entidades de dados (`PlayerData`, `ClubData`, `FacilityData`).
- Algoritmos matemáticos (`MatchSimulation`, `IsometricGridHelper`).
- Utilitários, calculadoras e DTOs.
- **Vantagem**: A memória é liberada automaticamente pela Godot assim que não houver mais variáveis apontando para a instância. Não exige `queue_free()`.

### 3.2 Quando usar `Node` / `Node2D` / `Control`
- Apenas e exclusivamente para elementos que **precisam ser desenhados na tela** ou **receber input do jogador**.
- Exemplos: `WorldCamera2D`, `BuildingVisualView`, `SquadManagementScreen`.
- **Atenção**: Sempre liberar nós removidos da árvore explicitamente com `queue_free()`.

### 3.3 Prevenção de Ciclos de Referência (*Reference Cycles*)
Se o Objeto A referencia o Objeto B e o Objeto B referencia o Objeto A, o `RefCounted` da Godot pode vazar memória.
- **Regra**: O relacionamento filho-para-pai deve ser feito por **ID em string** ou por `weakref()`.
- Exemplo: O `PlayerData` guarda `club_id: String = "club-aurora"`, e **nunca** uma referência direta ao objeto `ClubData` pai.

---

## 4. Guia de Convenções e Estilo de Código (GDScript)

### 4.1 Tipagem Estática Rigorosa
Todo o código deve ser 100% tipado estaticamente. Tipos implícitos (`Variant`) são expressamente proibidos, exceto para payloads genéricos de eventos.

```gdscript
# Correto
var player_name: String = "Silva"
var current_score: int = 0
var overall: float = 75.5

func calculate_wage(base_wage: int, bonus_percentage: float) -> int:
	return int(base_wage * (1.0 + bonus_percentage))

# Errado
var player_name = "Silva" # Sem tipo explícito
func calculate_wage(base, bonus): # Sem parâmetros ou retorno tipados
	return base * (1 + bonus)
```

### 4.2 Padrões de Nomenclatura
- **Arquivos e Pastas**: `snake_case.gd`, `match_simulation.gd`.
- **Classes**: `PascalCase` (`class_name MatchSimulation`).
- **Funções e Variáveis**: `snake_case` (`calculate_possession()`, `starting_eleven`).
- **Constantes e Enums**: `SCREAMING_SNAKE_CASE` (`const MAX_PLAYERS = 25`, `enum FormationType { F_442, F_433 }`).
- **Variáveis Privadas**: Devem ser prefixadas com underline (`var _cached_power: float = -1.0`, `func _recalculate_internal() -> void:`).

### 4.3 Tratamento de Erros e Defensividade
Funções que realizam I/O ou cálculos críticos devem retornar códigos `Error` ou estruturas de resultado (`ResultObject`):

```gdscript
# Padrão de retorno seguro
func load_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Arquivo não encontrado: " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Falha ao abrir arquivo com erro: %d" % FileAccess.get_open_error())
		return {}
	# ...
```

---

## 5. Estrutura de Camadas Físicas no Disco

Para refletir a arquitetura técnica sem ambiguidades:

```text
src/
├── core/             # DOMÍNIO PURO (RefCounted, zero nós)
│   ├── club/
│   ├── player/
│   ├── match/
│   ├── competition/
│   ├── facility/
│   └── calendar/
│
├── systems/          # SERVIÇOS & INFRAESTRUTURA
│   ├── event_bus/
│   ├── save_system/
│   ├── data_loader/
│   └── mod_system/
│
└── presentation/     # VIEW & APRESENTAÇÃO (Nós da Godot)
	├── world_2d/     # Mapa isométrico, prédios, câmera
	├── ui/           # Menus, HUD, painéis de gestão
	└── match_view/   # Visualização e narração de partida
```
