# Arquitetura

> Navegação: [documentação](../README.md) · [README principal](../../README.md)

Este diretório guarda artefatos específicos da arquitetura do projeto. As instruções agnósticas permanecem na [configuração do agente de arquitetura](../../.codex/agents/arquiteto.toml), e o estado do FIAP X está no [contexto do projeto](../contexto-projeto.md).

Identidade, relações, procedência e validade temporal seguem a [convenção de contexto](../contexto/README.md).

## Artefatos esperados

- visão e diagramas que respondam a uma pergunta arquitetural concreta;
- [características arquiteturais](caracteristicas.md) priorizadas, com escopo e forma de verificação;
- [modelo ativo de oito componentes coesos](componentes-coesos.md), com os modelos [modular de treze componentes](componentes.md) e [macro](componentes-macro.md) preservados como históricos;
- [comparação histórica e definição física em análise](comparacao-e-arquitetura-recomendada.md), mantendo explícita a diferença entre componentes, quanta e topologia Kubernetes;
- [decisões duráveis](decisoes/README.md);
- mecanismos de validação e sinais que indiquem quando uma decisão deve ser revista.

Crie cada artefato somente quando ele apoiar uma decisão, implementação, validação ou apresentação. Evite duplicar o enunciado ou descrever uma arquitetura desejada como se já estivesse implementada.
