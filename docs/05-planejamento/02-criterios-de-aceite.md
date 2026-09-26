# Planejamento — Critérios de Aceite da V1 (Definition of Done)

> **Documento:** `docs/05-planejamento/02-criterios-de-aceite.md`  
> **Status:** Gestão de Qualidade / V1  
> **Escopo:** Critérios formais e verificáveis para considerar a V1 concluída  

---

## 1. Definição de Pronto (*Definition of Done*)

A versão **V1 (MVP 0.1)** só será considerada concluída quando **todos** os seguintes critérios forem atingidos e validados:

### 1.1 Critérios Técnicos e de Performance
- [ ] O jogo inicia em menos de **1.5 segundos** até o menu principal.
- [ ] Taxa constante de **60 FPS** no mapa isométrico e na tela de partida.
- [ ] **Zero vazamentos de memória (ObjectDB Leaks = 0)** ao fechar a aplicação.
- [ ] Todos os testes unitários e de simulação em `tests/` executam com resultado verde (`PASS`).
- [ ] O arquivo de save é gravado atomicamente sem corromper mesmo se o processo for interrompido.

### 1.2 A Jornada Completa do Jogador (Gameplay DoD)
Um testador deve conseguir executar a seguinte sequência de ponta a ponta sem qualquer trava ou bug impeditivo:

1. **Iniciar Carreira**: Abrir o jogo, clicar em "Nova Carreira" e assumir o comando do *Aurora FC*.
2. **Exploração**: Mover a câmera pelo mapa isométrico com o mouse e clicar no Estádio para verificar suas instalações.
3. **Escalação**: Abrir a tela de elenco, alterar a formação tática e escalar os 11 titulares.
4. **Disputar Partida**: Clicar em "Avançar Rodada", assistir aos lances da partida com cronômetro de 90' e sentir a emoção do resultado.
5. **Classificação**: Visualizar a tabela de classificação atualizada com os 4 jogos da rodada computados.
6. **Finanças e Reforma**: Disputar jogos em casa acumulando bilheteria suficiente para financiar a reforma do estádio (Nível 2).
7. **Evolução Visual**: Acompanhar as 4 rodadas de obras e presenciar a transformação física do estádio no mapa isométrico.
8. **Final da Liga**: Concluir as 14 rodadas da temporada, ver o encerramento do torneio e receber as premiações financeiras.
9. **Persistência**: Salvar a carreira, fechar o jogo, reabri-lo e carregar o estado salvo exatamente de onde parou.
