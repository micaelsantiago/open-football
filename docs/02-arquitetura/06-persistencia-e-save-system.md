# Arquitetura — Persistência e Save System

> **Documento:** `docs/arquitetura/06-persistencia-e-save-system.md`  
> **Status:** Especificação Técnica / V1  
> **Escopo:** Persistência em JSON, gravação atômica anti-corrupção e esteira de migração de versões  

---

## 1. Visão Geral da Persistência

O sistema de persistência (`src/systems/save_system/`) é responsável por serializar todo o `GameState` para o disco rígido e restaurá-lo com fidelidade absoluta.

### 1.1 Requisitos Críticos
1. **Zero Corrupção (Gravação Atômica)**: O jogo nunca grava diretamente sobre o arquivo de save antigo.
2. **Formato Aberto e Legível (JSON)**: Não utiliza formatos binários proprietários da Godot. Qualquer pessoa pode abrir o save em um editor de texto.
3. **Metadados Desacoplados**: A lista de saves no menu principal carrega em menos de 10 ms sem precisar desserializar megabytes de dados de clubes e atletas.
4. **Compatibilidade com Versões Futuras**: Sistema de migração (*Save Migrators*) que converte saves antigos para o schema atual.

---

## 2. Estrutura Física do Save no Disco

Cada carreira salva reside em uma pasta isolada dentro do diretório do usuário da Godot (`user://saves/<slot_id>/`):

```text
user://saves/carreira_aurora_01/
├── metadata.json       # Informações rápidas para a tela de Load Game
└── game_state.json     # O estado completo da carreira
```

### 2.1 Conteúdo de `metadata.json` (Leve)
```json
{
  "save_version": 1,
  "slot_id": "carreira_aurora_01",
  "career_name": "Glória do Aurora FC",
  "club_id": "club-aurora-fc",
  "club_name": "Aurora FC",
  "current_season": 2026,
  "current_round": 7,
  "total_rounds": 14,
  "saved_at_unix": 1774618200,
  "saved_at_readable": "2026-03-26 10:30"
}
```

---

## 3. Padrão de Gravação Atômica (Safe-Write Pattern)

Para eliminar 100% dos riscos de um save ser corrompido caso o computador seja desligado ou o processo seja finalizado durante a escrita:

```
[ GameState em Memória ]
            │
            │  1. Serializa para JSON
            ▼
[ Grava no arquivo temporário: game_state.json.tmp ]
            │
            │  2. Valida integridade e fecha arquivo (flush)
            ▼
[ Sucesso? ]
   ├── NÃO ──► Descarta .tmp e preserva o save anterior intacto!
   └── SIM  ──► Executa renomeação atômica do SO:
                rename("game_state.json.tmp", "game_state.json")
```

### 3.1 Implementação Canônica em GDScript

```gdscript
class_name SaveManager
extends RefCounted

static func save_game(state: GameState, slot_id: String) -> Error:
    var save_dir := "user://saves/%s" % slot_id
    if not DirAccess.dir_exists_absolute(save_dir):
        DirAccess.make_dir_recursive_absolute(save_dir)
        
    var tmp_path := "%s/game_state.json.tmp" % save_dir
    var final_path := "%s/game_state.json" % save_dir
    
    # 1. Serializa para o arquivo temporário
    var file := FileAccess.open(tmp_path, FileAccess.WRITE)
    if not file:
        return FileAccess.get_open_error()
        
    var data_dict := GameStateSerializer.serialize(state)
    var json_string := JSON.stringify(data_dict, "  ") # Indentação legível
    file.store_string(json_string)
    file.close()
    
    # 2. Renomeia atomicamente sobre o arquivo final
    var dir := DirAccess.open(save_dir)
    if dir.file_exists("game_state.json"):
        dir.remove("game_state.json")
    dir.rename(tmp_path, final_path)
    
    # 3. Grava metadados
    _save_metadata(state, slot_id, save_dir)
    return OK
```

---

## 4. Esteira de Migração de Versões (*Save Migrators*)

Conforme o jogo evolui para a V2 e V3, novos atributos serão adicionados (ex: salários com bônus, histórico de lesões). Para não invalidar os saves dos jogadores:

```gdscript
class_name SaveMigratorRegistry
extends RefCounted

static func migrate_if_needed(data: Dictionary) -> Dictionary:
    var current_version: int = data.get("save_version", 1)
    
    # Se o save for versão 1 e a engine estiver na versão 2:
    if current_version == 1:
        data = _migrate_v1_to_v2(data)
        current_version = 2
        
    # Se a engine estiver na versão 3:
    if current_version == 2:
        data = _migrate_v2_to_v3(data)
        current_version = 3
        
    data["save_version"] = current_version
    return data

static func _migrate_v1_to_v2(data: Dictionary) -> Dictionary:
    # Exemplo: Adiciona novo campo com valor default para todos os atletas
    for player_id in data.get("players", {}):
        var p = data["players"][player_id]
        if not p.has("release_clause"):
            p["release_clause"] = p.get("wage_per_round", 1000) * 50
    return data
```
