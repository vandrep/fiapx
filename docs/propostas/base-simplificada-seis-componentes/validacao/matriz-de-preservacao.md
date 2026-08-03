---
context_id: R6-VAL-001
context_type: evidence
status: registrado
recorded_at: 2026-08-03
valid_from: 2026-08-03
relations:
  - type: informs
    target: R6-PROP-001
  - type: governed_by
    target: CTX-GOV-001
---

# Matriz de preservação

Esta matriz verifica que os resultados curados da conversa possuem destino no pacote. Ela não afirma preservar cada mensagem literalmente.

| Conteúdo a preservar | Fonte no pacote | Verificação |
|---|---|---|
| dez histórias e ator Usuário | [histórias](../historias.md#inventario) | dez IDs `R6-US-*` e formulação quem/o que/para quê |
| responsável principal único | [atribuição final](../componentes.md#atribuicao-final-das-historias) | validador compara inventário e tabela |
| seis componentes atuais | [inventário refinado](../componentes.md#inventario-refinado) | seis IDs `R6-CMP-*` |
| responsabilidades, exclusões e autoridades | [componentes](../componentes.md#inventario-refinado) | bloco completo por componente |
| responsabilidades sem componente | [seção explícita](../componentes.md#responsabilidades-sem-componente) | separa negócio, suporte e mecanismos |
| fluxo de acionamento | [diagramas](../diagramas.md#base-final-de-componentes) | Mermaid com submissão, processamento, entrega, gestão, visão e notificação |
| notificação de sucesso e falha | [`R6-US-04`](../historias.md#r6-us-04) | formulação e fatos de origem explícitos |
| estado, histórico, cancelamento, reprocessamento e disputas | [`R6-CMP-02`](../componentes.md#r6-cmp-02) | mesma autoridade comportamental |
| disponibilidade física na Entrega | [`R6-CMP-04`](../componentes.md#r6-cmp-04) | contrato com Gerenciar explícito |
| remoção de tentativas | [histórico](../historico-decisoes-e-sugestoes.md#linha-de-evolucao) | situação `nao_adotada_agora` e impacto mapeado |
| ZIP transferido para Entrega | [comparação](../comparacao-com-modelo-atual.md#componentes-canonicos) | `CMP-14` marcado como transferido |
| divisões avaliadas | [divisões condicionais](../historico-decisoes-e-sugestoes.md#divisoes-condicionais) | aceite, condição ou não adoção diferenciados |
| características e formato de cenário | [características](../caracteristicas-e-quanta.md#formato-sugerido) | estímulo, resposta, medida e fitness function |
| alternativas de quanta | [quanta candidatos](../caracteristicas-e-quanta.md#alternativas-candidatas-de-quanta) | A, B e C continuam hipóteses |
| diferenças para o canônico | [comparação](../comparacao-com-modelo-atual.md) | `US-01..07` e `CMP-05..17` mapeados |
| decisões aceitas e não aceitas | [histórico](../historico-decisoes-e-sugestoes.md) | situações possuem semântica definida |
| continuidade em outro computador | [README](../README.md#como-retomar) e [roadmap](../acompanhamento/roadmap.md) | base Git, leitura, validação e próximo item explícitos |
| histórico do roadmap | [histórico local](../acompanhamento/historico.md) | eventos append-only e itens concluídos separados |

## Limites conhecidos

- O pacote não contém transcrição literal nem autoria nominal além do papel “usuário”.
- Questões sem confirmação continuam abertas; não foram convertidas em requisitos.
- Diagramas expressam relações lógicas, não contratos físicos ou topologia.
- O commit que contém este pacote preserva a evidência temporal do Git; o autor do commit não substitui a autoridade semântica.
