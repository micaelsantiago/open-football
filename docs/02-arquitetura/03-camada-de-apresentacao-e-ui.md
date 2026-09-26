# Arquitetura — Camada de Apresentação e UI

> **Documento:** `docs/arquitetura/03-camada-de-apresentacao-e-ui.md`  
> **Status:** Especificação Técnica / V1  
> **Escopo:** Interface de usuário, padrão Model-View-Presenter, barramento de eventos e componentes modulares  

---

## 1. Visão Geral da Apresentação

A camada de apresentação (`src/presentation/`) é responsável por traduzir os dados abstratos da simulação em elementos interativos táteis na tela da Godot.

Para evitar que scripts de telas acumulem regras financeiras ou cálculos de atributos, a UI adota o padrão **Model-View-Presenter (MVP)**.

```
┌─────────────────────────────────────────────────────────────┐
│                    PADRÃO MVP NA GODOT                      │
│                                                             │
│   [ VIEW ] (Cena .tscn com nós Control)                    │
│   • Apenas sabe desenhar botões, labels e capturar cliques  │
│   • Não calcula finanças nem escala jogadores               │
│               ▲                                             │
│               │ Notifica cliques / Recebe dados formatados  │
│               ▼                                             │
│   [ PRESENTER ] (Script GDScript da cena)                   │
│   • Intermediário inteligente                               │
│   • Lê dados do Core, formata em texto e manda a View exibir│
│   • Conecta ao EventBus para atualizar em tempo real        │
│               ▲                                             │
│               │ Consulta e executa comandos                 │
│               ▼                                             │
│   [ MODEL / CORE ] (ClubData, PlayerData, GameState)        │
│   • A verdade do jogo (RefCounted puro)                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. O Barramento Global de Eventos (`EventBus`)

O `EventBus` é um dos raros **Autoloads** permitidos no projeto. Ele atua como uma central telefônica desacoplada, permitindo que qualquer sistema notifique acontecimentos sem saber quem está escutando.

### 2.1 Especificação de Sinais (`src/systems/event_bus/event_bus.gd`)

```gdscript
class_name EventBusSingleton
extends Node

# --- Eventos de Economia e Finanças ---
signal balance_changed(new_balance: int, delta: int)
signal wage_paid(total_wages: int)

# --- Eventos de Instalações / Mundo ---
signal facility_selected(facility_id: String)
signal facility_upgrade_started(facility_id: String, target_level: int)
signal facility_upgrade_completed(facility_id: String, new_level: int)

# --- Eventos da Partida ---
signal match_tick_advanced(minute: int)
signal match_goal_scored(goal_event: Dictionary)
signal match_card_shown(card_event: Dictionary)
signal match_ended(result: Dictionary)

# --- Eventos de Calendário e Temporada ---
signal round_started(round_number: int)
signal round_ended(round_number: int)
signal season_ended(champion_club_id: String)

# --- Eventos de UI e Notificações ---
signal toast_requested(message: String, type: String) # "INFO", "SUCCESS", "WARNING", "ERROR"
signal modal_opened(modal_name: String)
signal modal_closed(modal_name: String)
```

### 2.2 Exemplo de Uso Desacoplado
Quando uma obra de estádio termina, a lógica do Core emite:
```gdscript
EventBus.facility_upgrade_completed.emit("facility-estadio-aurora", 2)
```

Dois sistemas independentes reagem simultaneamente:
1. O **Mundo Isométrico** troca o sprite do estádio por um modelo maior.
2. O **HUD de UI** exibe uma notificação comemorativa (*toast*) no canto da tela: *"Obras concluídas! O Estádio das Colinas agora comporta 8.500 torcedores."*

Nenhum dos dois sistemas precisou se conhecer diretamente.

---

## 3. Design System e Componentes Modulares de UI

Para manter a consistência visual em todo o jogo, as telas não são desenhadas do zero. Elas utilizam uma biblioteca de componentes reutilizáveis localizada em `src/presentation/ui/common/`.

### 3.1 Biblioteca de Componentes Base
1. **`DataTable` (`data_table.tscn`)**:
   - Tabela parametrizável para listas com cabeçalhos ordenáveis (usada na Tabela de Classificação, Lista de Elenco e Histórico Financeiro).
2. **`PlayerCard` (`player_card.tscn`)**:
   - Cartão compacto exibindo nome, posição, idade, overall e barra de estamina.
3. **`MetricBadge` (`metric_badge.tscn`)**:
   - Etiqueta com ícone e valor (Saldo monetário, Capacidade de público, Reputação).
4. **`ActionModal` (`action_modal.tscn`)**:
   - Janela flutuante modal com botão de fechar, título, área de conteúdo dinâmico e botões de ação primária/secundária.
5. **`ToastContainer` (`toast_container.tscn`)**:
   - Fila vertical no canto superior direito que exibe balões de aviso que desaparecem após 3 segundos.

---

## 4. Gerenciamento de Janelas e Modais (Window Stack)

O jogo possui uma estrutura em camadas para que menus não se sobreponham desordenadamente:

```text
CanvasLayer (Layer = 10)
│
├── TopBarHUD (Sempre Visível)
│   • Nome do Clube, Saldo Atual, Data da Rodada, Botão "Avançar"
│
├── MainScreenContainer (Substituição de Tela Principal)
│   • Ou exibe o Mundo Isométrico (Visão Padrão)
│   • Ou exibe a Tela de Partida Ao Vivo (Modo Dia de Jogo)
│
├── ModalLayer (Janelas Flutuantes Sobrepostas)
│   • Ex: Modal de Elenco, Modal de Finanças, Modal do Estádio
│   • Bloqueia cliques no mundo isométrico ao fundo via escurecimento (Dimmer)
│
└── ToastLayer (Notificações Flutuantes no Topo)
```

### 4.1 Controle de Pilha de Telas (`UIManager`)
- Apenas um modal principal pode estar aberto por vez.
- Pressionar a tecla `ESC` ou clicar fora da janela fecha o modal ativo e devolve o foco ao mapa do clube.

---

## 5. Resolução, Responsividade e Proporção

- **Resolução Base:** $1152 \times 648\text{ px}$ (16:9 padrão HD).
- **Modo de Stretch da Godot:**
  - `window/stretch/mode = "canvas_items"`
  - `window/stretch/aspect = "expand"`
- **Comportamento em Monitores Ultrawide ou 4:3:**
  - O HUD se ancora nos cantos da tela através de *Anchors* da Godot (`Control`).
  - O mundo isométrico simplesmente ganha mais visão lateral sem distorcer os tiles ou esticar a imagem.
