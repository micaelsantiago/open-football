# Planejamento — Escopo e Marcos da V1 (MVP 0.1)

> **Documento:** `docs/05-planejamento/01-escopo-e-marcos-v1.md`  
> **Status:** Gestão de Projeto / V1  
> **Escopo:** As 6 fases de execução do MVP 0.1 e cronograma de marcos  

---

## 1. O Objetivo da V1 (MVP 0.1)

O primeiro marco de desenvolvimento tem como única finalidade validar a diversão da premissa central:

> **"Administrar um clube de futebol com menus rápidos estilo Brasfoot e vê-lo fisicamente crescer em um mundo isométrico em pixel art."**

---

## 2. As 6 Fases Sequenciais de Execução

```text
Fase 1: Fundação & Dados ──► Fase 2: Simulação de Liga ──► Fase 3: Mundo Isométrico
                                                                   │
Fase 6: Save & Entrega   ◄── Fase 5: Upgrade Visual    ◄── Fase 4: Interface & Jogo
```

### 🔹 Fase 1: Fundação do Core Engine e Dados
- Estrutura de classes puras (`PlayerData`, `ClubData`, `FacilityData`, `GameState`).
- Serviço `DataLoader` com leitura dos arquivos JSON em `data/`.
- 8 clubes fictícios e a Liga Inaugural cadastrados.
- **Entrega:** Teste unitário headless carregando o banco completo sem erros em menos de 100 ms.

### 🔹 Fase 2: Motor Matemático da Partida e Temporada
- Implementação de `MatchSimulation` (Forças setoriais, posse territorial e resolução de lances).
- Tabela de classificação com critérios de desempate ordenados.
- Calendário de 14 rodadas (turno e returno).
- **Entrega:** Uma rodada inteira simulada no console com resultados e tabela atualizada.

### 🔹 Fase 3: O Mundo Isométrico e Navegação
- Grid isométrico 2:1 ($64 \times 32\text{ px}$) via `TileMapLayer` na Godot 4.
- Câmera livre com arrasto do mouse e zoom suave.
- Prédios do *Aurora FC* posicionados (Estádio, CT e Sede) com detecção de hover e clique.
- **Entrega:** Navegação fluida no mapa do clube com clique funcionando nos prédios.

### 🔹 Fase 4: Interface de Gestão (UI) e Acompanhamento da Partida
- Menus de gestão: Escalação do time, finanças da semana e ingressos.
- Tela de partida estilo Brasfoot: Cronômetro acelerado de 90', barra de posse e feed de lances narrados.
- **Entrega:** Jogar a 1ª rodada do campeonato pela interface gráfica.

### 🔹 Fase 5: O Teste de Ouro — A Evolução Visual
- Mecânica de reforma do estádio: Gasto de R$ 150.000 e 4 rodadas em obras.
- Efeito visual de andaimes durante a reforma.
- Substituição permanente do sprite pela **Arena Regional de Alvenaria Nível 2** no mapa ao concluir.
- **Entrega:** Presenciar o estádio crescer no mapa após rodadas de trabalho.

### 🔹 Fase 6: Sistema de Save/Load e Empacotamento
- Gravação atômica em JSON na pasta `user://saves/`.
- Menu principal (Nova Carreira, Carregar, Sair).
- Áudio procedural para apito, clique e gols.
- **Entrega:** Jogo fechado e distribuível, 100% jogável do início ao fim.
