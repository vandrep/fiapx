# Documentação de domínio

Como as engineering skills devem consumir a documentação de domínio deste repositório.

## Antes de explorar, leia

- `CONTEXT.md` na raiz; ou
- `CONTEXT-MAP.md` na raiz, se existir, apontando para um `CONTEXT.md` por contexto;
- ADRs relevantes em `docs/adr/`; em repositórios multi-context, verifique também `src/<context>/docs/adr/`.

Se algum desses arquivos não existir, prossiga silenciosamente. Não sinalize a ausência nem sugira sua criação antecipada. A skill `/domain-modeling`, alcançada por `/grill-with-docs` e `/improve-codebase-architecture`, cria esses artefatos sob demanda quando termos ou decisões forem realmente resolvidos.

## Estrutura de arquivos

Este repositório adota o layout single-context:

```text
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

## Use o vocabulário do glossário

Ao nomear um conceito de domínio em uma issue, proposta, hipótese ou teste, use o termo definido em `CONTEXT.md`. Não derive para sinônimos que o glossário evite explicitamente.

Se o conceito necessário não estiver no glossário, reavalie se o termo foi inventado ou registre a lacuna para `/domain-modeling`.

## Sinalize conflitos com ADRs

Se uma saída contradizer uma ADR existente, torne o conflito explícito em vez de sobrescrever silenciosamente:

> _Contradiz ADR-0007 (pedidos orientados a eventos), mas vale reabrir porque…_
