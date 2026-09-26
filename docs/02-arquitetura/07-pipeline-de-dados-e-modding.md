# Arquitetura — Pipeline de Dados e Modding

> **Documento:** `docs/arquitetura/07-pipeline-de-dados-e-modding.md`  
> **Status:** Especificação Técnica / V1  
> **Escopo:** Carregamento de dados, sistema de arquivos em camadas, sobreposição de mods e sanitização  

---

## 1. Visão Geral do Sistema de Conteúdo

O Open Football adota o padrão de **Sistema de Arquivos Virtual em Camadas** (*Layered Virtual Content System*), garantindo que a engine nunca dependa de dados proprietários compilados.

```
                      ORDEM DE PRECEDÊNCIA DE CARGA
                      
   [ Prioridade 1: Mods Ativos ]  (user://mods/meu_mod_preferido/)
                 │  (Sobrescreve se houver conflito de ID)
                 ▼
   [ Prioridade 0: Base Nativa ]   (res://data/)
                 │
                 ▼
          [ DataLoader ]
                 │  (Parser, Sanitização e Clamping)
                 ▼
   [ Registros Globais em Memória (GameState) ]
```

---

## 2. O Ciclo de Descoberta e Montagem de Mods

Ao iniciar o jogo, o subsistema `src/systems/modding/mod_manager.gd` executa:

1. **Varredura de Manifestos**:
   - Varre as subpastas de `user://mods/` buscando arquivos `mod.json`.
   - Se o manifesto for válido e a versão da engine compatível, adiciona à lista de mods disponíveis.
2. **Ordenação por Prioridade**:
   - Mods com maior valor no campo `"priority"` são processados por último, sobrescrevendo os dados de mods anteriores e da base padrão.
3. **Fusão em Camadas (Deep Merge)**:
   - Se o mod adicionar um clube novo (`club-flamengo`), ele é inserido no registro.
   - Se o mod definir um clube já existente (`club-aurora-fc`), ele substitui os atributos fornecidos sem corromper outros clubes.

---

## 3. Validação e Sanitização Defensiva

Mods criados pela comunidade podem conter erros de digitação, valores exagerados ou arquivos incompletos. A engine adota uma postura **defensiva e auto-corretiva**:

```gdscript
class_name DataSanitizer
extends RefCounted

static func sanitize_player_data(raw_dict: Dictionary) -> Dictionary:
    var clean := raw_dict.duplicate(true)
    
    # 1. Garante ID válido
    if not clean.has("id") or str(clean["id"]).strip_edges().is_empty():
        clean["id"] = "player-fallback-" + str(Time.get_ticks_usec())
        push_warning("Jogador sem ID encontrado! Gerado ID automático: %s" % clean["id"])
        
    # 2. Clamping universal de atributos (1 a 99)
    if clean.has("attributes"):
        for category in clean["attributes"]:
            for attr_name in clean["attributes"][category]:
                var val: int = int(clean["attributes"][category][attr_name])
                clean["attributes"][category][attr_name] = clampi(val, 1, 99)
                
    # 3. Posição padrão
    if not clean.has("positions") or not clean["positions"].has("primary"):
        clean["positions"] = { "primary": "CM", "secondary": [] }
        
    return clean
```

### 3.1 Resolução de Integridade Referencial Quebrada
- **Jogador associado a um clube inexistente**: É convertido automaticamente em `free_agent` (agente livre contratável).
- **Clube associado a um estádio inexistente**: Recebe um estádio genérico padrão nível 1 com 3.000 lugares.
- **Competição referenciando clube ausente**: O clube ausente é substituído por um time fictício genérico para manter a paridade da tabela.

---

## 4. Substituição de Assets Gráficos

Mods podem substituir não apenas dados em JSON, mas também texturas em pixel art:

```text
user://mods/retro_pixel_pack/
├── mod.json
└── assets/
    └── world/
        └── buildings/
            └── stadium_lvl1.png   # Substitui o sprite oficial do estádio!
```

O `DataLoader` intercepta requisições de texturas: se existir o arquivo correspondente na pasta do mod ativo, ele carrega o asset customizado em vez do asset padrão de `res://`.
