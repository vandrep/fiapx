---
context_id: CTX-EXP-HARNESS-001
context_type: experiment
status: registrado
recorded_at: 2026-08-16
valid_from: 2026-08-16
relations:
  - type: informed_by
    target: CTX-EVD-HARNESS-004
  - type: affects
    target: WORK-022
  - type: affects
    target: WORK-027
  - type: governed_by
    target: CTX-GOV-001
  - type: governed_by
    target: CTX-GOV-002
---

# Comparação pareada entre os contratos v1 e v2

> Navegação: [contrato do harness](../README.md) · [evolução v2](../v2.md) · [roadmap](../../../acompanhamento/roadmap.md)

## Pergunta e limite causal

Verificar se v1 e v2 preservam aprovação semântica, ausência de retrabalho e comportamento de navegação comparável no mesmo estado do repositório. Os três cenários compartilhados reutilizam os mesmos prompts, schemas e assertions; v2 acrescenta apenas `EVAL-HARNESS-ARCH-001`. Por isso, diferenças nos cenários compartilhados serão tratadas como variabilidade observada ou possível efeito colateral do contrato consultável, não como efeito causal do mapa arquitetural.

O benefício próprio do mapa será avaliado separadamente pelo cenário arquitetural: recuperar o estado vigente na primeira tentativa, consultar no máximo sete fontes, usar `ARCHITECTURE.md` e não promover o modelo histórico.

## Protocolo congelado antes da coleta

- Executar o controle v1 e o candidato v2 no mesmo commit limpo.
- Usar `codex-cli 0.147.0`, `gpt-5.6-sol`, esforço `low` e sandbox `read-only`.
- Executar três suítes completas de cada contrato, sem `--fail-fast`.
- Exigir aprovação automática e revisão semântica, zero amostras censuradas e zero retrabalho.
- Comparar `TM`, `ADR` e `GRAPH` por cenário; não comparar o agregado das suítes, pois v2 possui um cenário adicional.
- Registrar mínimo, mediana e máximo de fontes, duração, tokens de entrada, entrada não cacheada e caracteres devolvidos por comandos.
- Manter eventos, respostas e saídas brutas fora do repositório; normalizar métricas, hashes e conclusão.

## Critério de interpretação

- `EVAL-HARNESS-ARCH-001` sustenta a navegação arquitetural se passar `3/3`, sem retrabalho e com até sete fontes em cada amostra.
- Uma mediana menor nos cenários compartilhados é apenas descritiva, pois não existe intervenção distinta nos seus prompts, schemas ou assertions e três amostras não estimam a variabilidade com precisão.
- A hipótese ampla de que o mapa reduz fontes será marcada como não demonstrada se depender apenas da diferença v1/v2 nos cenários compartilhados.
- Qualquer reprovação, censura, mudança de manifesto entre os lotes ou divergência de versão torna a comparação inelegível e aciona o Meta-PDCA.

## Comandos previstos

```bash
HARNESS_CODEX_BIN=tools/codex-telemetry/node_modules/.bin/codex bash scripts/avaliar-harness.sh run --contract scenarios.json --repeat 3 --label pareado-v1-2026-08-16 --output-dir /tmp/fiapx-harness-pareado-v1-2026-08-16
HARNESS_CODEX_BIN=tools/codex-telemetry/node_modules/.bin/codex bash scripts/avaliar-harness.sh run --contract scenarios-v2.json --repeat 3 --label pareado-v2-2026-08-16 --output-dir /tmp/fiapx-harness-pareado-v2-2026-08-16
```

## Meta-PDCA da pré-inscrição

A primeira validação rejeitou a relação `informed_by CTX-EVD-HARNESS-004`: o ID existia no JSON normalizado, mas ainda não estava registrado como entidade do nó agregador do harness. A causa foi normalizar a evidência fora do conjunto de arquivos Markdown percorrido pelo Context Graph sem exigir seu registro no agregador. `CTX-EVD-HARNESS-004` foi acrescentado às entidades de `CTX-EVD-HARNESS-001`, e o self-test agora reprova uma evidência multiexecução cujo ID não esteja registrado ali. A regressão deve reaplicar tanto `scripts/validar-harness.sh check` quanto `scripts/validar-contexto.sh`.
