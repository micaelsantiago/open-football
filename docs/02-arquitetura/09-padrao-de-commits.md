# Engenharia — Padrão de Micro-commits e Semantic Commits

> **Documento:** `docs/02-arquitetura/09-padrao-de-commits.md`  
> **Status:** Padrão Oficial de Engenharia / V1  
> **Escopo:** Diretrizes de versionamento Git, Conventional Commits e micro-commits atômicos  

---

## 1. Filosofia de Micro-commits Atômicos

No desenvolvimento do **Open Football**, adotamos a cultura de **Micro-commits**:

> **"Cada commit deve representar uma única alteração atômica, auto-contida e com propósito claro. O repositório deve permanecer estável e funcional a cada commit."**

### Por que Micro-commits?
1. **Rastreabilidade Fina**: Identificar exatamente quando e por que um comportamento mudou via `git bisect` ou `git log`.
2. **Reversão Segura**: Facilidade de reverter (`git revert`) uma única alteração sem desfazer trabalho não relacionado.
3. **Revisões de Código Leves**: PRs compostos por commits pequenos e narrativos são muito mais fáceis de revisar e aprovar.

---

## 2. Padrão de Semantic Commits (Conventional Commits)

Todas as mensagens de commit devem seguir estritamente o formato:

```text
<tipo>(<escopo>): <descrição concisa e direta no imperativo>

[corpo opcional explicando o porquê da mudança]

[rodapé opcional com referências a issues: Closes #12]
```

### 2.1 Tipos Permitidos (`<tipo>`)

| Tipo | Quando Usar | Exemplo |
| :--- | :--- | :--- |
| **`feat`** | Nova funcionalidade para o jogo ou engine. | `feat(match): adiciona calculo de posse de bola` |
| **`fix`** | Correção de bug ou falha de cálculo. | `fix(save): corrige gravacao atomica em caminhos com espaco` |
| **`docs`** | Alterações ou adições apenas na documentação. | `docs(arch): especifica padrao de micro-commits` |
| **`refactor`**| Refatoração de código sem alterar comportamento externo. | `refactor(core): isola algoritmo de forcas setoriais` |
| **`test`** | Adição ou correção de testes automatizados. | `test(grid): adiciona teste unitario para conversao 2:1` |
| **`style`** | Ajuste de espaçamento, formatação ou lint sem alterar lógica. | `style(ui): formata identacao do painel de financas` |
| **`perf`** | Melhoria de desempenho ou otimização de memória. | `perf(world): otimiza ordenacao y-sort de estruturas multi-tile` |
| **`chore`** | Tarefas de manutenção, .gitignore, scripts de build. | `chore(git): atualiza .gitignore para ignorar screenshots` |
| **`ci`** | Alterações em scripts de integração contínua / pipelines. | `ci(github): adiciona step de execucao headless de testes` |

---

## 3. Escopos Padronizados (`<escopo>`)

O escopo contextualiza em qual módulo a alteração ocorreu:

- `(core)`: Lógica pura de simulação e domínio (`src/core/`).
- `(match)`: Motor de partida, ticks e lances.
- `(world)`: Mapa isométrico, TileMapLayers, Y-Sort e câmera.
- `(ui)`: Telas, modais, componentes e HUD.
- `(save)`: Persistência, serialização e migração de saves.
- `(data)`: Arquivos JSON de clubes, atletas e ligas (`data/`).
- `(mod)`: Subsistema de carregamento e injeção de mods.
- `(docs)`: Documentação técnica e design documents.

---

## 4. Exemplos Práticos de Micro-commits no Projeto

### ✅ Exemplos Bons (Atômicos e Semânticos)
```text
docs(arch): documenta padrao de micro-commits e conventional commits
chore(git): adiciona regras para screenshots e logs no .gitignore
feat(core): implementa classe PlayerData com calculo de overall
test(core): adiciona teste de assercao para overall de atacante
feat(world): cria helper IsometricGridHelper para projecao 2:1
fix(match): corrige divisao por zero quando forcas de meio sao nulas
```

### ❌ Exemplos Ruins (Proibidos)
```text
"ajustes gerais"               (Vago, sem tipo, sem contexto)
"feat: cria o jogo inteiro"    (Não atômico, mistura 10 coisas)
"fix: bug"                     (Sem escopo e sem explicar qual bug)
"WIP" ou "teste"               (Quebra a rastreabilidade)
```

---

## 5. Regra de Ouro da Branch Principal (`main`)

> **Nenhum commit que quebre a execução da engine ou faça testes falharem pode ser enviado para a branch `main`.**
