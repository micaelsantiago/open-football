# Game Design — Loop de Temporada e Competições

> **Documento:** `docs/01-game-design/04-loop-de-temporada.md`  
> **Status:** Game Design Document (GDD) / V1  
> **Escopo:** Ciclo da temporada, formato de liga, premiações e transição anual  

---

## 1. O Loop Central da Temporada

A jornada do jogador é estruturada em ciclos anuais de temporada:

```
[ Início da Temporada: Pré-temporada & Caixa Inicial ]
                      │
                      ▼
[ Disputa das 14 Rodadas da Liga (Turno e Returno) ]
  • Semana a semana: gestão do elenco, ingressos e jogos
  • Acúmulo de bilheteria e início de reformas no estádio
                      │
                      ▼
[ Conclusão da Liga (Rodada 14) ]
  • Entrega da Taça de Campeão
  • Pagamento das premiações em dinheiro
                      │
                      ▼
[ Transição de Temporada (Ano Novo) ]
  • Todos os atletas envelhecem 1 ano (+1 na idade)
  • Evolução natural de atributos dos jovens
  • Renovação de contratos de patrocínio
  • Início da próxima temporada em nível superior de infraestrutura
```

---

## 2. Formato da Liga Inaugural (V1)

- **Total de Equipes:** 8 clubes fictícios regionais.
- **Formato:** Pontos Corridos (*Round-Robin*).
- **Número de Rodadas:** 14 rodadas (7 jogos de ida no primeiro turno + 7 jogos de volta no returno).
- **Mando de Campo:** Cada clube joga exatamente 7 partidas em seu estádio e 7 partidas como visitante.

### 2.1 Critérios de Desempate
Se dois ou mais clubes empatarem em pontos ao final da 14ª rodada, o desempate segue a seguinte ordem:
1. **Maior Número de Vitórias (`WINS`)**.
2. **Maior Saldo de Gols (`GOAL_DIFFERENCE`)**.
3. **Maior Número de Gols Pró (`GOALS_FOR`)**.
4. **Confronto Direto (`HEAD_TO_HEAD`)**.
5. **Sorteio Determinístico**.

---

## 3. Premiações Financeiras da V1

O sucesso na tabela impulsiona os cofres para investimentos pesados no mapa:

| Colocação | Título | Premiação em Dinheiro | Reputação do Clube |
| :---: | :--- | :---: | :---: |
| 🥇 **1º Lugar** | **Campeão da Liga** | **R$ 100.000** | $+8$ pontos |
| 🥈 **2º Lugar** | Vice-Campeão | **R$ 50.000** | $+4$ pontos |
| 🥉 **3º Lugar** | Terceiro Colocado | **R$ 25.000** | $+2$ pontos |
| 4º ao 8º | Participação | R$ 10.000 | Neutro |

---

## 4. Transição Anual (Virada de Temporada)

Ao encerrar a 14ª rodada e distribuir as premiações:
1. **Envelhecimento**: `age = current_year - birth_year`.
2. **Desenvolvimento de Jovens**: Atletas com menos de 22 anos ganham bônus de atributos com base na qualidade do CT e nos minutos jogados na temporada.
3. **Declínio de Veteranos**: Atletas com mais de 32 anos sofrem leve declínio em atributos físicos (Velocidade e Aceleração).
4. **Reinício de Calendário**: Novo sorteio de mandos e datas para as 14 rodadas do ano seguinte.
