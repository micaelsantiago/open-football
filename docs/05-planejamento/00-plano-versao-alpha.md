# Planejamento — Plano de Desenvolvimento da Versão Alpha

> **Documento:** `docs/05-planejamento/00-plano-versao-alpha.md`  
> **Status:** Concluído / Alpha 0.1.0 Pronto  
> **Meta:** Entrega do primeiro ciclo de gameplay completo e jogável de ponta a ponta  
> **Estratégia de Trabalho:** Micro-commits atômicos e Semantic Commits  

---

## 1. Visão Geral do Alpha

O **Alpha do Open Football** tem um objetivo preciso:

> **Entregar uma experiência de jogo fechada onde o treinador pode criar seu clube (ou escolher um existente), navegar por sua sede no mapa isométrico, escalar o time, disputar uma liga de 14 rodadas (estilo Brasfoot acelerado), acumular bilheteria e reformar o estádio fisicamente no mapa.**

---

## 2. As 7 Etapas do Alpha e Estratégia de Micro-commits

Cada etapa será construída através de **micro-commits atômicos** e testados:

```
[ ETAPA 1: Setup & Dados ] ──► [ ETAPA 2: Core & Estado ] ──► [ ETAPA 3: Motor Partida ]
                                                                       │
[ ETAPA 6: UI Partida & Liga ] ◄── [ ETAPA 5: UI & Gestão ] ◄── [ ETAPA 4: Mapa Isométrico ]
        │
        ▼
[ ETAPA 7: Reforma do Estádio & Save/Load ] ──► ALPHA COMPLETO!
```

---

### 🟢 Etapa 1: Repositório, Baseline e Carga de Dados (Data Engine)
- [x] Inicialização do repositório Git, `.gitignore` seguro e conexão com GitHub.
- [x] Criação da pasta `data/` com manifesto `mod.json` do jogo base.
- [x] Implementação de `src/systems/data_loader/data_loader.gd` com sanitização e parsing defensivo.
- [x] Cadastro dos arquivos JSON dos 8 clubes da Liga Inaugural e seus elencos base.
- [x] Teste unitário headless comprovando o carregamento dos dados em $< 50\text{ ms}$.
- *Commits realizados:* `chore(git)`, `feat(data)`, `feat(loader)`, `test(loader)`.

---

### 🟢 Etapa 2: Core Engine de Domínio e Estado da Sessão
- [x] Implementação das entidades `PlayerData`, `ClubData`, `FacilityData` e `CompetitionData` em GDScript puro (`RefCounted`).
- [x] Criação da classe `GameState` com gerenciamento de sementes determinísticas (`RandomNumberGenerator.seed`).
- [x] Máquina de estados do ciclo temporal da rodada (`SeasonController`):
  - `PRE_MATCH` ➔ `MATCH_DAY` ➔ `FINANCES` ➔ `FACILITY_TICK` ➔ `RECOVERY`.
- [x] Teste unitário headless do avanço de 14 rodadas puramente em memória.
- *Commits realizados:* `feat(core)`, `feat(state)`, `test(state)`.

---

### 🟢 Etapa 3: Motor Matemático da Partida (Match Engine)
- [x] Implementação do cálculo de forças setoriais: Defesa, Meio-Campo e Ataque com fator casa e mentalidade.
- [x] Algoritmo de Posse de Bola territorial ponderada.
- [x] Loop de 30 ticks de 3 minutos com geração de lances perigosos.
- [x] Resolução do duelo finalizador vs goleiro e emissão de eventos imutáveis (`GOAL`, `SAVE`, `CARD`).
- [x] Modo Instantâneo (IA) calculando 3 partidas da rodada em $< 2\text{ ms}$.
- [x] Teste de 100 partidas simuladas validando médias de gols (2.2 a 3.0 por jogo).
- *Commits realizados:* `feat(match)`, `test(match)`.

---

### 🟢 Etapa 4: Câmera e Sede Física Isométrica
- [x] Implementação do `IsometricGridHelper` (fórmulas 2:1 de conversão de coordenadas).
- [x] Montagem da cena `world_view.tscn` com nós `TileMapLayer` para terreno e asfalto.
- [x] Criação do nó reutilizável `BuildingNode2D` com suporte a pegadas multi-tile ($4\times4, 3\times3, 2\times2$) e pivô de Y-Sort na base.
- [x] Câmera 2D desacoplada com navegação por arrasto do mouse (Pan) e zoom suave.
- [x] Detecção de hover e clique do mouse sobre os prédios da sede.
- *Commits realizados:* `feat(grid)`, `feat(world)`, `feat(camera)`.

---

### 🟢 Etapa 5: Interface de Gestão e Criação de Clube
- [x] Implementação do `EventBus` para comunicação desacoplada Core ➔ UI.
- [x] Componentes base de UI: `DataTable`, `PlayerCard` e `ActionModal`.
- [x] Tela de Escalação e Táticas: seleção dos 11 titulares, reservas e postura (Ofensivo/Equilibrado/Defensivo).
- [x] Tela de Finanças Básicas: saldo, folha salarial e ajuste de preço do ingresso.
- [x] Assistente **Create-a-Club (Dois Caminhos)**:
  - Escolher time existente OU fundar novo clube escolhendo Nome, Cores e Nome do Estádio.
- *Commits realizados:* `feat(eventbus)`, `feat(ui)`, `feat(squad)`, `feat(create-club)`.

---

### 🟢 Etapa 6: A Experiência de Jogo (Dia de Partida) e Tabela
- [x] Tela `MatchView` com cronômetro de 90' acelerado (partida dura ~12 segundos).
- [x] Barra dinâmica de posse de bola e placar ao vivo.
- [x] Feed de narração em texto dos lances com destaque de cores.
- [x] Botão de Pausar e alteração tática durante o jogo.
- [x] Atualização automática da Tabela de Classificação com pontuação e saldo após o apito final.
- *Commits realizados:* `feat(match-view)`, `feat(standings)`.

---

### 🟢 Etapa 7: A Evolução Visual do Estádio e Persistência
- [x] Mecânica de Reforma do Estádio:
  - Custo de R$ 150.000 e 4 rodadas em obras.
  - Andaimes visuais durante a reforma.
  - Conclusão: troca permanente para o sprite do Estádio Nível 2 e salto de capacidade para 8.500 torcedores.
- [x] Gravação atômica em JSON na pasta `user://saves/` via `SaveManager`.
- [x] Menu Principal: "Nova Carreira", "Continuar Carreira", "Sair".
- [x] Efeitos sonoros procedurais táteis (apito, clique e comemoração de gol).
- *Commits realizados:* `feat(stadium-upgrade)`, `feat(save)`, `feat(audio)`.

---

## 3. Critério de Sucesso do Alpha

O Alpha estará pronto para testes quando for possível:
1. Abrir a aplicação e criar um novo clube ou escolher o *Aurora FC*.
2. Escalar os 11 titulares e ajustar o ingresso.
3. Jogar as 14 rodadas da Liga Inaugural, acompanhando a emoção dos lances.
4. Acumular bilheteria nos jogos em casa e financiar a reforma do estádio.
5. Ver o estádio crescer fisicamente no mapa isométrico.
6. Salvar o jogo e continuar a carreira após reabrir.

---

## 3. Critério de Sucesso do Alpha

O Alpha estará pronto para testes quando for possível:
1. Abrir a aplicação e criar um novo clube ou escolher o *Aurora FC*.
2. Escalar os 11 titulares e ajustar o ingresso.
3. Jogar as 14 rodadas da Liga Inaugural, acompanhando a emoção dos lances.
4. Acumular bilheteria nos jogos em casa e financiar a reforma do estádio.
5. Ver o estádio crescer fisicamente no mapa isométrico.
6. Salvar o jogo e continuar a carreira após reabrir.
