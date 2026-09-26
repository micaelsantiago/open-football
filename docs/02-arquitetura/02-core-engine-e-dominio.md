# Arquitetura — Core Engine e Modelagem de Domínio

> **Documento:** `docs/arquitetura/02-core-engine-e-dominio.md`  
> **Status:** Especificação Técnica / V1  
> **Escopo:** Entidades de domínio, ciclo de vida do estado de jogo e regras de negócio puras  

---

## 1. Visão Geral do Domínio

A camada de domínio (`src/core/`) é o coração computacional do Open Football. Ela é **completamente autônoma**, agnóstica a gráficos e capaz de simular temporadas inteiras de forma puramente lógica.

```
						 GameState
			(Single Source of Truth da Carreira)
							 │
	   ┌─────────────┬───────┴───────┬─────────────┐
	   ▼             ▼               ▼             ▼
  ClubsRegistry  PlayersPool   Competitions   CalendarService
  (ClubData)     (PlayerData)  (Competition)  (Datas & Rodadas)
	   │             │               │
	   └─────────────┼───────────────┘
					 ▼
			  MatchSimulation
		 (Algoritmo de Resolução)
```

---

## 2. Entidades Canônicas de Domínio

Todas as classes estendem `RefCounted` e vivem em `src/core/`.

### 2.1 `PlayerData` (`src/core/player/player_data.gd`)
Responsável por encapsular atributos, forma física, moral e contrato do atleta.

```gdscript
class_name PlayerData
extends RefCounted

var id: String = ""
var full_name: String = ""
var common_name: String = ""
var birth_year: int = 2005
var nationality: String = "BR"
var preferred_foot: String = "R" # "L", "R", "Both"
var primary_position: String = "ST"
var secondary_positions: Array[String] = []

# Atributos (1 a 99)
var attributes: Dictionary = {
	"finishing": 50, "passing": 50, "tackling": 50,
	"pace": 50, "stamina": 50, "strength": 50,
	"positioning": 50, "vision": 50, "reflexes": 10
}

var potential_min: int = 65
var potential_max: int = 75
var club_id: String = "free_agent"
var wage_per_round: int = 1000
var contract_rounds_left: int = 28

# Condição dinâmica
var condition: float = 100.0   # 0.0 a 100.0
var morale: float = 80.0       # 0.0 a 100.0
var injury_rounds_left: int = 0
var yellow_cards: int = 0
var is_suspended: bool = false

func is_available() -> bool:
	return injury_rounds_left == 0 and not is_suspended

func calculate_effective_power(sector: String) -> float:
	# Retorna o poder do jogador considerando atributos, moral e cansaço
	var base_score: float = 0.0
	match sector:
		"ATK":
			base_score = (attributes["finishing"] * 0.5) + (attributes["pace"] * 0.3) + (attributes["positioning"] * 0.2)
		"MID":
			base_score = (attributes["passing"] * 0.4) + (attributes["vision"] * 0.3) + (attributes["stamina"] * 0.3)
		"DEF":
			base_score = (attributes["tackling"] * 0.5) + (attributes["positioning"] * 0.3) + (attributes["strength"] * 0.2)
		"GK":
			base_score = (attributes["reflexes"] * 0.6) + (attributes["positioning"] * 0.4)
			
	var condition_factor: float = clampf(condition / 100.0, 0.6, 1.0)
	var morale_factor: float = 0.9 + (morale / 100.0) * 0.2 # 0.9 a 1.1
	return base_score * condition_factor * morale_factor
```

### 2.2 `ClubData` (`src/core/club/club_data.gd`)
Encapsula patrimônio financeiro, elenco, cores e instalações.

```gdscript
class_name ClubData
extends RefCounted

var id: String = ""
var name: String = ""
var short_name: String = ""
var reputation: int = 50 # 1 a 100
var primary_color: Color = Color.BLUE
var secondary_color: Color = Color.WHITE

# Finanças
var balance: int = 100000
var ticket_price: int = 20
var weekly_sponsor: int = 5000

# IDs de Instalações associadas
var stadium_id: String = ""
var training_center_id: String = ""
var headquarters_id: String = ""

# Elenco
var squad_player_ids: Array[String] = []
var lineup_starter_ids: Array[String] = []
var lineup_substitute_ids: Array[String] = []
var tactical_mentality: String = "BALANCED" # "DEFENSIVE", "BALANCED", "OFFENSIVE"

func calculate_wage_bill() -> int:
	# A ser somado consultando o pool de jogadores do GameState
	return 0

func can_afford(amount: int) -> bool:
	return balance >= amount

func debit(amount: int) -> bool:
	if not can_afford(amount):
		return false
	balance -= amount
	return true

func credit(amount: int) -> void:
	balance += amount
```

### 2.3 `FacilityData` (`src/core/facility/facility_data.gd`)
Representa uma estrutura construída que existe no mundo do clube e pode ser aprimorada.

```gdscript
class_name FacilityData
extends RefCounted

var id: String = ""
var club_id: String = ""
var type: String = "STADIUM" # STADIUM, TRAINING_CENTER, HEADQUARTERS
var grid_x: int = 0
var grid_y: int = 0
var current_level: int = 1
var is_under_construction: bool = false
var construction_rounds_left: int = 0

# Configuração dos níveis
var levels: Array[Dictionary] = [] # [ { level, name, capacity, upgrade_cost, visual_key } ]

func get_current_capacity() -> int:
	if type != "STADIUM" or levels.is_empty():
		return 0
	var lvl_data = levels[current_level - 1]
	var cap = lvl_data.get("capacity", 1000)
	# Durante obras, a capacidade cai temporariamente em 25%
	if is_under_construction:
		return int(cap * 0.75)
	return cap
```

---

## 3. O Container Central: `GameState`

O `GameState` é a **fonte única da verdade** de uma carreira em andamento. Qualquer dado que precise persistir entre saves reside dentro deste container.

```gdscript
class_name GameState
extends RefCounted

# Metadados
var save_version: int = 1
var career_name: String = ""
var user_club_id: String = "club-aurora-fc"

# Registros Relacionais (Chave: ID em String -> Instância RefCounted)
var clubs: Dictionary = {}         # id -> ClubData
var players: Dictionary = {}       # id -> PlayerData
var facilities: Dictionary = {}    # id -> FacilityData
var competitions: Dictionary = {}  # id -> CompetitionData

# Calendário e Tempo
var current_round: int = 1
var total_rounds: int = 14
var current_season: int = 2026

# Semente Mestre de RNG
var master_seed: int = 0
var rng: RandomNumberGenerator

func _init(seed_val: int = 0) -> void:
	master_seed = seed_val if seed_val != 0 else int(Time.get_unix_time_from_system())
	rng = RandomNumberGenerator.new()
	rng.seed = master_seed

func get_player(id: String) -> PlayerData:
	return players.get(id, null)

func get_club(id: String) -> ClubData:
	return clubs.get(id, null)

func get_user_club() -> ClubData:
	return get_club(user_club_id)
```

---

## 4. Máquina de Estados Temporal (Ciclo de Rodadas)

O jogo progride através de um ciclo rígido de estados coordenado pelo `SeasonController`:

```
┌─────────────────────────────────────────────────────────────┐
│                    CICLO DA RODADA                          │
│                                                             │
│   1. PRE_MATCH (Gestão Livre)                               │
│      • Jogador mexe no elenco, tática, ingressos e obras    │
│      • Nenhum cálculo de partida ocorre                     │
│               │                                             │
│               │ [Jogador clica em "Jogar Rodada"]           │
│               ▼                                             │
│   2. MATCH_EXECUTION (Simulação)                            │
│      • Simula a partida do jogador (emissão de eventos)     │
│      • Simula partidas simultâneas da IA (instantâneo)      │
│               │                                             │
│               │ [Fim dos 90 minutos de todos os jogos]      │
│               ▼                                             │
│   3. POST_MATCH_FINANCES (Contabilidade)                    │
│      • Credita bilheteria dos mandantes                     │
│      • Debita salários semanais de todos os clubes          │
│      • Atualiza tabela de classificação (Standings)         │
│               │                                             │
│               ▼                                             │
│   4. FACILITY_TICK (Avanço de Obras)                        │
│      • Reduz 1 rodada das reformas ativas                   │
│      • Conclui obras que chegaram a 0 rodadas restantes     │
│               │                                             │
│               ▼                                             │
│   5. RECOVERY_AND_TRAINING (Recuperação Física)             │
│      • Recupera estamina dos atletas (+15% a +25%)          │
│      • Reduz rodadas de lesão (-1)                          │
│      • current_round += 1                                   │
│      • Retorna para o estado 1 (PRE_MATCH)                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Determinismo e Sementes Derivadas

Para garantir que uma mesma partida seja reprodutível sem que uma rolagem de dado de um jogo afete o resultado do jogo vizinho:

### Sementes Derivadas por Partida
Cada partida recebe uma sub-semente única gerada a partir da semente mestre combinada com o ID da partida:

```gdscript
func create_match_rng(fixture_id: String, round_num: int) -> RandomNumberGenerator:
	var match_rng := RandomNumberGenerator.new()
	# Combina hash da string com a semente global da carreira
	var derived_seed = (master_seed + fixture_id.hash() + round_num * 10007) & 0x7FFFFFFF
	match_rng.seed = derived_seed
	return match_rng
```

Com essa técnica:
- O resultado de *Aurora vs União* será **100% idêntico** mesmo se o jogador recarregar o jogo, desde que a escalação e a semente sejam as mesmas.
- Evita o exploit de *Save Scumming* trivial (salvar antes da partida para tentar resultados diferentes aleatórios).
