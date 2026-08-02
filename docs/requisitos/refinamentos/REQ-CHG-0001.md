---
context_id: REQ-CHG-0001
context_type: requirement_change
status: registrado
recorded_at: 2026-08-01
valid_from: 2026-08-01
refined_by: nao_registrado
recorded_by: nao_registrado
relations:
  - type: affects
    target: US-01
  - type: affects
    target: US-02
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
  - type: derived_from
    target: docs/enunciado.md
  - type: governed_by
    target: CTX-GOV-003
---

# REQ-CHG-0001 — Registro inicial das histórias

## Procedência

Este registro reconstrói o ponto inicial observável do conjunto [`CTX-REQ-001`](../historias.md). A data vem dos metadados do conjunto e a fonte é o [enunciado](../../enunciado.md). As evidências disponíveis não permitem distinguir com segurança quem realizou e quem materializou o refinamento inicial; por isso ambos os atores permanecem `nao_registrado`.

## Alterações

| História | Alteração semântica | Classificação anterior | Classificação resultante | Evidência | Confirmação |
|---|---|---|---|---|---|
| [`US-01`](../historias.md#us-01) | Registrou a necessidade de autenticação para proteger funcionalidades e recursos do usuário | Ausente | `Declarada` | [Enunciado](../../enunciado.md) | Não registrada |
| [`US-02`](../historias.md#us-02) | Registrou o envio de vídeo e a identificação do trabalho | Ausente | `Declarada`; detalhes `Inferidos` | [Enunciado](../../enunciado.md) | Não registrada |
| [`US-03`](../historias.md#us-03) | Registrou processamento concorrente de vídeos | Ausente | `Declarada`; isolamento `Inferido` | [Enunciado](../../enunciado.md) | Não registrada |
| [`US-04`](../historias.md#us-04) | Registrou preservação de trabalhos aceitos diante de picos e falhas | Ausente | `Declarada`; recuperação `Inferida` | [Enunciado](../../enunciado.md) | Não registrada |
| [`US-05`](../historias.md#us-05) | Registrou consulta dos próprios trabalhos e estados | Ausente | `Declarada`; estados `Inferidos` | [Enunciado](../../enunciado.md) | Não registrada |
| [`US-06`](../historias.md#us-06) | Registrou o download do resultado produzido | Ausente | `Declarada`; propriedade `Inferida` | [Enunciado](../../enunciado.md) | Não registrada |
| [`US-07`](../historias.md#us-07) | Registrou a possibilidade de notificação sobre falha | Ausente | `Declarada como possibilidade` | [Enunciado](../../enunciado.md) | Não registrada |

## Limite da reconstrução

O registro preserva somente o estado semântico recuperável. O histórico do Git continua sendo a evidência da edição física e não foi usado para atribuir autoridade de negócio.
