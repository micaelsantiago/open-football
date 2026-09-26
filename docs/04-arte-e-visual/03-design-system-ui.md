# Arte e Visual — Design System da Interface (UI)

> **Documento:** `docs/04-arte-e-visual/03-design-system-ui.md`  
> **Status:** Especificação de UI/UX / V1  
> **Escopo:** Paleta de cores da interface, tipografia, estados de componentes e layout de telas  

---

## 1. Filosofia de Interface

A interface do Open Football equilibra o **minimalismo retro dos simuladores dos anos 90** com a **ergonomia e clareza visual moderna**.

- Informação visual prioritária e legível.
- Menos cliques para tomar uma decisão.
- Cores de destaque funcionais (Verde para sucesso/dinheiro/vitória, Vermelho para derrota/déficit, Amarelo para atenção).

---

## 2. Paleta de Cores da UI (Color Tokens)

```text
SUPERFÍCIES:
• Fundo de Telas e HUD:     #12161E (Azul Petróleo Profundo / Dark)
• Fundo de Painéis/Modais:   #1A202C (Cinza Azulado Escuro)
• Superfície de Cards:       #242D3D (Cinza Médio)
• Bordas e Divisórias:       #3A475C (Cinza Suave)

ACENTOS E STATUS:
• Primária (Ações / Botões): #2563EB (Azul Esportivo Forte)
• Sucesso / Receita:         #16A34A (Verde Gramado)
• Alerta / Atenção:          #EAB308 (Dourado de Troféu)
• Perigo / Déficit:          #DC2626 (Vermelho Alerta)

TEXTOS:
• Texto Principal:           #F8FAFC (Branco Gelo Alto Contraste)
• Texto Secundário:          #94A3B8 (Cinza Claro)
• Texto Mudo / Desabilitado: #64748B (Cinza Médio)
```

---

## 3. Tipografia e Escala de Texto

A tipografia deve utilizar fontes nítidas e sólidas, sem antialiasing borrado em resoluções menores:

- **Títulos de Telas:** `24 px` (Negrito).
- **Subtítulos e Cabeçalhos de Tabela:** `16 px` (Seminegrito).
- **Texto Corrido e Valores:** `14 px` (Regular).
- **Notas de Rodapé e Tooltips:** `11 px` (Regular).

---

## 4. Componentes Chave

### 4.1 Botões Primários
- Cantos suavemente arredondados ($4\text{ px}$).
- Estado **Hover**: Iluminação de $+15\%$ no fundo com cursor de mãozinha.
- Estado **Pressed**: Pequeno deslocamento de $1\text{ px}$ para baixo com som tátil curto.

### 4.2 Tabelas de Dados (Data Tables)
- Linhas alternadas ("zebradas") para facilitar leitura de longas listas de atletas.
- Colunas com alinhamento funcional: Texto à esquerda, números (gols, saldo, notas) à direita.

---

## 5. Tela do Assistente de Criação de Clube (Create-a-Club Wizard)

Para a experiência de fundar um novo time, a interface adota um layout dividido em duas colunas (*Two-Pane Layout*) com atualização visual em tempo real:

```text
┌─────────────────────────────────────────────────────────────┐
│  NOVA CARREIRA: FUNDAÇÃO DE CLUBE              [Passo 2/4]  │
│  [1. Identidade] ──► [● 2. Cores] ──► [3. Estádio] ──► [4. Fim]│
├──────────────────────────────┬──────────────────────────────┤
│ PAINEL DE CONFIGURAÇÃO       │ PRÉ-VISUALIZAÇÃO AO VIVO     │
│                              │                              │
│ • Cor Primária:   [ #1A4B8C ]│      🛡️ ESCUDO DO CLUBE      │
│ • Cor Secundária: [ #FFFFFF ]│      (Cores aplicadas)       │
│ • Cor de Destaque:[ #F2B705 ]│                              │
│                              │      👕 UNIFORME TITULAR     │
│ [Paletas Esportivas Prontas] │      Azul com faixas brancas │
│ 🔵 Clássico  🔴 Rubi  🟢 Bosque│                              │
│                              │      🏟️ MINIATURA DO ESTÁDIO │
│ [ ◄ Voltar ]    [ Próximo ► ]│      Bandeirinhas no gramado │
└──────────────────────────────┴──────────────────────────────┘
```

### 5.1 Recursos Visuais do Assistente
1. **Stepper Superior**: Barra de progresso horizontal que indica visualmente o passo atual da fundação.
2. **Pré-visualização Instantânea**: Qualquer alteração no seletor de cor atualiza imediatamente o escudo, a camisa e as arquibancadas de teste na coluna direita.
3. **Paletas Esportivas Recomendadas**: Além do seletor livre (HEX), a UI oferece combinações clássicas do futebol (Alvinegro, Tricolor, Celeste, Grená) para escolha em um clique.
