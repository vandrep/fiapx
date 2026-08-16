---
context_id: CTX-EXP-HARNESS-003
context_type: experiment
status: registrado
recorded_at: 2026-08-16
valid_from: 2026-08-16
relations:
  - type: supersedes
    target: CTX-EXP-HARNESS-002
  - type: informed_by
    target: CTX-EVD-HARNESS-004
  - type: affects
    target: WORK-022
  - type: affects
    target: WORK-027
  - type: affects
    target: DEC-0006
  - type: governed_by
    target: CTX-GOV-001
  - type: governed_by
    target: CTX-GOV-002
---

# Comparação pareada v1/v2 após correção de falso positivo

> Navegação: [protocolo com timeout](comparacao-pareada-v1-v2-2026-08-16-v2.md) · [DEC-0006](../../../arquitetura/decisoes/0006-separacao-do-oraculo-do-harness.md) · [roadmap](../../../acompanhamento/roadmap.md)

## Motivo da sucessão

A coleta de `CTX-EXP-HARNESS-002` executou as três suítes v1, mas somente a primeira passou. Em `ADR` e `GRAPH`, o comando `rg` usou `--glob '!docs/referencia/projeto-original/**'` para excluir explicitamente a fonte vedada; a fiscalização textual interpretou o fragmento como acesso e reprovou as respostas mesmo após duas correções. O lote é inelegível e permanece somente em `/tmp/fiapx-harness-pareado2-v1-2026-08-16`.

O caso materializa a condição de revisão da `DEC-0006` sobre falsos positivos por referências incidentais. Ele não demonstra acesso ao oráculo nem falha semântica das respostas.

## Protocolo preservado e correção

Permanecem válidos o protocolo causal de `CTX-EXP-HARNESS-001` e o limite operacional de `CTX-EXP-HARNESS-002`. A fiscalização agora remove ocorrências literais `!CAMINHO_VEDADO` antes de procurar acesso ao mesmo fragmento no comando. Se o comando também mencionar o caminho fora da exclusão, a ocorrência restante continua reprovada.

Antes da nova coleta, o self-test deve provar que:

- acesso direto ao caminho vedado reprova;
- `--glob '!CAMINHO_VEDADO/**'` sem outra ocorrência passa;
- timeout recebe código específico e encerra o lote.

Toda a coleta será refeita em novo commit limpo, sem reutilizar amostras das duas tentativas inelegíveis.

## Comandos previstos

```bash
HARNESS_CODEX_BIN=tools/codex-telemetry/node_modules/.bin/codex bash scripts/avaliar-harness.sh run --contract scenarios.json --repeat 3 --attempt-timeout-seconds 600 --label pareado3-v1-2026-08-16 --output-dir /tmp/fiapx-harness-pareado3-v1-2026-08-16
HARNESS_CODEX_BIN=tools/codex-telemetry/node_modules/.bin/codex bash scripts/avaliar-harness.sh run --contract scenarios-v2.json --repeat 3 --attempt-timeout-seconds 600 --label pareado3-v2-2026-08-16 --output-dir /tmp/fiapx-harness-pareado3-v2-2026-08-16
```

## Meta-PDCA

- **Causa no produto:** a fiscalização usava `contains(CAMINHO_VEDADO)` sobre a linha de comando inteira e não distinguia seleção de exclusão.
- **Causa no processo:** o self-test possuía caso positivo de vazamento, mas nenhum controle negativo com um filtro de exclusão legítimo.
- **Correção:** remover apenas ocorrências precedidas literalmente por `!` antes da inspeção e manter a detecção sobre qualquer ocorrência restante.
- **Prevenção:** os dois contrafactuais passam a fazer parte do self-test executado no preflight de toda coleta.
