# Dados e Modding — Base de Dados Canônica da V1

> **Documento:** `docs/03-dados-e-modding/02-base-de-dados-v1.md`  
> **Status:** Especificação de Conteúdo / V1  
> **Escopo:** Os 8 clubes fundadores, médias de atributos, perfis táticos e a Liga Inaugural  

---

## 1. Visão Geral do Universo da V1

Para a primeira versão jogável, o universo do Open Football é situado em uma liga regional competitiva e balanceada chamada **Liga Inaugural**, com **8 clubes fictícios** disputando o título em 14 rodadas.

As forças médias dos elencos variam entre **50 e 65 de overall**, garantindo partidas disputadas onde a estratégia do treinador faz a diferença.

```text
┌─────────────────────────────────────────────────────────────────┐
│                 OS 8 CLUBES DA LIGA INAUGURAL                   │
├──────────────────────┬─────────────┬───────────┬────────────────┤
│ Clube                │ Cidade      │ Cores     │ Estilo Tático  │
├──────────────────────┼─────────────┼───────────┼────────────────┤
│ 1. Aurora FC         │ Serra Alta  │ Azul/Bco  │ Equilibrado    │
│ 2. União FC          │ Vila Velha  │ Verm/Pto  │ Agressivo/Fís  │
│ 3. Estrela EC        │ Metrópole   │ Amar/Azul │ Técnico/Posse  │
│ 4. Esperança FC      │ Nova Colina │ Verde/Bco │ Velocidade/Base│
│ 5. Metropolitano FC  │ Centro      │ Vinho/Dou │ Controle/Passe │
│ 6. Atlético do Vale  │ Vale Verde  │ Cinza/Lar │ Retranca/Contr │
│ 7. Real Litorâneo    │ Praia Azul  │ Celeste/B │ Ofensivo/Ponta │
│ 8. Juventude Paulist.│ Planalto    │ Grená/Bco │ Pressão Alta   │
└──────────────────────┴─────────────┴───────────┴────────────────┘
```

---

## 2. Perfis Detalhados dos Clubes

### 2.1 Aurora FC (`club-aurora-fc`) — *O Clube Inicial do Jogador*
- **Fundação:** 1924 | **Reputação:** 45 | **Saldo Inicial:** R$ 250.000
- **Identidade:** Clube tradicional de serra, sustentado por torcedores apaixonados. Começa com instalações rústicas e grande potencial de expansão.
- **Destaque do Elenco:** João Silva (ST, 19 anos, Overall 68, Potencial 85).

### 2.2 União FC (`club-uniao-fc`) — *O Grande Rival Operário*
- **Fundação:** 1938 | **Reputação:** 48 | **Saldo Inicial:** R$ 220.000
- **Identidade:** Time aguerrido, famoso por divididas duras e estádio com caldeirão de pressão.
- **Destaque do Elenco:** Betão (CB, 29 anos, Desarme 76, Força 82).

### 2.3 Estrela Esporte Clube (`club-estrela-ec`)
- **Fundação:** 1912 | **Reputação:** 55 | **Saldo Inicial:** R$ 400.000
- **Identidade:** O clube mais antigo e com maior folha salarial da liga. Favorito ao título.
- **Destaque do Elenco:** Gabriel Toledo (AM, 26 anos, Passe 78, Visão 75).

### 2.4 Esperança Futebol Clube (`club-esperanca-fc`)
- **Fundação:** 1975 | **Reputação:** 40 | **Saldo Inicial:** R$ 180.000
- **Identidade:** Clube de baixo orçamento focado em revelar talentos jovens velozes.
- **Destaque do Elenco:** Kauã (RW, 18 anos, Velocidade 84, Drible 72).

### 2.5 Metropolitano Futebol Clube (`club-metropolitano-fc`)
- **Fundação:** 1988 | **Reputação:** 52 | **Saldo Inicial:** R$ 350.000
- **Identidade:** Clube moderno financiado por empresas locais. Jogo técnico e posse de bola cadenciada.

### 2.6 Atlético do Vale (`club-atletico-vale`)
- **Fundação:** 1950 | **Reputação:** 42 | **Saldo Inicial:** R$ 190.000
- **Identidade:** Mestre da retranca e do contra-ataque letal. Difícil de ser batido em seus domínios.

### 2.7 Real Litorâneo (`club-real-litoraneo`)
- **Fundação:** 1963 | **Reputação:** 46 | **Saldo Inicial:** R$ 230.000
- **Identidade:** Futebol alegre, ofensivo e que utiliza bastante as pontas e cruzamentos na área.

### 2.8 Juventude Paulista (`club-juventude-paulista`)
- **Fundação:** 1999 | **Reputação:** 44 | **Saldo Inicial:** R$ 210.000
- **Identidade:** Time disciplinado taticamente que aplica marcação alta com grande intensidade física.

---

## 3. Calendário da Liga Inaugural (14 Rodadas)

Cada rodada é composta por **4 confrontos simultâneos**:

- **Turno (Rodadas 1 a 7)**: Todos se enfrentam uma vez.
- **Returno (Rodadas 8 a 14)**: Os mesmos confrontos com mandos de campo rigorosamente invertidos.
