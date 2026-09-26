# Arquitetura — Sistema de Partidas e Eventos

> **Documento:** `docs/arquitetura/05-sistema-de-partidas-e-eventos.md`  
> **Status:** Especificação Técnica / V1  
> **Escopo:** Orquestração de partidas, modos de execução (instantâneo vs interativo) e pipeline de eventos  

---

## 1. Visão Geral da Arquitetura de Partida

O sistema de partidas é dividido estritamente em dois subsistemas:

1. **`MatchSimulation` (Cálculo Puro / Domínio)**:
   - Classe `RefCounted` que executa a matemática probabilística e gera uma sequência cronológica de eventos imutáveis.
2. **`MatchRunner` & `MatchView` (Apresentação / Aplicação)**:
   - O orquestrador que consome a sequência de eventos, controla a velocidade de reprodução (1x, 2x, Pausa) e atualiza a interface visual em tempo real.

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUXO DA PARTIDA                         │
│                                                             │
│   [ Setup ] ──► Injeta Titulares, Táticas e RNG Seed        │
│                    │                                        │
│                    ▼                                        │
│   [ MatchSimulation ] (Executa os 30 ticks de 3')          │
│                    │                                        │
│                    ▼                                        │
│   [ Fila de Eventos (Event Stream) ]                        │
│   [ Lance 12', Lance 23' GOL, Lance 41', Lance 68' GOL... ] │
│                    │                                        │
│        ┌───────────┴───────────┐                            │
│        ▼                       ▼                            │
│   MODO INSTANTÂNEO        MODO INTERATIVO                   │
│   (Partidas da IA)        (Partida do Jogador)              │
│   • Roda em < 1 ms        • Reproduz com delay suave        │
│   • Retorna MatchResult   • Atualiza cronômetro e narração  │
│   • Sem interface gráfica • Permite pausar e substituir     │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Os Dois Modos de Execução

Em uma rodada padrão de 8 clubes, ocorrem 4 confrontos simultâneos:
- **1 jogo** envolve o clube do jogador.
- **3 jogos** ocorrem entre clubes controlados pela IA.

### 2.1 Modo Instantâneo (Headless)
Utilizado para os jogos da IA ou quando o jogador clica em *"Pular para o Final"*:
- A função `run_full_match()` executa todos os 30 ticks em um loop único.
- Não há `await`, *timers* ou chamadas de renderização.
- O resultado completo e as estatísticas são gerados instantaneamente.

### 2.2 Modo Interativo (Playback com Velocidade Variável)
Utilizado na tela de acompanhamento ao vivo do jogador:
- O `MatchRunner` recebe a fila de eventos e os despacha para a UI usando um timer escalonável:
  - **Velocidade $1\times$ (Normal):** Cada minuto de jogo dura $0.15\text{ s}$ (partida dura $\sim 13.5\text{ s}$).
  - **Velocidade $2\times$ (Rápida):** Cada minuto dura $0.075\text{ s}$ (partida dura $\sim 6.7\text{ s}$).
  - **Pausa:** O tempo congela, permitindo que o jogador analise estatísticas ou realize uma substituição tática.

---

## 3. Tipologia de Eventos de Partida (`MatchEvent`)

Cada lance relevante gera um dicionário padronizado:

```gdscript
class_name MatchEvent
extends RefCounted

enum Type {
    KICKOFF,
    POSSESSION_TICK,
    ATTACK_OPPORTUNITY,
    GOAL,
    SAVE_CORNER,
    SAVE_HELD,
    WOODWORK,
    FOUL,
    YELLOW_CARD,
    RED_CARD,
    INJURY,
    SUBSTITUTION,
    FULL_TIME
}
```

### 3.1 Exemplo de Payload de Evento de Gol
```json
{
  "minute": 54,
  "type": "GOAL",
  "team": "HOME",
  "club_id": "club-aurora-fc",
  "player_id": "player-joao-silva-01",
  "player_name": "João Silva",
  "assistant_name": "Lucas",
  "home_score": 1,
  "away_score": 0,
  "description": "54' GOOOOOL DO AURORA! João Silva recebe na cara do gol e estufa a rede adversária!"
}
```

---

## 4. Arquitetura da Tela de Jogo (`MatchView`)

A tela de partida vive em `src/presentation/match_view/match_view.tscn` e adota a estética clássica e ágil do **Brasfoot**:

```text
┌─────────────────────────────────────────────────────────────┐
│ AURORA FC  [ 2 ]  x  [ 1 ]  UNIÃO FC            Tempo: 74'  │
├─────────────────────────────────────────────────────────────┤
│ Posse de Bola:                                              │
│ [████████████████████░░░░░░░░░░░░░░] 60% vs 40%             │
│ Finalizações: 8 (5 no gol)    Finalizações: 4 (2 no gol)    │
├─────────────────────────────────────────────────────────────┤
│ NARRAÇÃO AO VIVO (FEED):                                    │
│ • 14' Chute perigoso de fora da área para o União FC!       │
│ • 32' GOOOOL! Carlos abre o placar de cabeça para o Aurora! │
│ • 58' Cartão amarelo para o zagueiro do União por falta.   │
│ • 74' GOOOOL! União empata em contra-ataque rápido!        │
├─────────────────────────────────────────────────────────────┤
│ [ ⏸️ Pausar ]  [ ⏩ 1x / 2x ]  [ 🔄 Substituir ]  [ ⏭️ Pular ] │
└─────────────────────────────────────────────────────────────┘
```

### 4.1 Reação a Mudanças Táticas do Jogador Durante o Jogo
Se o jogador pausar aos 60 minutos e trocar para a postura **OFFENSIVE**:
1. O `MatchRunner` atualiza os multiplicadores de força de setor em tempo real:
   - `ATK_POWER` recebe $+15\%$.
   - `DEF_POWER` sofre $-15\%$.
2. Os ticks restantes (minutos 61 a 90) passam a rodar sob a nova configuração tática imediatamente.
