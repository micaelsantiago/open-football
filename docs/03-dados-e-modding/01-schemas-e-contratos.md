# Dados e Modding — Schemas e Contratos JSON

> **Documento:** `docs/03-dados-e-modding/01-schemas-e-contratos.md`  
> **Status:** Especificação Técnica / V1  
> **Escopo:** Schemas JSON formais para Atletas, Clubes, Instalações Físicas e Competições  

---

## 1. Princípios Gerais de Dados

O Open Football é **100% data-driven**. Nenhum clube, atleta ou instalação pode ser inserido hardcoded no código. 

### 1.1 Regras de Padronização
- **Formato:** JSON em UTF-8 estrito com indentação de 2 espaços.
- **Identificadores Únicos (`id`):** Strings em formato `kebab-case` prefixadas pela categoria:
  - Atletas: `player-<slug>`
  - Clubes: `club-<slug>`
  - Instalações: `facility-<slug>`
  - Competições: `comp-<slug>`
- **Escala de Atributos:** Inteiros estritamente entre **1 e 99**.
- **Reputação de Clubes:** Inteiros de **1 a 100**.

---

## 2. Schema do Manifesto do Mod (`mod.json`)

Toda pasta de mod ou pacote de dados nativo contém este cabeçalho na raiz:

```json
{
  "id": "mod-base-v1",
  "name": "Base Universe V1",
  "version": "1.0.0",
  "author": "Open Football Team",
  "description": "Banco de dados oficial da versão V1 com 8 clubes fictícios.",
  "target_engine_version": "0.1.0",
  "dependencies": [],
  "priority": 0,
  "contents": {
    "clubs": true,
    "players": true,
    "competitions": true,
    "facilities": true,
    "assets": true
  }
}
```

---

## 3. Schema do Atleta (`player.json`)

```json
{
  "id": "player-joao-silva-01",
  "name": "João Silva",
  "common_name": "Silva",
  "birth_year": 2007,
  "nationality": "BR",
  "preferred_foot": "R",
  "positions": {
    "primary": "ST",
    "secondary": ["LW", "RW"]
  },
  "attributes": {
    "technical": {
      "finishing": 75,
      "passing": 62,
      "dribbling": 70,
      "crossing": 50,
      "tackling": 25,
      "heading": 68
    },
    "physical": {
      "pace": 80,
      "acceleration": 78,
      "stamina": 72,
      "strength": 64
    },
    "mental": {
      "positioning": 74,
      "vision": 60,
      "composure": 66,
      "work_rate": 82
    },
    "goalkeeping": {
      "reflexes": 10,
      "handling": 10,
      "aerial": 10
    }
  },
  "potential": {
    "min": 79,
    "max": 88
  },
  "contract": {
    "club_id": "club-aurora-fc",
    "wage_per_round": 1800,
    "rounds_remaining": 28,
    "release_clause": 600000
  },
  "status": {
    "condition": 100,
    "morale": 85,
    "injured_rounds_remaining": 0,
    "yellow_cards": 0,
    "is_suspended": false
  }
}
```

---

## 4. Schema do Clube (`club.json`)

```json
{
  "id": "club-aurora-fc",
  "name": "Futebol Clube Aurora",
  "short_name": "Aurora",
  "nickname": "O Alvinegro da Serra",
  "founded_year": 1924,
  "country": "BR",
  "city": "Serra Alta",
  "reputation": 45,
  "colors": {
    "primary": "#1A4B8C",
    "secondary": "#FFFFFF",
    "accent": "#F2B705"
  },
  "facilities": {
    "stadium_id": "facility-estadio-aurora",
    "training_center_id": "facility-ct-aurora",
    "headquarters_id": "facility-sede-aurora"
  },
  "finances": {
    "balance": 250000,
    "ticket_price": 20,
    "season_tickets": 1200,
    "weekly_sponsor": 8000
  },
  "squad": [
    "player-joao-silva-01"
  ],
  "tactics_preset": {
    "formation": "4-4-2",
    "mentality": "BALANCED",
    "aggression": "NORMAL",
    "starting_eleven": ["player-joao-silva-01"],
    "substitutes": []
  }
}
```

---

## 5. Schema da Instalação (`facility.json`)

```json
{
  "id": "facility-estadio-aurora",
  "club_id": "club-aurora-fc",
  "type": "STADIUM",
  "name": "Estádio das Colinas",
  "world_position": {
    "grid_x": 12,
    "grid_y": 8
  },
  "current_level": 1,
  "levels": [
    {
      "level": 1,
      "name": "Estádio Comunitário",
      "capacity": 3000,
      "maintenance_cost_per_round": 1200,
      "upgrade_cost": 0,
      "construction_time_rounds": 0,
      "visual": {
        "footprint_width": 4,
        "footprint_height": 4,
        "texture_path": "assets/world/buildings/stadium_lvl1.png"
      }
    },
    {
      "level": 2,
      "name": "Arena Regional de Alvenaria",
      "capacity": 8500,
      "maintenance_cost_per_round": 3500,
      "upgrade_cost": 150000,
      "construction_time_rounds": 4,
      "visual": {
        "footprint_width": 4,
        "footprint_height": 4,
        "texture_path": "assets/world/buildings/stadium_lvl2.png"
      }
    }
  ],
  "construction_state": {
    "is_under_construction": false,
    "target_level": 1,
    "rounds_remaining": 0
  }
}
```
