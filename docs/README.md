# Documentação do FIAP X

> Navegação: [README principal](../README.md)

Este é o catálogo dos documentos mantidos no repositório. Os índices por área fornecem a sequência de leitura e ligam cada artefato ao restante da documentação.

## Entender o projeto

- [Contexto do projeto](contexto-projeto.md) — objetivo, requisitos declarados, estado observado, decisões vigentes e questões abertas.
- [Enunciado](enunciado.md) — fonte original do desafio acadêmico.
- [Protótipo de referência](referencia/README.md) — código-base Go e limites de seu uso como evidência.
- [Agentes especializados](agentes.md) — papéis ativos, candidatos e atores registrados.

## Fontes ativas

- [Mapa arquitetural da raiz](../ARCHITECTURE.md) — estado corrente, limites, invariantes e caminhos para as autoridades detalhadas.
- [Requisitos e domínio](requisitos/README.md) — histórias, vocabulário, Event Storming e histórico de refinamentos.
- [Arquitetura](arquitetura/README.md) — características, modelo ativo, comparação física e ADRs.
- [Acompanhamento](acompanhamento/README.md) — trabalho corrente e realizações concluídas.
- [Contexto e decisões](contexto/README.md) — convenção do Context Graph, roteamento, rastreabilidade e Meta-PDCA.

## Material histórico ou isolado

- [Propostas](propostas/README.md) — alternativas preservadas que não são fontes canônicas.
- Os modelos substituídos permanecem listados no [índice de arquitetura](arquitetura/README.md) e indicam explicitamente seu sucessor.

## Governança e automação

- [Instruções compartilhadas](../AGENTS.md) e [instruções operacionais do Codex](../.codex/instructions.md).
- [Skill de refinamento de componentes](../.agents/skills/refinar-componentes-arquiteturais/SKILL.md).
- [Baseline e contrato de avaliação do harness](avaliacoes/harness/README.md) — cenários, oráculos e métricas para mudanças nas instruções e ferramentas.
- [Validação agregada do harness](../scripts/validar-harness.sh), [validação da documentação](../scripts/validar-documentacao.sh) e [validação do Context Graph](../scripts/validar-contexto.sh).

Use o [roteador de contexto](contexto/roteador.md) para selecionar somente os documentos necessários a uma tarefa.
