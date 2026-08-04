---
context_id: DEC-0000
context_type: decision
status: em_analise
recorded_at: "YYYY-MM-DD"
valid_from: "YYYY-MM-DD"
template: true
relations:
  - type: derived_from
    target: CTX-REQ-001
  - type: affects
    target: CTX-CMP-003
---

# DEC-0000 — Título da decisão

Ao copiar este modelo, substitua o ID e as datas e remova `template: true` para que o registro passe a ser validado como um nó real.

## Pergunta

Qual decisão precisa ser tomada e qual é seu escopo?

## Contexto e evidências

Descreva motivadores, restrições e evidências. Conecte as fontes nos metadados em vez de apenas mencioná-las sem relação.

## Características arquiteturais

Liste somente as características que diferenciam as opções, com escopo e forma de verificação.

## Opções e trade-offs

Compare as opções viáveis, incluindo manter o estado atual quando fizer sentido.

## Decisão

Enquanto o estado for `em_analise`, registre aqui a recomendação condicionada e o que falta para aceitá-la. Quando aceita, registre a escolha e o motivo determinante.

Antes de alterar o estado para `aceita`, revise nos nós diretamente citados as questões e marcações `A confirmar` que a decisão resolveu. Atualize a fonte ativa ou acrescente uma nota temporal à evidência histórica; não reescreva a descoberta anterior nem transforme uma escolha técnica em novo critério de negócio.

## Consequências

Registre benefícios, custos, riscos, dependências e impactos conhecidos.

## Validação e resultados

Defina como a decisão será verificada. Resultados relevantes devem ganhar identidade própria e uma relação `validated_by`, `contradicts` ou `produces`, conforme o caso.

## Condições de revisão

Liste sinais objetivos que devem reabrir a decisão.

## Histórico temporal

| Data | Estado | Alteração | Evidência ou responsável |
|---|---|---|---|
| YYYY-MM-DD | `em_analise` | Registro inicial da pergunta | A informar |
