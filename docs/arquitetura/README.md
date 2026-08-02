# Arquitetura

Este diretório guarda artefatos específicos da arquitetura do projeto. As instruções agnósticas do agente de arquitetura permanecem em `.codex/agents/arquiteto.toml` e o contexto do FIAP X em `../contexto-projeto.md`.

Identidade, relações, procedência e validade temporal seguem a [convenção de contexto](../contexto/README.md).

## Artefatos esperados

- visão e diagramas que respondam a uma pergunta arquitetural concreta;
- [características arquiteturais](caracteristicas.md) priorizadas, com escopo e forma de verificação;
- [inventário e refinamento iterativo de componentes](componentes.md), com o [modelo macro substituído](componentes-macro.md) preservado como histórico;
- [decisões duráveis](decisoes/);
- mecanismos de validação e sinais que indiquem quando uma decisão deve ser revista.

Crie cada artefato somente quando ele apoiar uma decisão, implementação, validação ou apresentação. Evite duplicar o enunciado ou descrever uma arquitetura desejada como se já estivesse implementada.
