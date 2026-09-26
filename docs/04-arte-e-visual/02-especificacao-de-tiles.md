# Arte e Visual — Especificação de Tiles e Estruturas Multi-Tile

> **Documento:** `docs/04-arte-e-visual/02-especificacao-de-tiles.md`  
> **Status:** Especificação Técnica / V1  
> **Escopo:** Dimensões do grid 2:1, caixas de colisão, pegadas de edifícios e pivôs de Y-Sort  

---

## 1. O Padrão do Tile Base ($64 \times 32\text{ px}$)

Cada célula básica do grid é um losango simétrico com proporção $2:1$:

```text
                     (32, 0)
                       /\
                      /  \
           (0, 16)   /    \   (64, 16)
                     \    /
                      \  /
                       \/
                     (32, 32)
```

- **Largura:** $64\text{ pixels}$
- **Altura:** $32\text{ pixels}$
- **Vértice Central:** $(32, 16)$

---

## 2. Padrões de Pegadas no Solo (Footprints de Instalações)

Prédios e campos de futebol ocupam múltiplos tiles contíguos na grade. Os sprites devem ser desenhados considerando a área de base correspondente:

| Tipo de Estrutura | Pegada no Grid | Largura de Base ($X$) | Altura de Base ($Y$) | Exemplos |
| :--- | :---: | :---: | :---: | :--- |
| **Pequena (1x1)** | $1 \times 1\text{ tile}$ | $64\text{ px}$ | $32\text{ px}$ | Árvores, postes de luz, bilheteria avulsa |
| **Média (2x2)** | $2 \times 2\text{ tiles}$ | $128\text{ px}$ | $64\text{ px}$ | Sede Administrativa, Loja do Clube, Vestiário |
| **Grande (3x3)** | $3 \times 3\text{ tiles}$ | $192\text{ px}$ | $96\text{ px}$ | Campo de Treinamento do CT, Alojamentos |
| **Estádio Nv 1/2 (4x4)** | $4 \times 4\text{ tiles}$ | $256\text{ px}$ | $128\text{ px}$ | Estádio Rústico e Arena Regional de Alvenaria |
| **Mega Estádio (6x6)** | $6 \times 6\text{ tiles}$ | $384\text{ px}$ | $192\text{ px}$ | Estádio Metropolitano Moderno (Nível 3+) |

---

## 3. Posição do Pivô de Profundidade (Y-Sort Origin)

Para que a Godot ordene a profundidade de forma 100% perfeita sem bugs de sobreposição:

> **O ponto de origem do sprite no arquivo PNG deve estar alinhado com o vértice inferior central da pegada da base no solo.**

```text
                  Topo do Estádio
                        /\
                       /  \
                      /    \
                     /______\
                     \      /
                      \    /
                       \  /
                        \/  ◄── ORIGEM / PIVÔ (X = Centro, Y = Base Inferior)
```

Seguindo essa convenção, se um torcedor ou carro caminhar pelo sul da instalação, seu `Y` será maior e ele será desenhado **na frente** do prédio. Se caminhar pelo norte, seu `Y` será menor e ele será encoberto **atrás** do prédio.
