# Open Football — Documento Inicial do Projeto

> **Status:** Ideia / pré-produção  
> **Tipo:** Jogo de gerenciamento e simulação de futebol  
> **Modelo:** Offline-first, open source e altamente customizável  
> **Direção visual:** Pixel art 2D isométrica, tile-based, inspirada em clássicos como OpenTTD  
> **Referências de gameplay:** Brasfoot, Football Manager, jogos Tycoon/Management e simuladores esportivos

---

# 1. Visão geral

**Open Football** é o nome provisório de um jogo de gerenciamento de futebol inspirado na simplicidade e acessibilidade de **Brasfoot**, mas apresentado visualmente como um pequeno mundo isométrico em pixel art, inspirado na linguagem visual de jogos como **OpenTTD**.

A ideia central é:

> **Um simulador de gestão de futebol onde o clube é um pequeno mundo vivo.**

O jogador começa administrando um clube pequeno e, temporada após temporada, pode desenvolver o elenco, contratar jogadores, disputar competições, melhorar a infraestrutura, aumentar a torcida, expandir o estádio e transformar o clube em uma potência.

O diferencial é que o jogo não deve ser apenas uma coleção de menus.

O clube existe fisicamente no mundo.

O estádio, centro de treinamento, campos, prédios administrativos, alojamentos e demais estruturas podem ser vistos e evoluem visualmente conforme o clube cresce.

---

# 2. Pilares do projeto

O projeto deve ser construído sobre cinco pilares principais.

## 2.1 Gestão de futebol

O jogador administra:

- elenco;
- escalações;
- táticas;
- transferências;
- contratos;
- salários;
- treinamento;
- categorias de base;
- comissão técnica;
- lesões;
- finanças;
- estádio;
- infraestrutura;
- torcida;
- reputação;
- competições;
- calendário.

---

## 2.2 Mundo isométrico

O clube possui uma representação física no mapa.

Elementos possíveis:

- estádio;
- campos de treinamento;
- academia;
- centro médico;
- alojamentos;
- prédio administrativo;
- estacionamento;
- loja oficial;
- restaurantes;
- hotel;
- centro de categorias de base;
- sala de troféus;
- áreas comerciais.

O mapa deve ser construído sobre uma grade de tiles.

---

## 2.3 Progressão visual

O crescimento do clube deve ser perceptível também visualmente.

Um clube pequeno pode começar com:

```text
Campo pequeno
Escritório simples
1 campo de treinamento
Estádio pequeno
```

Depois pode evoluir para:

```text
Estádio maior
Múltiplos campos
Centro de treinamento
Academia
Departamento médico
Categorias de base
Loja
Hotel
Centro administrativo
```

A ideia é que o jogador consiga olhar para o mapa depois de várias temporadas e perceber a evolução do próprio clube.

---

## 2.4 Offline-first

O jogo deve funcionar inicialmente completamente offline.

Não deve depender de:

- servidor;
- conta;
- internet;
- banco de dados remoto;
- API externa;
- serviço de terceiros.

O jogador deve conseguir:

- iniciar uma carreira;
- jogar temporadas;
- salvar;
- carregar;
- editar conteúdo;
- criar mods;

sem conexão com a internet.

Recursos online podem ser considerados futuramente, mas não fazem parte do núcleo inicial.

---

## 2.5 Open source e moddable

O projeto deve nascer pensando em uma comunidade.

A engine deve ser separada do conteúdo.

A ideia não é criar somente um jogo fechado, mas uma **engine aberta de simulação e gerenciamento de futebol** que permita que outras pessoas criem seus próprios universos.

Exemplos:

- bancos de dados de diferentes países;
- futebol histórico;
- clubes fictícios;
- universos alternativos;
- novas competições;
- novos mapas;
- novos assets;
- novas regras;
- novos temas visuais.

---

# 3. Conceito de gameplay

A experiência principal pode ser resumida como:

```text
Escolher clube
     ↓
Montar elenco
     ↓
Definir escalação
     ↓
Treinar
     ↓
Disputar partidas
     ↓
Gerenciar finanças
     ↓
Contratar / vender jogadores
     ↓
Melhorar infraestrutura
     ↓
Desenvolver jovens
     ↓
Conquistar competições
     ↓
Expandir o clube
     ↓
Começar uma nova temporada
```

O jogo deve funcionar em ciclos de temporada.

---

# 4. O clube como um pequeno mundo

Uma das principais diferenças em relação a jogos tradicionais de gerenciamento é que o clube não existe apenas em menus.

Ele possui uma representação física.

Exemplo:

```text
                 CIDADE

          🏠          🏢

                🏟️
             ESTÁDIO

          ⚽       ⚽
       CAMPO    CAMPO

             🏋️
              CT

             🏥
          MÉDICO
```

Conforme o clube cresce, esse espaço também cresce.

---

# 5. Jogadores

Cada jogador deve possuir atributos que influenciam sua performance.

Exemplo:

```yaml
player:
  id: player-001
  name: João Silva
  age: 18
  nationality: BR
  position: ST

  attributes:
    pace: 72
    shooting: 68
    passing: 54
    dribbling: 70
    defending: 25
    physical: 61

  potential:
    min: 75
    max: 87
```

Atributos possíveis:

- velocidade;
- aceleração;
- finalização;
- passe;
- visão;
- drible;
- cruzamento;
- marcação;
- desarme;
- força;
- resistência;
- impulsão;
- cabeceio;
- posicionamento;
- técnica;
- tomada de decisão.

Também podem existir atributos mentais:

- liderança;
- concentração;
- disciplina;
- profissionalismo;
- consistência;
- ambição;
- personalidade.

---

# 6. Potencial e desenvolvimento

Os jogadores não devem ser estáticos.

Um jogador jovem pode evoluir muito.

Exemplo:

```text
18 anos
Overall: 62
Potencial: 82

       ↓

20 anos
Overall: 71

       ↓

23 anos
Overall: 81
```

O desenvolvimento pode depender de:

- idade;
- potencial;
- treinamento;
- minutos jogados;
- qualidade do centro de treinamento;
- comissão técnica;
- profissionalismo;
- lesões;
- moral;
- sequência de jogos.

---

# 7. Sistema de partidas

O jogador não controla diretamente os jogadores como em FIFA/eFootball.

O foco é a simulação.

A partida deve considerar:

- atributos;
- escalação;
- formação;
- tática;
- condição física;
- moral;
- forma;
- qualidade dos adversários;
- mando de campo;
- clima, se implementado;
- estratégia;
- substituições.

Durante a partida, o jogador pode alterar:

- formação;
- mentalidade;
- pressão;
- linha defensiva;
- largura;
- ritmo;
- marcação;
- instruções individuais;
- substituições.

---

# 8. Representação visual da partida

A partida pode ser apresentada através de uma visão isométrica ou pseudo-isométrica simplificada.

Os jogadores podem ser pequenos sprites.

Exemplo conceitual:

```text
             ⚽

       🔵             🔴

          🔵      🔴

             🔵

       🔴             🔵

──────────────────────────
```

Não é necessário reproduzir uma partida em tempo real com a complexidade de um jogo de futebol tradicional.

A prioridade é transmitir:

- posicionamento;
- movimentação;
- ataques;
- chances;
- gols;
- substituições;
- alterações táticas.

---

# 9. Interface de partida

Uma partida pode mostrar:

```text
┌─────────────────────────────────────────────┐
│ FC Aurora  1 × 0  União FC                 │
│                                             │
│ 32:14                                       │
│                                             │
│ Posse                                       │
│ ████████████░░░░  68%                      │
│                                             │
│ Finalizações                                │
│ ██████ 6                                    │
│                                             │
│ Ataques perigosos                           │
│ ████████ 8                                  │
│                                             │
│ [Tática] [Escalação] [Substituir] [Pausar] │
└─────────────────────────────────────────────┘
```

---

# 10. Sistema de competições

O jogo deve possuir uma engine de competições configurável.

Uma competição pode definir:

- nome;
- número de clubes;
- sistema de pontos;
- número de rodadas;
- promoção;
- rebaixamento;
- playoffs;
- grupos;
- mata-mata;
- critérios de desempate;
- premiação;
- vagas para outras competições.

Exemplo:

```yaml
competition:
  id: brazilian-league
  name: Campeonato Brasileiro

  teams: 20

  points:
    win: 3
    draw: 1
    loss: 0

  relegation:
    count: 4

  promotion:
    count: 4
```

Isso permite criar competições completamente diferentes sem modificar a engine.

---

# 11. Economia

A economia é uma parte fundamental da progressão.

Possíveis receitas:

- bilheteria;
- patrocínio;
- direitos de transmissão;
- premiações;
- venda de jogadores;
- produtos;
- loja;
- publicidade.

Possíveis despesas:

- salários;
- transferências;
- manutenção do estádio;
- infraestrutura;
- comissão técnica;
- departamento médico;
- categorias de base;
- viagens;
- manutenção geral.

O clube deve possuir um balanço financeiro.

Exemplo:

```text
Receitas
──────────────────
Bilheteria       R$ 500.000
Patrocínio       R$ 300.000
TV               R$ 200.000
Transferências   R$ 150.000

Total            R$ 1.150.000


Despesas
──────────────────
Salários         R$ 700.000
Infraestrutura   R$ 100.000
Operacional      R$ 120.000

Total            R$ 920.000

Resultado        +R$ 230.000
```

---

# 12. Estádio

O estádio deve ser uma das principais estruturas do jogo.

Características:

- capacidade;
- preço dos ingressos;
- qualidade;
- conforto;
- iluminação;
- gramado;
- setores;
- estacionamento;
- camarotes;
- lojas;
- manutenção.

O estádio pode evoluir visualmente.

Exemplo:

```text
Nível 1
🏟️ 5.000 lugares

       ↓

Nível 2
🏟️ 15.000 lugares

       ↓

Nível 3
🏟️ 30.000 lugares

       ↓

Nível 4
🏟️ 60.000 lugares
```

---

# 13. Centro de treinamento

O CT influencia diretamente o desenvolvimento do elenco.

Possíveis instalações:

- campo;
- academia;
- fisioterapia;
- departamento médico;
- análise de desempenho;
- alojamento;
- centro de recuperação;
- laboratório;
- categorias de base.

Exemplo:

```text
CT Básico
    ↓
CT Profissional
    ↓
CT Avançado
    ↓
Centro de Excelência
```

---

# 14. Categorias de base

A base deve ser uma parte importante do jogo.

O clube pode investir em:

- scouting juvenil;
- academia;
- treinadores;
- infraestrutura;
- alojamento;
- observação regional.

Jogadores podem surgir proceduralmente.

Exemplo:

```text
Novo jogador descoberto

Lucas
17 anos
MC
Overall: 54
Potencial: 78
```

O jogador pode virar:

- titular;
- reserva;
- empréstimo;
- venda;
- ídolo;
- jogador histórico.

---

# 15. Transferências

O mercado deve simular:

- compra;
- venda;
- empréstimo;
- renovação;
- salário;
- bônus;
- cláusulas;
- interesse de clubes;
- valorização;
- desvalorização.

O valor de um jogador pode depender de:

```text
Idade
+
Overall
+
Potencial
+
Forma
+
Contrato
+
Posição
+
Reputação
+
Desempenho
```

---

# 16. Torcida e reputação

O clube deve possuir uma reputação.

Fatores:

- tamanho da torcida;
- desempenho;
- títulos;
- rivalidades;
- estádio;
- cidade;
- tradição;
- jogadores importantes.

A torcida pode afetar:

- público;
- receita;
- pressão;
- reputação;
- patrocínios.

---

# 17. Cidade

O clube pode existir dentro de uma cidade.

A cidade pode possuir:

- população;
- bairros;
- infraestrutura;
- empresas;
- transporte;
- torcedores;
- clubes rivais.

A cidade pode crescer junto com o clube.

Isso conecta:

```text
Cidade
  ↓
Torcida
  ↓
Receita
  ↓
Clube
  ↓
Infraestrutura
  ↓
Desempenho
  ↓
Reputação
  ↓
Cidade
```

---

# 18. Sistema de mapa isométrico

O mundo será baseado em tiles.

Estrutura conceitual:

```text
TileMap
├── Grass
├── Road
├── Building
├── Stadium
├── TrainingField
├── Tree
├── Decoration
└── Water
```

Cada elemento possui uma posição no grid.

Exemplo:

```text
x = 42
y = 17
```

A posição lógica é convertida para coordenadas de tela.

Fórmula isométrica conceitual:

```text
screenX = (x - y) * tileWidth / 2
screenY = (x + y) * tileHeight / 2
```

---

# 19. Estilo visual

Direção artística:

- pixel art;
- 2D;
- isométrico;
- tile-based;
- sprites;
- paleta limitada;
- estética retro;
- inspiração em jogos de gerenciamento dos anos 1990/2000.

Referências conceituais:

- OpenTTD;
- Transport Tycoon Deluxe;
- SimCity 2000;
- RollerCoaster Tycoon;
- Caesar III;
- Pharaoh;
- Brasfoot.

O objetivo não é copiar esses jogos, mas utilizar conceitos visuais semelhantes para construir uma identidade própria.

---

# 20. Arquitetura open source

A arquitetura deve separar **engine** e **conteúdo**.

```text
Open Football
│
├── Engine
│   ├── Football
│   ├── Economy
│   ├── Players
│   ├── Transfers
│   ├── Competitions
│   ├── Calendar
│   ├── AI
│   ├── World
│   ├── Rendering
│   └── Save System
│
├── Content
│   ├── Clubs
│   ├── Players
│   ├── Competitions
│   ├── Stadiums
│   ├── Cities
│   └── Rules
│
├── Assets
│   ├── Tiles
│   ├── Buildings
│   ├── Players
│   ├── Stadiums
│   └── UI
│
└── Mods
    ├── Databases
    ├── Maps
    ├── Assets
    └── Rules
```

---

# 21. Conteúdo baseado em dados

O conteúdo não deve ficar hardcoded no código.

Formatos candidatos:

- JSON;
- YAML;
- TOML.

Exemplo:

```yaml
club:
  id: club-001
  name: FC Aurora
  short_name: Aurora

  country: BR
  city: city-001

  stadium:
    id: stadium-001
    capacity: 12000

  finances:
    balance: 15000000
```

Isso permite que pessoas sem conhecimento profundo de programação possam modificar o conteúdo.

---

# 22. Sistema de Mods

O jogo deve suportar mods desde cedo.

Exemplo:

```text
mods/
├── brasileirao/
├── premier-league/
├── futebol-1990/
├── futebol-2000/
├── fantasy-football/
└── fictional-world/
```

Um mod pode alterar:

- clubes;
- jogadores;
- competições;
- regras;
- cidades;
- mapas;
- sprites;
- prédios;
- interface;
- configurações.

---

# 23. Diferentes universos

O mesmo executável poderia carregar universos completamente diferentes.

Exemplo:

### Universo A

```text
Brasil
2026
20 clubes
Brasileirão
Copa Nacional
```

### Universo B

```text
Brasil
1995
Clubes históricos
Regras históricas
Elencos históricos
```

### Universo C

```text
Mundo fictício
32 clubes
4 continentes
Competições próprias
```

### Universo D

```text
Futebol futurista
Clubes fictícios
Cidades fictícias
Regras próprias
```

A engine permanece a mesma.

---

# 24. Sistema de assets customizáveis

Assets também devem ser substituíveis.

```text
assets/
├── default/
│   ├── tiles/
│   ├── buildings/
│   ├── players/
│   ├── stadiums/
│   └── vehicles/
│
└── themes/
    ├── classic/
    ├── modern/
    ├── retro/
    └── custom/
```

Isso permite que a comunidade crie diferentes estilos visuais.

---

# 25. Sistema de saves

Os saves devem armazenar o estado da simulação.

Estrutura conceitual:

```text
save/
├── metadata.json
├── world.json
├── clubs.json
├── players.json
├── competitions.json
├── finances.json
└── history.json
```

O save também deve registrar versões:

```yaml
game_version: 0.3.0
database_version: 4

mod:
  id: brasileirao-2026
  version: 1.2.0
```

Isso facilita compatibilidade entre versões futuras.

---

# 26. Engine de simulação

O núcleo do jogo deve ser independente da interface gráfica.

A simulação deve ser capaz de executar:

```text
simulateMatch()
simulateSeason()
generateYouthPlayer()
calculateTransferValue()
calculatePlayerDevelopment()
calculateClubFinances()
calculateLeagueTable()
```

Isso significa que a lógica de futebol não precisa saber se está sendo exibida em:

- mapa isométrico;
- interface tradicional;
- modo texto;
- ferramenta de edição;
- teste automatizado.

Essa separação facilitará muito o desenvolvimento e os testes.

---

# 27. Tecnologia inicial

Uma candidata forte para a engine gráfica é:

## Godot

Motivos:

- open source;
- excelente suporte a 2D;
- TileMap;
- sprites;
- animações;
- UI;
- desktop;
- bom suporte para jogos independentes;
- adequado para mapas isométricos;
- fácil distribuição.

Arquitetura inicial:

```text
Godot
│
├── Football Simulation
│   ├── Players
│   ├── Teams
│   ├── Matches
│   ├── Competitions
│   └── Economy
│
├── World
│   ├── Isometric TileMap
│   ├── Buildings
│   ├── Stadium
│   └── NPCs
│
├── Match
│   ├── Tactical Simulation
│   └── Match Renderer
│
└── UI
    ├── Squad
    ├── Tactics
    ├── Transfers
    ├── Finance
    └── Calendar
```

A tecnologia definitiva deve ser validada durante o protótipo.

---

# 28. MVP

O primeiro objetivo não deve ser criar um Football Manager completo.

O MVP deve provar que o conceito é divertido.

## MVP 0.1

### Mundo

- 1 mapa;
- 1 cidade;
- 1 clube;
- estádio pequeno;
- CT simples;
- alguns prédios;
- sistema de tiles isométricos.

### Futebol

- 20 jogadores;
- posições;
- atributos;
- escalação;
- formação;
- partidas simuladas.

### Competição

- 1 campeonato;
- 8 clubes fictícios;
- tabela;
- calendário;
- rodada;
- campeão.

### Gestão

- contratação;
- venda;
- salários;
- treinamento;
- finanças básicas.

### Save

- salvar;
- carregar;
- iniciar nova carreira.

---

# 29. MVP 0.2

Depois de validar o núcleo:

- mercado de transferências mais completo;
- contratos;
- potencial;
- evolução de jogadores;
- lesões;
- categorias de base;
- estádio expansível;
- CT expansível;
- torcida;
- reputação;
- mais competições;
- mais clubes.

---

# 30. MVP 0.3

Primeiro sistema de modding:

- carregamento de database externo;
- clubes via JSON/YAML;
- jogadores via JSON/YAML;
- competições configuráveis;
- regras configuráveis;
- assets externos;
- criação de universos personalizados.

---

# 31. Futuro

Possibilidades futuras:

- editor de clubes;
- editor de jogadores;
- editor de competições;
- editor de mapas;
- editor de estádios;
- marketplace/repositório comunitário de mods;
- compartilhamento de databases;
- rankings online opcionais;
- cloud saves opcionais;
- multiplayer assíncrono;
- Steam Workshop ou equivalente;
- ferramentas externas para criação de conteúdo.

Nada disso deve ser requisito para o jogo funcionar offline.

---

# 32. Princípios de desenvolvimento

O projeto deve seguir alguns princípios.

### 1. Offline primeiro

O jogo não deve depender de serviços externos.

### 2. Dados separados do código

Clubes, jogadores e competições não devem ser hardcoded.

### 3. Modding desde o início

Não deixar o sistema de mods para depois.

### 4. Engine independente do conteúdo

A engine deve conseguir executar universos diferentes.

### 5. Simulação independente da apresentação

A lógica de futebol deve poder ser testada sem renderização.

### 6. Simplicidade antes de complexidade

O MVP deve ser pequeno.

### 7. Comunidade como parte do projeto

O formato dos dados e ferramentas devem facilitar contribuições externas.

---

# 33. Filosofia do projeto

Uma frase que resume a proposta:

> **A engine simula o futebol. Você decide qual futebol quer simular.**

Outra possibilidade:

> **Build your club. Shape your world.**

O jogo não precisa ser apenas uma experiência fechada.

Ele pode ser uma plataforma para criação de diferentes jogos de gerenciamento de futebol.

---

# 34. Identidade conceitual

O projeto combina:

```text
Brasfoot
   +
OpenTTD
   +
Football Management
   +
Pixel Art Isométrica
   +
Open Source
   +
Modding
```

Resultado pretendido:

```text
┌─────────────────────────────────────────┐
│                                         │
│          FOOTBALL MANAGEMENT             │
│                                         │
│     ⚽       🏟️        🏢               │
│                                         │
│       Pixel Art Isométrica              │
│                                         │
│       Simulação Profunda                │
│                                         │
│       Offline + Open Source             │
│                                         │
│       Mods + Customização               │
│                                         │
└─────────────────────────────────────────┘
```

---

# 35. Primeira meta concreta

A primeira versão jogável deve responder apenas uma pergunta:

> **É divertido administrar um clube e vê-lo existir e crescer visualmente em um mundo isométrico?**

Para responder isso, construir:

1. mapa isométrico;
2. clube;
3. estádio;
4. CT;
5. elenco;
6. atributos;
7. escalação;
8. simulação de partida;
9. calendário;
10. tabela;
11. dinheiro;
12. construção/expansão simples;
13. save/load.

Se essa experiência funcionar, todo o restante pode crescer sobre ela.

---

# 36. Visão de longo prazo

O objetivo final não é simplesmente criar um clone de Brasfoot.

A visão é criar uma **plataforma aberta de gerenciamento e simulação de futebol**.

Um jogador pode baixar o projeto e jogar a versão oficial.

Outro pode criar uma database brasileira.

Outro pode recriar uma temporada histórica.

Outro pode criar um universo fictício.

Outro pode criar novos prédios.

Outro pode criar um novo sistema de competição.

Outro pode criar uma estética completamente diferente.

Todos utilizam a mesma base:

```text
                 OPEN FOOTBALL
                      │
              ┌───────┴───────┐
              │               │
            ENGINE          MODS
              │               │
       ┌──────┼──────┐   ┌────┼─────┐
       │      │      │   │    │     │
    Futebol Mundo  Economia Dados Assets
       │      │      │   │    │     │
       └──────┴──────┘   └────┴─────┘
              │               │
              └───────┬───────┘
                      │
                 NOVOS JOGOS
```

---

# 37. Estado atual da ideia

### Definido

- [x] Jogo de gerenciamento de futebol
- [x] Inspiração em Brasfoot
- [x] Visual inspirado em OpenTTD
- [x] Pixel art
- [x] Isométrico
- [x] Tile-based
- [x] Mundo físico do clube
- [x] Progressão visual
- [x] Offline
- [x] Open source
- [x] Customizável
- [x] Sistema de mods como objetivo arquitetural
- [x] Separação entre engine e conteúdo
- [x] Simulação independente da renderização

### A decidir

- [ ] Nome definitivo
- [ ] Engine definitiva
- [ ] Licença open source
- [ ] Linguagem principal
- [ ] Formato definitivo dos dados
- [ ] Arquitetura de mods
- [ ] Estilo definitivo da pixel art
- [ ] Escopo exato do MVP
- [ ] Modelo de criação/distribuição de databases
- [ ] Ferramentas para modders

---

# 38. Próximo passo

Não começar implementando centenas de sistemas.

A sequência recomendada é:

```text
IDEIA
  ↓
GAME DESIGN DOCUMENT
  ↓
PROTÓTIPO ISOMÉTRICO
  ↓
SIMULAÇÃO DE PARTIDA
  ↓
PRIMEIRO CICLO DE TEMPORADA
  ↓
GESTÃO DO CLUBE
  ↓
PROGRESSÃO DO MUNDO
  ↓
SAVE/LOAD
  ↓
DATA-DRIVEN CONTENT
  ↓
MOD SYSTEM
  ↓
MVP
  ↓
OPEN SOURCE
```

O primeiro protótipo deve ser deliberadamente pequeno.

A prioridade é validar a **experiência central**, não construir toda a infraestrutura do projeto antes de existir um jogo.
