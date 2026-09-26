# Open Football — Documentação Oficial do Projeto

Bem-vindo ao repositório de documentação do **Open Football**, um simulador e jogo de gerenciamento de futebol *open source*, *offline-first* e *data-driven*, onde o clube é um mundo vivo em pixel art isométrica (inspirado na agilidade e simplicidade de **Brasfoot** e na estética e construção de impérios de **OpenTTD / Tycoons**).

---

## 🗂️ Estrutura da Documentação

A documentação está organizada em **5 pilares modulares por contexto**:

```text
docs/
├── 01-game-design/     # A Alma do Jogo (GDD: Visão, Mecânicas, Táticas e Liga)
├── 02-arquitetura/     # A Engenharia (TDD: Clean Arch, Core Engine, Saves e Testes)
├── 03-dados-e-modding/ # O Conteúdo (Schemas JSON, Base de Clubes e Guia do Modder)
├── 04-arte-e-visual/   # A Estética (Pixel Art, Grid 2:1, Footprints e Design System)
└── 05-planejamento/    # A Gestão (Escopo da V1, Definition of Done e Visão V2/V3)
```

---

## 🧭 Índice Geral dos Documentos

### ⚽ 1. [Game Design (GDD)](file:///home/micael/projects/open-football/docs/01-game-design/README.md)
- [**`00-ideia-original.md`**](file:///home/micael/projects/open-football/docs/01-game-design/00-ideia-original.md): Texto conceitual inicial original preservado na íntegra.
- [**`01-visao-e-pilares.md`**](file:///home/micael/projects/open-football/docs/01-game-design/01-visao-e-pilares.md): Os 5 pilares do projeto (Clube Vivo, Agilidade Brasfoot, Progressão, Offline e Open Source).
- [**`02-mecanicas-de-gestao.md`**](file:///home/micael/projects/open-football/docs/01-game-design/02-mecanicas-de-gestao.md): Elenco, atributos (1 a 99), táticas (4-4-2, 4-3-3), ingressos, salários e obras.
- [**`03-regras-de-partida.md`**](file:///home/micael/projects/open-football/docs/01-game-design/03-regras-de-partida.md): Ritmo acelerado (15s), ticks de lance, intervenções do treinador e narração.
- [**`04-loop-de-temporada.md`**](file:///home/micael/projects/open-football/docs/01-game-design/04-loop-de-temporada.md): Liga Inaugural (14 rodadas, 8 times), premiações e virada anual.

---

### 🏛️ 2. [Arquitetura Técnica (TDD)](file:///home/micael/projects/open-football/docs/02-arquitetura/README.md)
- [**`01-visao-geral-e-padroes.md`**](file:///home/micael/projects/open-football/docs/02-arquitetura/01-visao-geral-e-padroes.md): Clean Architecture na Godot 4, DI vs limites de Autoloads e `RefCounted`.
- [**`02-core-engine-e-dominio.md`**](file:///home/micael/projects/open-football/docs/02-arquitetura/02-core-engine-e-dominio.md): `PlayerData`, `ClubData`, `GameState` e máquina de estados da rodada.
- [**`03-camada-de-apresentacao-e-ui.md`**](file:///home/micael/projects/open-football/docs/02-arquitetura/03-camada-de-apresentacao-e-ui.md): Padrão MVP, barramento de eventos (`EventBus`) e design system de UI.
- [**`04-mundo-isometrico-e-renderizacao.md`**](file:///home/micael/projects/open-football/docs/02-arquitetura/04-mundo-isometrico-e-renderizacao.md): `TileMapLayer`, profundidade Y-Sort com pivô na base e câmera livre.
- [**`05-sistema-de-partidas-e-eventos.md`**](file:///home/micael/projects/open-football/docs/02-arquitetura/05-sistema-de-partidas-e-eventos.md): Modo Instantâneo (IA em $<1\text{ ms}$) vs Modo Interativo (Jogador com playback).
- [**`06-persistencia-e-save-system.md`**](file:///home/micael/projects/open-football/docs/02-arquitetura/06-persistencia-e-save-system.md): Gravação atômica anti-corrupção (`.tmp` ➔ `rename`) e esteira de migração.
- [**`07-pipeline-de-dados-e-modding.md`**](file:///home/micael/projects/open-football/docs/02-arquitetura/07-pipeline-de-dados-e-modding.md): Sistema de arquivos virtual em camadas e sanitização defensiva.
- [**`08-testabilidade-e-qualidade.md`**](file:///home/micael/projects/open-football/docs/02-arquitetura/08-testabilidade-e-qualidade.md): Testes unitários do Core, simulação de 100 temporadas (Monte Carlo) e CI.
- [**`09-padrao-de-commits.md`**](file:///home/micael/projects/open-football/docs/02-arquitetura/09-padrao-de-commits.md): Padrão de micro-commits atômicos e Semantic Commits (Conventional Commits).

---

### 📦 3. [Dados e Modding](file:///home/micael/projects/open-football/docs/03-dados-e-modding/README.md)
- [**`01-schemas-e-contratos.md`**](file:///home/micael/projects/open-football/docs/03-dados-e-modding/01-schemas-e-contratos.md): Schemas JSON rigorosos para Atletas, Clubes, Instalações e Competições.
- [**`02-base-de-dados-v1.md`**](file:///home/micael/projects/open-football/docs/03-dados-e-modding/02-base-de-dados-v1.md): Descrição dos 8 clubes canônicos (Aurora FC, União FC, Estrela, etc.).
- [**`03-guia-do-modder.md`**](file:///home/micael/projects/open-football/docs/03-dados-e-modding/03-guia-do-modder.md): Tutorial prático para a comunidade criar novos clubes e ligas via JSON.

---

### 🎨 4. [Arte e Visual](file:///home/micael/projects/open-football/docs/04-arte-e-visual/README.md)
- [**`01-estilo-pixel-art.md`**](file:///home/micael/projects/open-football/docs/04-arte-e-visual/01-estilo-pixel-art.md): Direção artística, iluminação 45° noroeste e paleta de cores naturais.
- [**`02-especificacao-de-tiles.md`**](file:///home/micael/projects/open-football/docs/04-arte-e-visual/02-especificacao-de-tiles.md): Dimensões do grid 2:1 ($64 \times 32\text{ px}$), pegadas no chão ($4\times4, 6\times6$) e pivôs.
- [**`03-design-system-ui.md`**](file:///home/micael/projects/open-football/docs/04-arte-e-visual/03-design-system-ui.md): Paleta da interface (Dark Blue/Sporty), tipografia nítida e botões táteis.

---

### 📋 5. [Planejamento e Entregas](file:///home/micael/projects/open-football/docs/05-planejamento/README.md)
- [**`00-plano-versao-alpha.md`**](file:///home/micael/projects/open-football/docs/05-planejamento/00-plano-versao-alpha.md): Roteiro prático das 7 etapas de construção da versão Alpha com estratégia de micro-commits.
- [**`01-escopo-e-marcos-v1.md`**](file:///home/micael/projects/open-football/docs/05-planejamento/01-escopo-e-marcos-v1.md): As 6 fases de desenvolvimento do MVP 0.1 (Fundação ➔ Simulação ➔ Mundo ➔ UI ➔ Upgrade ➔ Save).
- [**`02-criterios-de-aceite.md`**](file:///home/micael/projects/open-football/docs/05-planejamento/02-criterios-de-aceite.md): *Definition of Done* formal e a jornada testável completa do jogador.
- [**`03-visao-v2-e-futuro.md`**](file:///home/micael/projects/open-football/docs/05-planejamento/03-visao-v2-e-futuro.md): Roadmap estratégico para a V2 (mercado dinâmico, categorias de base e copas).

---

## 🎯 Meta da V1 (MVP 0.1)

> **"É divertido e recompensador administrar um clube de futebol simplificado e vê-lo fisicamente existir e evoluir em um pequeno mundo isométrico em pixel art?"**
