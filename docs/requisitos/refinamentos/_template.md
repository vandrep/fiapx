---
context_id: REQ-CHG-0000
context_type: requirement_change
status: registrado
recorded_at: "YYYY-MM-DD"
valid_from: "YYYY-MM-DD"
refined_by: analista_negocio
recorded_by: agente_principal
template: true
relations:
  - type: affects
    target: US-00
  - type: governed_by
    target: CTX-GOV-003
---

# REQ-CHG-0000 — Título do refinamento

> Navegação: [refinamentos de requisitos](README.md) · [histórias](../historias.md)

Remova `template: true`, substitua IDs, atores e datas e acrescente `confirmed_by` e `confirmed_at` somente quando houver confirmação do responsável pelo produto.

## Alterações

| História | Alteração semântica | Classificação anterior | Classificação resultante | Evidência | Confirmação |
|---|---|---|---|---|---|
| [`US-00`](../historias.md) | Descrever o que mudou, sem copiar o diff | `A confirmar` | `Validada na descoberta` | Fonte navegável | Responsável e data, ou `Não confirmada` |

## Questões e consequências

Registre somente dúvidas e impactos produzidos pelo refinamento. Não transforme uma possibilidade futura em requisito corrente.
