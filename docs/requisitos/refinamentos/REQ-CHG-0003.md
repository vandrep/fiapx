---
context_id: REQ-CHG-0003
context_type: requirement_change
status: registrado
recorded_at: 2026-08-03
valid_from: 2026-08-03
refined_by: analista_negocio
recorded_by: agente_principal
confirmed_by: responsavel_produto
confirmed_at: 2026-08-03
relations:
  - type: affects
    target: US-03
  - type: affects
    target: US-04
  - type: affects
    target: US-05
  - type: affects
    target: US-06
  - type: affects
    target: US-07
  - type: informed_by
    target: R6-REQ-001
  - type: governed_by
    target: CTX-GOV-003
---

# REQ-CHG-0003 — Consolidação conservadora da proposta R6

## Procedência

O Analista de Negócio confrontou as dez [histórias propostas em `R6-REQ-001`](../../propostas/base-simplificada-seis-componentes/historias.md) com as sete [histórias canônicas](../historias.md). O responsável pelo produto confirmou em 3 de agosto de 2026 a consolidação conservadora registrada abaixo: sobreposições preservam `US-01..07`, comportamentos já existentes não viram novas histórias e candidatas futuras não são promovidas.

## Alterações

| História | Alteração semântica | Classificação anterior | Classificação resultante | Evidência | Confirmação |
|---|---|---|---|---|---|
| [`US-03`](../historias.md#us-03) | Explicitou a extração de imagens como valor do processamento de [`R6-US-05`](../../propostas/base-simplificada-seis-componentes/historias.md#r6-us-05), preservando concorrência controlada, isolamento e falha independente | Declarada; isolamento por trabalho `Inferido` | Declarada; isolamento por trabalho `Inferido` | [`R6-US-05`](../../propostas/base-simplificada-seis-componentes/historias.md#r6-us-05) e critérios existentes de [`US-03`](../historias.md#us-03) | `responsavel_produto`, 2026-08-03 |
| [`US-04`](../historias.md#us-04) | Reconheceu [`R6-US-07`](../../propostas/base-simplificada-seis-componentes/historias.md#r6-us-07) como o reprocessamento já previsto; preservou nova submissão, reentrega, retentativa automática e reprocessamento como conceitos distintos; manteve o cancelamento de `R6-US-08` como candidato futuro | Declarada; recuperação e duplicidade `Inferidas`; distinção entre submissão e retentativa `Validada na descoberta` | Declarada; recuperação e duplicidade `Inferidas`; distinção entre submissão e retentativa `Validada na descoberta` | [`R6-US-07`](../../propostas/base-simplificada-seis-componentes/historias.md#r6-us-07), [`R6-US-08`](../../propostas/base-simplificada-seis-componentes/historias.md#r6-us-08) e critérios existentes de [`US-04`](../historias.md#us-04) | `responsavel_produto`, 2026-08-03 |
| [`US-05`](../historias.md#us-05) | Consolidou [`R6-US-03`](../../propostas/base-simplificada-seis-componentes/historias.md#r6-us-03) como sobreposição da consulta e manteve motivo sanitizado e detalhe de falha de `R6-US-06` como `A confirmar` | Declarada; conjunto de estados `Inferido` | Declarada; conjunto de estados `Inferido` | [`R6-US-03`](../../propostas/base-simplificada-seis-componentes/historias.md#r6-us-03) e [`R6-US-06`](../../propostas/base-simplificada-seis-componentes/historias.md#r6-us-06) | `responsavel_produto`, 2026-08-03 |
| [`US-06`](../historias.md#us-06) | Consolidou o download em conjunto de [`R6-US-02`](../../propostas/base-simplificada-seis-componentes/historias.md#r6-us-02) sem retirar o ZIP obrigatório e manteve o download individual de `R6-US-10` como candidato futuro | Declarada; autorização por propriedade `Inferida` | Declarada; autorização por propriedade `Inferida` | [`R6-US-02`](../../propostas/base-simplificada-seis-componentes/historias.md#r6-us-02), [`R6-US-10`](../../propostas/base-simplificada-seis-componentes/historias.md#r6-us-10) e resultado ZIP de [`US-06`](../historias.md#us-06) | `responsavel_produto`, 2026-08-03 |
| [`US-07`](../historias.md#us-07) | Manteve a falha como núcleo da notificação; eventos de submissão, sucesso ou progresso de `R6-US-04` e configuração de preferências ou múltiplos canais de `R6-US-09` permanecem candidatas futuras | Declarada como possibilidade; opt-in, canal e garantias `A confirmar` | Declarada como possibilidade; opt-in, canal e garantias `A confirmar` | [`R6-US-04`](../../propostas/base-simplificada-seis-componentes/historias.md#r6-us-04), [`R6-US-09`](../../propostas/base-simplificada-seis-componentes/historias.md#r6-us-09) e núcleo de falha de [`US-07`](../historias.md#us-07) | `responsavel_produto`, 2026-08-03 |

## Sobreposições sem alteração semântica

[`R6-US-01`](../../propostas/base-simplificada-seis-componentes/historias.md#r6-us-01) já corresponde a [`US-02`](../historias.md#us-02), sem mudar admissão ou aceite recuperável. A autenticação de [`US-01`](../historias.md#us-01) permanece obrigatória apesar de ter sido adiada na proposta R6. Por não haver delta semântico nessas duas histórias, elas não recebem relação `affects` nem backlink para este registro.

## Questões e consequências preservadas

- Motivo sanitizado e nível de detalhe da falha na consulta continuam `A confirmar`.
- Cancelamento, download individual, notificações de submissão, sucesso ou progresso e configuração de preferências ou múltiplos canais permanecem candidatas futuras, sem prioridade ou aceite no incremento atual.
- Concorrência, não perda, tentativas, retentativa automática limitada, reprocessamento manual e entrega do ZIP permanecem no conjunto canônico.
