# Game Design — Regras e Experiência de Partida

> **Documento:** `docs/01-game-design/03-regras-de-partida.md`  
> **Status:** Game Design Document (GDD) / V1  
> **Escopo:** Ritmo de jogo, lances capitais, intervenções do treinador e eventos de partida  

---

## 1. A Filosofia da Partida no Open Football

Diferente de simuladores lentos com 10 minutos de espera ou de arcades de joystick, a partida no Open Football é inspirada no **ritmo ágil e viciante do Brasfoot**:

> **"Uma partida deve durar entre 10 e 15 segundos no tempo normal, oferecendo suspense em cada lance perigoso e controle tático rápido nas mãos do treinador."**

```
┌─────────────────────────────────────────────────────────────┐
│                    EXPERIÊNCIA DE PARTIDA                   │
│                                                             │
│   [ Apito Inicial ] ──► Cronômetro digital avança (0' a 90')│
│                                                             │
│   [ Ticks de Lance ]                                        │
│   • Posse de bola oscila no radar visual                    │
│   • Lances perigosos surgem no feed narrado                 │
│   • Gol marcado toca som comemorativo e destaca o placar    │
│                                                             │
│   [ Intervenção ]                                           │
│   • Treinador pode pausar aos 60' e mexer na tática/elenco  │
│                                                             │
│   [ Apito Final ] ──► Estatísticas completas e premiações   │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. A Linha do Tempo dos 90 Minutos

A partida ocorre em **30 blocos de 3 minutos**:
- **0' a 45' (Primeiro Tempo)**: 15 ticks de disputa.
- **Intervalo**: Pausa automática rápida de 1 segundo exibindo resumo parcial de posse e finalizações.
- **45' a 90' (Segundo Tempo)**: 15 ticks restantes com maior probabilidade de gols devido ao cansaço acumulado dos defensores.

---

## 3. Controles do Treinador Durante o Jogo

O jogador não assiste passivamente; ele possui ferramentas em tempo real:

1. **Pausar Partida (`ESPAÇO` ou Botão)**: Congela o relógio imediatamente para avaliar a situação.
2. **Alterar Mentalidade Instantaneamente**:
   - Sofreu gol e precisa empatar? Muda com um clique para **OFENSIVO**.
   - Está ganhando por 1 gol aos 80 minutos? Muda para **DEFENSIVO** para fechar os espaços.
3. **Substituições (Até 5 trocas em 3 paradas)**:
   - Trocar um atleta cansado ou com cartão amarelo para evitar expulsão.
4. **Velocidade de Playback**:
   - `1x` (Velocidade Normal: ~14 segundos).
   - `2x` (Velocidade Acelerada: ~7 segundos).
   - `Pular (Instantâneo)`: Calcula o restante do jogo em 1 milissegundo e vai direto ao placar final.

---

## 4. O Feed Narrativo de Lances

A narração em texto é colorida e dinâmica:
- 🟢 **Gols do Time do Jogador**: Texto em destaque verde com som festivo.
- 🔴 **Gols do Adversário**: Texto em destaque vermelho.
- 🟡 **Cartões e Faltas**: Destaque em amarelo com nome do infrator.
- ⚪ **Lances Normais**: Passes, escanteios e defesas simples.
