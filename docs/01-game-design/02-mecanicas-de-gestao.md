# Game Design — Mecânicas de Gestão

> **Documento:** `docs/01-game-design/02-mecanicas-de-gestao.md`  
> **Status:** Game Design Document (GDD) / V1  
> **Escopo:** Administração de elenco, táticas, finanças e infraestrutura física  

---

## 1. Gestão de Elenco

Um clube bem-sucedido equilibra qualidade técnica, idade e saúde física do seu grupo de atletas.

### 1.1 Tamanho e Composição do Elenco
- **Tamanho Ideal na V1:** 16 a 20 jogadores.
- **Distribuição Típica:**
  - 2 Goleiros (1 titular, 1 reserva).
  - 4 a 5 Defensores (Zagueiros e Laterais).
  - 5 a 6 Meio-Campistas (Volantes e Armadores).
  - 3 a 4 Atacantes (Pontas e Centroavantes).

### 1.2 Atributos Chave e Posições
Os atletas possuem notas de **1 a 99**. O rendimento depende da posição escalada:

| Posição | Sigla | Atributos Primários | Atributos Secundários |
| :--- | :---: | :--- | :--- |
| **Goleiro** | `GK` | Reflexos, Posicionamento | Altura/Alcance, Força |
| **Zagueiro / Lateral** | `CB`, `LB`, `RB` | Desarme, Posicionamento, Físico | Velocidade, Passe |
| **Meio-Campista** | `DM`, `CM`, `AM` | Passe, Visão, Resistência | Desarme, Drible |
| **Atacante / Ponta** | `ST`, `LW`, `RW` | Finalização, Velocidade, Frio na Espinha | Drible, Cabeceio |

### 1.3 Condição Física e Fadiga
- **Desgaste por Jogo:** Atletas titulares perdem entre $15\%$ e $25\%$ de condição física por partida de 90 minutos.
- **Recuperação:** Entre uma rodada e outra, o repouso recupera $+20\%$ de estamina.
- **Risco de Lesão:** Atletas escalados com menos de $60\%$ de condição física têm risco elevado de lesão muscular (ausência de 2 a 6 rodadas). Isso força o jogador a **rodar o elenco**.

---

## 2. Táticas e Postura em Campo

As decisões táticas do treinador afetam diretamente os modificadores matemáticos do motor de partida:

### 2.1 Formações Suportadas na V1
1. **4-4-2 (Clássico)**: Equilíbrio padrão entre todos os setores.
2. **4-3-3 (Ofensivo)**: Fortalece o volume de finalizações à custa de menor proteção defensiva.
3. **5-3-2 (Reativo)**: Fortalece a barreira defensiva ideal para segurar placares contra times superiores.

### 2.2 Mentalidade Tática
O jogador pode alterar a postura da equipe a qualquer momento antes ou durante o jogo:
- **Defensiva (Retranca)**: $+15\%$ no poder de defesa, $-15\%$ no poder de ataque. Ideal para jogar fora de casa contra favoritos.
- **Equilibrada**: Sem bônus ou penalidades (postura padrão).
- **Ofensiva (Pressão Total)**: $+15\%$ no poder de ataque, $-15\%$ na proteção defensiva. Maior probabilidade de gols marcados e sofridos.

---

## 3. Economia e Balanço Financeiro

A saúde financeira é o motor que viabiliza a expansão das instalações físicas do clube.

```text
BALANÇO DA RODADA:
(+) Receita de Bilheteria (Jogos em Casa = Público Presente × Preço do Ingresso)
(+) Patrocínio Semanal Fixo
(-) Folha Salarial do Elenco (Soma dos salários de todos os contratos)
(-) Custo de Manutenção das Instalações (Estádio, CT, Sede)
────────────────────────────────────────────────────────────────
(=) SALDO LÍQUIDO DA RODADA
```

### 3.1 Preço do Ingresso vs Ocupação
O jogador define livremente o valor do ingresso para os jogos no seu estádio:
- **Ingresso Barato (ex: R$ 10)**: Atrai público máximo, mas arrecadação média menor.
- **Ingresso Equilibrado (ex: R$ 25)**: Ponto de equilíbrio de receita.
- **Ingresso Abusivo (ex: R$ 60)**: Esvazia o estádio se a reputação do clube não for alta.

### 3.2 O Perigo da Falência
- Se o caixa ficar negativo, o clube entra em aviso de déficit.
- Ficar com saldo negativo por 3 rodadas consecutivas impede contratações e paralisa reformas em andamento.

---

## 4. Obras e Evolução da Infraestrutura

As melhorias físicas não são menus instantâneos: são **projetos de engenharia** com custos e tempo de obra em rodadas:

| Instalação | Nível | Custo | Duração | Benefício Prático | Mudança Visual no Mapa |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **Estádio** | Nível 1 | R$ 0 | — | Capacidade: 3.000 torcedores | Arquibancada rústica de madeira |
| **Estádio** | Nível 2 | R$ 150.000 | 4 rodadas | Capacidade: 8.500 torcedores | Arena regional de alvenaria |
| **CT** | Nível 1 | R$ 0 | — | Recuperação física base | Campo simples de grama natural |
| **CT** | Nível 2 | R$ 80.000 | 3 rodadas | $+20\%$ na recuperação entre jogos | Campo com iluminação e alambrado |

---

## 5. Início de Carreira: Escolha de Clube vs Criação Própria (Create-a-Club)

Ao iniciar uma nova carreira, o jogador pode optar por dois caminhos:

### 5.1 Modo A: Comandar Clube Existente
- O jogador escolhe qualquer equipe já cadastrada na base de dados (ou instalada via mods de comunidades, como clubes das Séries A, B, C e D).
- Herda o elenco real/fictício existente, o saldo bancário daquele clube e o nível atual do seu estádio.

### 5.2 Modo B: Criar Meu Próprio Time (Create-a-Club Wizard)
O jogador funda uma nova agremiação do zero através de um assistente interativo em 5 passos:

1. **Identidade Institucional**:
   - Nome Oficial (ex: *"União Serra Futebol Clube"*).
   - Nome Curto / Sigla de 3 letras (ex: *"USF"*).
   - Apelido da Torcida (ex: *"O Dragão da Serra"*).
   - Cidade e Estado de origem.
2. **Cores do Uniforme e Identidade Visual**:
   - Seleção da **Cor Primária** (tinge a camisa titular e detalhes do estádio).
   - Seleção da **Cor Secundária** (calção e faixas).
   - Cor de Destaque / Terceira cor (números e detalhes).
3. **O Estádio Fundador**:
   - Nome de Batismo do Estádio (ex: *"Arena do Povo"*).
   - Começa com a estrutura básica: Nível 1 (Arquibancadas de madeira, capacidade de 3.000 pessoas).
4. **Geração Procedural do Elenco Fundador**:
   - A engine gera automaticamente **18 atletas fictícios** balanceados para a divisão de entrada:
     - 2 Goleiros, 5 Defensores, 6 Meio-Campistas e 5 Atacantes.
     - Médias de overall equilibradas (entre 50 e 58), com 2 ou 3 jovens promessas de alto potencial.
5. **Divisão de Entrada e Desafio de Acesso**:
   - O novo clube começa obrigatoriamente na divisão de acesso mais baixa (ex: Série D ou Liga Inaugural).
   - Caixa inicial padrão de R$ 200.000 para começar a gestão financeira e trilhar o caminho até o topo do futebol.
