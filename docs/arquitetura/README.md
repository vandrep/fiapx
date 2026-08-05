# Arquitetura

> Navegação: [documentação](../README.md) · [README principal](../../README.md)

Este diretório guarda artefatos específicos da arquitetura do projeto. As instruções agnósticas permanecem na [configuração do agente de arquitetura](../../.codex/agents/arquiteto.toml), e o estado do FIAP X está no [contexto do projeto](../contexto-projeto.md).

Identidade, relações, procedência e validade temporal seguem a [convenção de contexto](../contexto/README.md).

<a id="evolucao-dos-componentes"></a>

## Evolução dos componentes

| Período | Situação | Artefato | Uso atual |
|---|---|---|---|
| desde 2026-08-03 | **vigente** | [`CTX-CMP-003` — oito componentes coesos](componentes-coesos.md) | fonte canônica de fronteiras, autoridades e contratos lógicos |
| ciclo de 2026-08-03 | histórico | [`CTX-EVD-CMP-003` — evidência do refinamento](historico/componentes/ctx-cmp-003-refinamento.md) | explica como o modelo vigente foi derivado |
| 2026-08-02 a 2026-08-03 | substituído | [`CTX-CMP-002` — treze componentes modulares](historico/componentes/ctx-cmp-002-componentes-modulares.md) | snapshot histórico preservado |
| 2026-08-01 a 2026-08-02 | substituído | [`CTX-CMP-001` — quatro componentes macro](historico/componentes/ctx-cmp-001-componentes-macro.md) | snapshot histórico preservado |

Para saber **o que vale hoje**, leia somente `CTX-CMP-003` e os ADRs citados por ele. Consulte a evidência ou os modelos substituídos apenas para investigar procedência, alternativas ou razões de uma fronteira.

## Autoridades documentais

| Pergunta | Fonte |
|---|---|
| Quais são os componentes e suas responsabilidades? | [`CTX-CMP-003`](componentes-coesos.md) |
| Por que oito componentes foram aceitos? | [`DEC-0004`](decisoes/0004-componentes-coesos-do-nucleo.md) e [`CTX-EVD-CMP-003`](historico/componentes/ctx-cmp-003-refinamento.md) |
| Como os componentes são implantados para validação? | [`DEC-0002`](decisoes/0002-topologia-kubernetes.md) |
| Como persistência e mensageria podem ser realizadas? | [`DEC-0003`](decisoes/0003-entrega-duravel-e-persistencia.md), ainda `em_analise` |
| Qual é o próximo trabalho? | [roadmap ativo](../acompanhamento/roadmap.md) |

## Artefatos mantidos

- visão e diagramas que respondam a uma pergunta arquitetural concreta;
- [características arquiteturais](caracteristicas.md) priorizadas, com escopo e forma de verificação;
- [modelo ativo de oito componentes coesos](componentes-coesos.md), sua [evidência de refinamento](historico/componentes/ctx-cmp-003-refinamento.md) e os modelos [modular de treze componentes](historico/componentes/ctx-cmp-002-componentes-modulares.md) e [macro](historico/componentes/ctx-cmp-001-componentes-macro.md) preservados como históricos;
- [comparação histórica e definição física em análise](comparacao-e-arquitetura-recomendada.md), mantendo explícita a diferença entre componentes, quanta e topologia Kubernetes;
- [decisões duráveis](decisoes/README.md);
- mecanismos de validação e sinais que indiquem quando uma decisão deve ser revista.

Crie cada artefato somente quando ele apoiar uma decisão, implementação, validação ou apresentação. Evite duplicar o enunciado ou descrever uma arquitetura desejada como se já estivesse implementada.
