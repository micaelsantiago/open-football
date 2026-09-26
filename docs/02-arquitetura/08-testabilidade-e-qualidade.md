# Arquitetura — Testabilidade e Qualidade

> **Documento:** `docs/arquitetura/08-testabilidade-e-qualidade.md`  
> **Status:** Especificação Técnica / V1  
> **Escopo:** Pirâmide de testes automatizados, simulações em massa (Monte Carlo) e execução em CI  

---

## 1. Filosofia de Qualidade

Como o Open Football é um simulador com dezenas de variáveis econômicas e probabilísticas, **testes manuais são insuficientes** para garantir que uma alteração em atributos de atacantes não quebre a economia inteira do jogo 5 temporadas depois.

A testabilidade é garantida pela separação rígida do Core:

> **Todo o domínio roda em modo headless (sem janela gráfica, sem som e sem nós de cena) na linha de comando da Godot.**

---

## 2. Pirâmide de Testes Automatizados

```
                    / \
                   /   \
                  /     \
                 /  E2E  \       ──► 5% (Loop da UI e Navegação da Câmera)
                /─────────\
               /           \
              /  SIMULAÇÃO  \    ──► 25% (100 Temporadas Monte Carlo)
             /   INTEGRAÇÃO  \
            /─────────────────\
           /                   \
          /      UNITÁRIOS      \ ──► 70% (Fórmulas, Saves, Grid, Finanças)
         /───────────────────────\
```

---

## 3. Testes Unitários de Domínio (`tests/unit/`)

Classes puras testadas com asserções rápidas:

```gdscript
# Exemplo: Teste do Conversor Isométrico (tests/unit/test_isometric_grid.gd)
class_name TestIsometricGrid
extends RefCounted

static func run_tests() -> bool:
    var test_coord := Vector2i(5, 3)
    var world_pos := IsometricGridHelper.grid_to_world(test_coord)
    var back_to_grid := IsometricGridHelper.world_to_grid(world_pos)
    
    assert(back_to_grid == test_coord, "Erro de conversão simétrica no Grid Isométrico!")
    print("[PASS] TestIsometricGrid: Conversão simétrica bidirecional validada.")
    return true
```

---

## 4. Testes de Simulação em Massa (Método de Monte Carlo)

Para calibrar a física matemática do motor de jogo, o script `tests/simulation/stress_season.gd` simula **100 temporadas completas em lote** e valida as métricas médias da simulação:

### 4.1 Métricas de Aceite Estatístico (Validadas pelo Test Runner)
- **Média de Gols por Partida:** Deve se manter entre **$2.2$ e $3.2$ gols**.
- **Equilíbrio de Empates:** Deve representar entre **$20\%$ e $28\%$** dos jogos.
- **Taxa de Vitórias do Mandante:** Deve oscilar entre **$44\%$ e $52\%$** (efeito fator casa calibrado).
- **Sem Quebras Financeiras Extremas:** Nenhum clube de IA deve atingir saldo negativo superior a 5 vezes sua folha salarial anual.

---

## 5. Execução em Linha de Comando (Headless CI)

Qualquer desenvolvedor ou esteira de CI (GitHub Actions) pode rodar a suíte completa com um único comando no terminal:

```bash
/home/micael/Downloads/Godot_v4.7.2-stable_linux.x86_64 --headless -s tests/test_runner.gd
```

O comando executa todos os testes unitários e de simulação em menos de **3 segundos** e retorna código `0` em caso de sucesso ou `1` em caso de quebra de contrato.
