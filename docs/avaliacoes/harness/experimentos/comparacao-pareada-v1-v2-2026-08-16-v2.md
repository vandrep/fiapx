---
context_id: CTX-EXP-HARNESS-002
context_type: experiment
status: registrado
recorded_at: 2026-08-16
valid_from: 2026-08-16
relations:
  - type: supersedes
    target: CTX-EXP-HARNESS-001
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

# Comparação pareada v1/v2 com limite por tentativa

> Navegação: [pré-inscrição anterior](comparacao-pareada-v1-v2-2026-08-16.md) · [contrato do harness](../README.md) · [roadmap](../../../acompanhamento/roadmap.md)

## Motivo da sucessão

A primeira coleta de `CTX-EXP-HARNESS-001` tornou-se inelegível: `EVAL-HARNESS-GRAPH-001` iniciou uma thread, mas não produziu outro evento por mais de dez minutos. O runner não possuía timeout por tentativa e continuaria as repetições após a falha de infraestrutura. A execução foi interrompida, seus resultados parciais permaneceram somente em `/tmp/fiapx-harness-pareado-v1-2026-08-16` e nenhuma amostra será reutilizada.

## Protocolo preservado e correção operacional

Permanecem válidos a pergunta, o limite causal, os cenários comparáveis, as métricas e os critérios de interpretação de `CTX-EXP-HARNESS-001`. Esta sucessora acrescenta:

- limite de `600` segundos para cada chamada inicial ou retomada do Codex;
- término de todo o lote após timeout, outra falha de infraestrutura ou mudança do manifesto;
- nova coleta completa de v1 e v2, sem reaproveitar respostas da tentativa inelegível;
- execução no mesmo commit limpo posterior à correção do runner e a esta pré-inscrição.

## Comandos previstos

```bash
HARNESS_CODEX_BIN=tools/codex-telemetry/node_modules/.bin/codex bash scripts/avaliar-harness.sh run --contract scenarios.json --repeat 3 --attempt-timeout-seconds 600 --label pareado2-v1-2026-08-16 --output-dir /tmp/fiapx-harness-pareado2-v1-2026-08-16
HARNESS_CODEX_BIN=tools/codex-telemetry/node_modules/.bin/codex bash scripts/avaliar-harness.sh run --contract scenarios-v2.json --repeat 3 --attempt-timeout-seconds 600 --label pareado2-v2-2026-08-16 --output-dir /tmp/fiapx-harness-pareado2-v2-2026-08-16
```

## Meta-PDCA

- **Falha:** uma chamada permaneceu indefinidamente entre `turn.started` e qualquer evento subsequente; a repetição seguinte começou após a interrupção manual.
- **Causa no produto:** `avaliar-harness.sh` não limitava a duração de `codex exec` ou `exec resume` e só encerrava repetições por `--fail-fast`.
- **Causa no processo:** o self-test cobria saída ausente e falha do binário, mas não simulava timeout nem verificava término do lote após falha de infraestrutura.
- **Correção:** cada tentativa passa por `timeout`, recebe código específico `RUNTIME-CODEX-TIMEOUT` ou `RUNTIME-CODEX-RESUME-TIMEOUT`, e uma iteração com falha de infraestrutura encerra o lote independentemente de `--fail-fast`.
- **Regressão exigida:** contrafactuais devem provar a classificação do exit code `124`, a preservação dos demais códigos de saída e a interrupção de um lote de múltiplas repetições após falha de infraestrutura.
