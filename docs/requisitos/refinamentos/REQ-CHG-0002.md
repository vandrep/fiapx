---
context_id: REQ-CHG-0002
context_type: requirement_change
status: registrado
recorded_at: 2026-08-02
valid_from: 2026-08-02
refined_by: agente_principal
recorded_by: agente_principal
confirmed_by: responsavel_produto
confirmed_at: 2026-08-02
relations:
  - type: affects
    target: US-01
  - type: affects
    target: US-02
  - type: affects
    target: US-04
  - type: affects
    target: US-05
  - type: affects
    target: US-06
  - type: affects
    target: US-07
  - type: derived_from
    target: WORK-009
  - type: informed_by
    target: CTX-DOM-002
  - type: governed_by
    target: CTX-GOV-003
---

# REQ-CHG-0002 — Refinamento do WORK-009

## Procedência

O agente principal refinou e registrou as respostas confirmadas pelo responsável pelo produto durante [`WORK-008`](../../acompanhamento/realizacoes.md#work-008--conduzir-event-storming-enxuto) e incorporadas por [`WORK-009`](../../acompanhamento/realizacoes.md#work-009--incorporar-descobertas-do-event-storming). O quadro validado de [`CTX-DOM-002`](../event-storming.md) preserva a evidência de descoberta.

## Alterações

| História | Alteração semântica | Classificação anterior | Classificação resultante | Evidência | Confirmação |
|---|---|---|---|---|---|
| [`US-01`](../historias.md#us-01) | Delimitou autogestão de credenciais e dados como direção futura, mantendo provisionamento e primeiro recorte pendentes | Fora do ciclo sem direção registrada | Direção `Validada na descoberta`; recorte `A confirmar` | [Resultado da descoberta](../event-storming.md#resultado-da-revisão-das-questões) | `responsavel_produto`, 2026-08-02 |
| [`US-02`](../historias.md#us-02) | Fez todas as validações aplicáveis precederem a aceitação, permitiu rejeição antecipada segura e distinguiu cota acumulada de limites operacionais | Política de admissão e limites `A confirmar` | Regra `Validada na descoberta`; valores `A confirmar` | [Resultado da descoberta](../event-storming.md#resultado-da-revisão-das-questões) | `responsavel_produto`, 2026-08-02 |
| [`US-04`](../historias.md#us-04) | Distinguiu reentrega duplicada, retentativa automática limitada por ciclo e reprocessamento solicitado sem nova submissão | Semântica de tentativa `A confirmar` | Distinção `Validada na descoberta`; mecanismo e valores `A confirmar` | [Resultado da descoberta](../event-storming.md#resultado-da-revisão-das-questões) | `responsavel_produto`, 2026-08-02 |
| [`US-05`](../historias.md#us-05) | Removeu `RECEBIDO` dos estados consultáveis, preservou histórico entre reprocessamentos e retirou expiração automática atual | Estados e retenção `A confirmar` | Estados candidatos `Inferidos`; retenção `Validada na descoberta` | [Histórias incorporadas pelo WORK-009](../historias.md#us-05) | `responsavel_produto`, 2026-08-02 |
| [`US-06`](../historias.md#us-06) | Substituiu prazo pendente por ausência atual de expiração automática de origem, resultado e histórico | Retenção `A confirmar` | `Validada na descoberta` | [Resultado da descoberta](../event-storming.md#resultado-da-revisão-das-questões) | `responsavel_produto`, 2026-08-02 |
| [`US-07`](../historias.md#us-07) | Separou rejeição síncrona de admissão da comunicação assíncrona posterior à aceitação e manteve transporte pendente | Canal e momento `A confirmar` | Momento `Validado na descoberta`; transporte `A confirmar` | [Resultado da descoberta](../event-storming.md#resultado-da-revisão-das-questões) | `responsavel_produto`, 2026-08-02 |

## Questões preservadas

Valores de admissão e capacidade, política concreta do ciclo automático, atomicidade da aceitação, provisionamento de contas e transporte de atualização continuam `A confirmar`; o refinamento não os promoveu a requisitos aceitos.
