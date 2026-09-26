# Dados e Modding — Guia do Modder

> **Documento:** `docs/03-dados-e-modding/03-guia-do-modder.md`  
> **Status:** Manual da Comunidade / V1  
> **Público-alvo:** Criadores de conteúdo, patch makers e pesquisadores de dados  

---

## 1. Bem-vindo ao Modding do Open Football!

O Open Football foi construído para ser a sua tela em branco. Você pode recriar o Brasileirão, a Champions League, copas históricas de 1970 ou ligas totalmente fictícias de fantasia.

Você **não precisa saber programar**. Basta editar arquivos JSON e colocar imagens em pastas.

---

## 2. Onde os Mods Moram

Todos os mods criados pelos jogadores devem ser colocados na pasta de usuário da Godot:

- **Linux:** `~/.local/share/godot/app_userdata/open-football/mods/`
- **Windows:** `%APPDATA%\Godot\app_userdata\open-football\mods\`
- **macOS:** `~/Library/Application Support/Godot/app_userdata/open-football/mods/`

Crie uma subpasta para o seu mod, por exemplo:
`mods/brasileirao_2026/`

---

## 3. Passo 1: Criando o Manifesto (`mod.json`)

Dentro da sua pasta `mods/brasileirao_2026/`, crie o arquivo `mod.json`:

```json
{
  "id": "mod-brasileirao-2026",
  "name": "Campeonato Brasileiro Série A 2026",
  "version": "1.0.0",
  "author": "Comunidade BR",
  "description": "20 clubes oficiais, elencos atualizados e uniformes.",
  "target_engine_version": "0.1.0",
  "priority": 10
}
```

> **Dica sobre Prioridade:** O campo `"priority": 10` garante que os seus arquivos tenham precedência sobre o jogo base.

---

## 4. Passo 2: Criando um Clube Personalizado

Crie a pasta `mods/brasileirao_2026/clubs/` e adicione um arquivo, ex: `santos_fc.json`:

```json
{
  "id": "club-santos-fc",
  "name": "Santos Futebol Clube",
  "short_name": "Santos",
  "country": "BR",
  "city": "Santos",
  "reputation": 72,
  "colors": {
    "primary": "#000000",
    "secondary": "#FFFFFF",
    "accent": "#FFD700"
  },
  "facilities": {
    "stadium_id": "facility-vila-belmiro"
  },
  "finances": {
    "balance": 1500000,
    "ticket_price": 40
  },
  "squad": [
    "player-neymar-jr",
    "player-menino-da-vila-10"
  ]
}
```

---

## 5. Passo 3: Adicionando Jogadores

Crie a pasta `mods/brasileirao_2026/players/` e adicione os atletas em formato JSON. Lembre-se: os atributos devem ficar sempre entre **1 e 99**.

---

## 6. Passo 4: Substituindo Imagens e Sprites

Se quiser que o estádio do seu clube tenha um visual único em pixel art:
1. Crie a pasta `mods/brasileirao_2026/assets/stadiums/`.
2. Adicione sua imagem PNG (ex: `vila_belmiro_lvl1.png`).
3. No arquivo `facility.json`, aponte para o caminho relativo:
   `"texture_path": "assets/stadiums/vila_belmiro_lvl1.png"`.

A engine carregará a sua imagem automaticamente!
