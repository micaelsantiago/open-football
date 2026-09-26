# Arquitetura Técnica — Open Football

Bem-vindo à especificação detalhada de engenharia e arquitetura de software do **Open Football**.

Esta pasta contém o detalhamento técnico modular de cada subsistema da engine, garantindo desacoplamento estrito, alta performance, manutenibilidade e suporte a mods.

---

## 📑 Índice dos Documentos de Arquitetura

| Arquivo | Contexto Técnico | Foco de Engenharia |
| :--- | :--- | :--- |
| [**`01-visao-geral-e-padroes.md`**](file:///home/micael/projects/open-football/docs/arquitetura/01-visao-geral-e-padroes.md) | **Padrões de Projeto & Código** | Arquitetura Hexagonal, injeção de dependência vs limites de Autoloads, `RefCounted` vs `Node` e tipagem estática. |
| [**`02-core-engine-e-dominio.md`**](file:///home/micael/projects/open-football/docs/arquitetura/02-core-engine-e-dominio.md) | **Domínio & GameState** | Entidades puras (`Club`, `Player`, `Facility`), `GameState` como fonte única da verdade e sementes determinísticas. |
| [**`03-camada-de-apresentacao-e-ui.md`**](file:///home/micael/projects/open-football/docs/arquitetura/03-camada-de-apresentacao-e-ui.md) | **Interface & Apresentação** | Padrão MVP (Model-View-Presenter), barramento de eventos transversal (`EventBus`), design system e pilha de janelas. |
| [**`04-mundo-isometrico-e-renderizacao.md`**](file:///home/micael/projects/open-football/docs/arquitetura/04-mundo-isometrico-e-renderizacao.md) | **Mundo 2D Isométrico** | Projeção 2:1 ($64 \times 32\text{ px}$), camadas `TileMapLayer`, resolução de profundidade Y-Sort e câmera livre. |
| [**`05-sistema-de-partidas-e-eventos.md`**](file:///home/micael/projects/open-football/docs/arquitetura/05-sistema-de-partidas-e-eventos.md) | **Simulação de Partidas** | Modo Instantâneo (IA) vs Modo Interativo (Jogador), buffer de playback com velocidade ajustável e UI estilo Brasfoot. |
| [**`06-persistencia-e-save-system.md`**](file:///home/micael/projects/open-football/docs/arquitetura/06-persistencia-e-save-system.md) | **Persistência & Saves** | Gravação atômica anti-corrupção (`.tmp` ➔ `rename`), formato JSON aberto e esteira de migração de versões. |
| [**`07-pipeline-de-dados-e-modding.md`**](file:///home/micael/projects/open-football/docs/arquitetura/07-pipeline-de-dados-e-modding.md) | **Modding & DataLoader** | Sistema de arquivos virtual em camadas, sanitização defensiva, clamping e sobreposição de texturas/dados. |
| [**`08-testabilidade-e-qualidade.md`**](file:///home/micael/projects/open-football/docs/arquitetura/08-testabilidade-e-qualidade.md) | **Testes & Qualidade** | Testes unitários de domínio, simulação em massa de 100 temporadas (Monte Carlo) e execução headless em CI. |
| [**`09-padrao-de-commits.md`**](file:///home/micael/projects/open-football/docs/02-arquitetura/09-padrao-de-commits.md) | **Versionamento & Git** | Padrão de micro-commits atômicos, Semantic Commits (Conventional Commits) e escopos padronizados. |
