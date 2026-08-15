---
context_id: DEC-0006
context_type: decision
status: em_analise
recorded_at: 2026-08-15
valid_from: 2026-08-15
relations:
  - type: motivated_by
    target: https://developers.openai.com/api/docs/guides/latest-model
  - type: informed_by
    target: CTX-EVD-HARNESS-001
  - type: affects
    target: WORK-018
  - type: affects
    target: WORK-022
  - type: governed_by
    target: CTX-GOV-001
  - type: governed_by
    target: CTX-GOV-002
---

# DEC-0006 — Separação do oráculo do harness

## Contexto

Os contratos v1/v2 fornecem schemas de Structured Outputs com valores esperados em `const`, `enum` e limites de cardinalidade. Mesmo sem ler fixtures ou assertions, o processo avaliado recebe parte da resposta pelo schema. Isso reduz a validade de um experimento que pretende medir descoberta do contexto.

A [OpenAI Docs](https://developers.openai.com/api/docs/guides/latest-model) recomenda remover um grupo de instruções ou ferramentas por vez e comparar sucesso, completude, tokens, latência e custo em tarefas representativas; menor consumo só conta como melhoria quando a resposta continua aprovada.

## Decisão em análise

Preservar v1/v2 como evidência histórica e experimentar em v3 três fronteiras:

- prompt e schema estrutural formam a especificação pública recebida pelo processo avaliado;
- assertions, fixtures e resultados formam o oráculo privado usado somente pelo graduador;
- eventos registram tentativas de acesso aos artefatos vedados e tornam a amostra inelegível.

V3 permanece opt-in. A fiscalização de comandos e saídas detecta acesso depois do fato, mas não fornece isolamento de filesystem; por isso ainda não sustenta aceitar a decisão.

## Alternativas e trade-offs

| Alternativa | Benefício | Custo ou risco |
|---|---|---|
| Reutilizar schemas v1/v2 | Comparação e implementação simples | valores esperados continuam expostos |
| Schema estrutural mais fiscalização — experimento atual | reduz vazamento sem duplicar todo o runner | detecção não equivale a impedir leitura |
| Snapshot filtrado sem oráculo | isolamento forte | pode divergir do worktree real e alterar comportamento de navegação ou Git |

## Validação e promoção

A [avaliação v3](../../avaliacoes/harness/v3.md) deve provar aprovação semântica, ausência de acesso vedado e redução mensurável em três execuções completas. Um contrafactual schema-valid com conteúdo incorreto precisa continuar reprovado pelas assertions.

## Condições de revisão

- O CLI oferecer negação nativa de caminhos ou raiz de avaliação filtrada sem perder fidelidade.
- A fiscalização produzir falsos positivos por referências incidentais aos caminhos vedados.
- A remoção de valores do schema reduzir a taxa de aprovação sem diminuir descoberta indevida.
