---
context_id: R6-PROP-001
context_type: proposal_package
status: em_analise
recorded_at: 2026-08-03
valid_from: 2026-08-03
relations:
  - type: derived_from
    target: CTX-REQ-001
  - type: informed_by
    target: CTX-CMP-002
  - type: informed_by
    target: CTX-CHAR-001
  - type: governed_by
    target: CTX-GOV-001
---

# Base simplificada de seis componentes

## Finalidade e precedência

Este diretório preserva, de forma autocontida, o refinamento conduzido na conversa de 3 de agosto de 2026. Ele registra histórias, responsabilidades, decisões, alternativas e próximos passos para que o trabalho possa continuar em outro computador.

O pacote é uma **proposta em análise**. Não substitui o conjunto canônico de [histórias `CTX-REQ-001`](../../requisitos/historias.md), o [modelo de componentes `CTX-CMP-002`](../../arquitetura/componentes.md), as [características `CTX-CHAR-001`](../../arquitetura/caracteristicas.md) nem o [roadmap oficial](../../acompanhamento/roadmap.md). Em caso de divergência, esses artefatos canônicos prevalecem até uma promoção explícita.

Base Git usada na consolidação: `b71c41478d93bff247bc7412bf3721b808bee070`.

## Conteúdo

1. [Histórias propostas](historias.md) — dez histórias locais, com responsável principal único.
2. [Componentes propostos](componentes.md) — seis fronteiras lógicas, autoridades e contratos.
3. [Diagramas](diagramas.md) — evolução visual e fluxo final em Mermaid, renderizável pelo yFiles da interface.
4. [Comparação com o modelo atual](comparacao-com-modelo-atual.md) — rastreabilidade para `US-01..07` e `CMP-05..17`.
5. [Histórico de decisões e sugestões](historico-decisoes-e-sugestoes.md) — aceites, substituições, adiamentos e opções ainda abertas.
6. [Características e quanta](caracteristicas-e-quanta.md) — pressões sistêmicas e três alternativas candidatas.
7. [Roadmap local](acompanhamento/roadmap.md) e seu [histórico append-only](acompanhamento/historico.md).
8. [Matriz de preservação](validacao/matriz-de-preservacao.md) e [validador do pacote](validacao/validar-pacote.sh).

## Identificadores e alcance

Os IDs `R6-*` pertencem somente a esta proposta:

- `R6-US-*`: histórias propostas;
- `R6-CMP-*`: componentes propostos;
- `R6-CA-*`: características priorizadas nesta análise;
- `R6-WORK-*`: itens do roadmap local.

Eles não reutilizam identidades canônicas e não afirmam que houve adoção na arquitetura corrente. `Aceita na conversa` significa apenas que a formulação foi confirmada pelo usuário durante este refinamento.

## Como retomar

1. Leia este arquivo e o [histórico de decisões](historico-decisoes-e-sugestoes.md).
2. Confirme se a proposta continua sendo a base desejada.
3. Execute `bash docs/propostas/base-simplificada-seis-componentes/validacao/validar-pacote.sh`.
4. Siga o próximo item do [roadmap local](acompanhamento/roadmap.md).

## Como promover

Uma promoção futura deve ser tratada como nova mudança, não como edição silenciosa deste histórico:

1. confirmar histórias, vocabulário e critérios ainda abertos com a autoridade de produto;
2. consultar os papéis especializados exigidos pelo repositório;
3. criar registros de mudança e/ou decisão com relações para os artefatos canônicos afetados;
4. atualizar as fontes canônicas e seus backlinks;
5. executar as validações do Context Graph e do ciclo de componentes.
