# Game Design — Visão e Pilares

> **Documento:** `docs/01-game-design/01-visao-e-pilares.md`  
> **Status:** Game Design Document (GDD) / V1  
> **Tema Central:** A alma do jogo, proposta de valor e pilares inegociáveis  

---

## 1. Declaração de Visão

> **"Open Football é um simulador de gestão de futebol onde o clube é um pequeno mundo vivo em pixel art isométrica."**

A grande maioria dos jogos de gerenciamento de futebol divide-se em dois extremos:
1. **Planilhas complexas e frias**: Centenas de menus, gráficos numéricos e pouca sensação tátil de posse física (ex: *Football Manager*).
2. **Arcades de ação**: Controle direto dos 11 bonecos em campo (ex: *FIFA/eFootball*), onde o aspecto de construção de clube a longo prazo é secundário.

O **Open Football** resgata a **agilidade, o vício e a simplicidade de menus do clássico Brasfoot**, combinando-os com o charme de **construção, crescimento e vida física de clássicos Tycoon como OpenTTD, SimCity e RollerCoaster Tycoon**.

---

## 2. Os 5 Pilares Fundamentais

```text
┌─────────────────────────────────────────────────────────────────┐
│                     OS 5 PILARES INEGOCIÁVEIS                   │
├───────────────────┬─────────────────────────┬───────────────────┤
│ 1. O CLUBE VIVO   │ 2. AGILIDADE BRASFOOT   │ 3. PROGRESSÃO     │
│ O estádio, o CT e │ Menus rápidos, decisões │ Comece rústico e  │
│ a sede existem no │ diretas e partidas de   │ veja o estádio e  │
│ mapa isométrico.  │ 15 segundos.            │ o CT crescerem.   │
├───────────────────┴─────────────────────────┴───────────────────┤
│ 4. OFFLINE-FIRST                            5. DATA-DRIVEN      │
│ Zero dependência de nuvem, contas           Engine separada de  │
│ ou servidores. Funciona 100% offline.       conteúdo; feito     │
│                                             para mods.          │
└─────────────────────────────────────────────────────────────────┘
```

### Pilar 1: O Clube como um Mundo Vivo
O clube não é apenas um nome no topo de uma planilha. Ele ocupa um espaço físico na cidade:
- O jogador vê seu estádio, o campo de terra do CT, a sede da diretoria e as ruas ao redor.
- Para gerenciar os ingressos, o jogador clica no estádio.
- Para cuidar da preparação física, o jogador clica no CT.

### Pilar 2: Agilidade e Foco Decisório (Espírito Brasfoot)
- Sem burocracia excessiva: o foco é contratar, escalar, definir a mentalidade (Ofensiva/Defensiva), disputar a rodada e colher os frutos.
- Uma temporada inteira pode ser jogada em **menos de 30 minutos**.

### Pilar 3: Progressão Visual Recompensadora
A vitória em campo gera dinheiro de bilheteria e patrocínios. Esse dinheiro é reinvestido no mapa:
- Reformar a arquibancada transforma o sprite do estádio no mundo isométrico.
- O jogador olha para o seu clube na 5ª temporada e sente orgulho visual do império construído.

### Pilar 4: Offline-First e Autonomia
- Jogue em qualquer lugar: sem login obrigatório, sem microtransações predatórias, sem necessidade de internet.
- Saves locais, transparentes e portáteis.

### Pilar 5: Código Aberto e Modding desde a Raiz
- A engine foi desenhada para que qualquer comunidade no mundo possa criar seu próprio universo (Brasileirão, Premier League, Futebol dos Anos 90 ou ligas fictícias) sem alterar uma linha de código GDScript.
