---
context_id: CTX-GOV-001
context_type: policy
status: ativo
recorded_at: 2026-08-01
valid_from: 2026-08-01
relations:
  - type: motivated_by
    target: https://www.thoughtworks.com/pt-br/radar/techniques/context-graph
---

# Convenção de contexto e decisões

> Navegação: [documentação](../README.md) · [README principal](../../README.md)

Documentos desta área: [roteador de contexto](roteador.md), [rastreabilidade de refinamentos](rastreabilidade-refinamentos.md) e [Meta-PDCA](meta-pdca.md).

## Objetivo

Manter o raciocínio do projeto rastreável como uma rede de contexto, e não apenas como uma coleção de documentos isolados. Decisões, requisitos, evidências, exceções e resultados devem possuir identidade estável e relações explícitas.

A fonte atual continua sendo Markdown versionado. Metadados YAML no início dos arquivos permitem extração futura para um grafo sem exigir agora RDF, banco de grafos ou uma plataforma específica.

## Nó

Todo artefato contextual relevante usa este formato mínimo:

```yaml
---
context_id: DEC-0001
context_type: decision
status: em_analise
recorded_at: 2026-08-01
valid_from: 2026-08-01
relations:
  - type: derived_from
    target: CTX-REQ-001
---
```

Campos:

| Campo | Significado |
|---|---|
| `context_id` | Identificador estável e único. Nunca deve ser reutilizado para outro significado |
| `context_type` | Tipo do nó, como `decision`, `evidence`, `assumption`, `requirement_set`, `requirement_change`, `component_model`, `policy`, `context_router`, `roadmap` ou `outcome_log` |
| `status` | Estado atual dentro do fluxo específico daquele tipo de nó |
| `recorded_at` | Data em que o nó foi registrado; não muda quando sua validade muda |
| `valid_from` | Data a partir da qual o nó ou esta versão contextual passa a ser aplicável |
| `valid_until` | Data opcional de encerramento da validade; ausência significa que não foi encerrada |
| `relations` | Arestas tipadas para outros IDs, caminhos versionados ou URIs externas |
| `entities` | IDs de entidades descritas dentro de um nó agregador, como histórias, características ou componentes |
| `template` | Quando `true`, identifica um modelo que não deve ser ingerido como nó real |

Um arquivo pode descrever um conjunto coerente, como histórias ou componentes. Decisões arquiteturais devem usar um arquivo por decisão para permanecerem nós independentes.

## Relações

Use preferencialmente:

| Relação | Uso |
|---|---|
| `derived_from` | O nó foi produzido a partir da fonte ou evidência indicada |
| `informed_by` | A fonte orientou o nó, mas não o determina sozinha |
| `informs` | O nó fornece contexto que orienta o alvo |
| `motivated_by` | A necessidade ou referência indicada motivou a criação do nó |
| `governed_by` | O nó segue a política ou convenção indicada |
| `refines` | O nó acrescenta precisão sem invalidar o alvo |
| `affects` | A decisão ou mudança produz consequência no alvo |
| `depends_on` | A validade ou execução depende do alvo |
| `validated_by` | Uma evidência ou resultado verifica a afirmação ou decisão |
| `contradicts` | Existe conflito que precisa permanecer visível |
| `supersedes` | O novo nó substitui o alvo a partir de uma data |
| `produces` | Uma decisão, experimento ou processo gerou o alvo |

Quando a validade estiver somente na relação, use:

```yaml
relations:
  - type: supersedes
    target: DEC-0001
    valid_from: 2026-09-10
    reason: Novas medições alteraram o limite de capacidade.
```

## Estados de decisão

| Estado | Significado |
|---|---|
| `em_analise` | A pergunta e as opções estão sendo avaliadas; nenhuma opção foi aceita |
| `aceita` | A decisão orienta o trabalho a partir de `valid_from` |
| `rejeitada` | A opção foi considerada e conscientemente descartada |
| `substituida` | Outra decisão assumiu sua validade; a aresta `supersedes` preserva a cadeia |

Outros tipos podem possuir fluxos próprios, como `em_refinamento` para histórias, `em_evolucao` para vocabulário e `ativo` para uma política. O estado deve descrever a posição no fluxo, em vez de usar um rótulo absoluto de maturidade.

## Procedência e temporalidade

- Não apague uma decisão, evidência ou relação porque deixou de valer.
- Encerre a validade quando necessário e conecte o novo nó ao anterior.
- Diferencie o que aconteceu (`evidence` ou `outcome`) do motivo e da escolha (`decision`).
- Registre fonte, data e responsável quando forem conhecidos; não invente autoria ou precisão.
- Um resultado pode validar, enfraquecer ou contradizer uma decisão sem reescrever sua justificativa original.
- Mantenha o corpo Markdown como explicação humana do porquê; os metadados representam identidade e conexões, não substituem o raciocínio.

## Identificadores canônicos e grupos principais

Esta tabela orienta a navegação pelas autoridades canônicas e pelos grupos históricos principais; a validação automatizada continua sendo a fonte da lista completa de IDs, inclusive os `R6-*` isolados na [proposta histórica](../propostas/base-simplificada-seis-componentes/README.md).

| ID | Tipo | Artefato |
|---|---|---|
| `CTX-GOV-001` | Política | Este documento |
| `CTX-GOV-002` | Política | [`docs/contexto/meta-pdca.md`](meta-pdca.md) |
| `CTX-GOV-003` | Política | [`docs/contexto/rastreabilidade-refinamentos.md`](rastreabilidade-refinamentos.md) |
| `CTX-ROUTE-001` | Roteador de contexto | [`docs/contexto/roteador.md`](roteador.md) |
| `CTX-PRJ-001` | Contexto do projeto | [`docs/contexto-projeto.md`](../contexto-projeto.md) |
| `CTX-DOM-001` | Vocabulário do domínio | [`docs/requisitos/glossario.md`](../requisitos/glossario.md) |
| `CTX-DOM-002` | Descoberta do domínio | [`docs/requisitos/event-storming.md`](../requisitos/event-storming.md) |
| `CTX-REQ-001` | Conjunto de requisitos | [`docs/requisitos/historias.md`](../requisitos/historias.md) |
| `CTX-CHAR-001` | Características arquiteturais | [`docs/arquitetura/caracteristicas.md`](../arquitetura/caracteristicas.md) |
| `CTX-CMP-001` | Modelo histórico de componentes macro | [`docs/arquitetura/historico/componentes/ctx-cmp-001-componentes-macro.md`](../arquitetura/historico/componentes/ctx-cmp-001-componentes-macro.md) |
| `CTX-CMP-002` | Modelo histórico de componentes modulares | [`docs/arquitetura/historico/componentes/ctx-cmp-002-componentes-modulares.md`](../arquitetura/historico/componentes/ctx-cmp-002-componentes-modulares.md) |
| `CTX-CMP-003` | Modelo ativo de componentes coesos | [`docs/arquitetura/componentes-coesos.md`](../arquitetura/componentes-coesos.md) |
| `CTX-EVD-CMP-003` | Evidência histórica do ciclo que produziu o modelo coeso | [`docs/arquitetura/historico/componentes/ctx-cmp-003-refinamento.md`](../arquitetura/historico/componentes/ctx-cmp-003-refinamento.md) |
| `CTX-THREAT-001` | Modelo de ameaças inicial em análise | [`docs/arquitetura/modelo-ameacas.md`](../arquitetura/modelo-ameacas.md) |
| `TB-01` a `TB-10` | Fronteiras de confiança do modelo de ameaças | [`CTX-THREAT-001`](../arquitetura/modelo-ameacas.md#fronteiras-de-confian%C3%A7a) |
| `THR-001` a `THR-020` | Ameaças priorizadas e rastreáveis | [`CTX-THREAT-001`](../arquitetura/modelo-ameacas.md#amea%C3%A7as-priorizadas) |
| `DEC-0001` | Decisão sobre granularidade e ciclo de componentes | [`docs/arquitetura/decisoes/0001-refinamento-de-componentes.md`](../arquitetura/decisoes/0001-refinamento-de-componentes.md) |
| `CTX-ARCH-001` | Comparação e arquitetura recomendada em análise | [`docs/arquitetura/comparacao-e-arquitetura-recomendada.md`](../arquitetura/comparacao-e-arquitetura-recomendada.md) |
| `DEC-0002` | Decisão aceita sobre topologia Kubernetes | [`docs/arquitetura/decisoes/0002-topologia-kubernetes.md`](../arquitetura/decisoes/0002-topologia-kubernetes.md) |
| `DEC-0003` | Decisão em análise sobre aceite, entrega durável e persistência | [`docs/arquitetura/decisoes/0003-entrega-duravel-e-persistencia.md`](../arquitetura/decisoes/0003-entrega-duravel-e-persistencia.md) |
| `DEC-0004` | Decisão aceita sobre oito componentes do núcleo | [`docs/arquitetura/decisoes/0004-componentes-coesos-do-nucleo.md`](../arquitetura/decisoes/0004-componentes-coesos-do-nucleo.md) |
| `DEC-0005` | Decisão aceita sobre Keycloak no ambiente de validação | [`docs/arquitetura/decisoes/0005-keycloak-no-ambiente-de-validacao.md`](../arquitetura/decisoes/0005-keycloak-no-ambiente-de-validacao.md) |
| `CTX-ROADMAP-001` | Roadmap ativo | [`docs/acompanhamento/roadmap.md`](../acompanhamento/roadmap.md) |
| `CTX-OUTCOME-001` | Registro de realizações | [`docs/acompanhamento/realizacoes.md`](../acompanhamento/realizacoes.md) |
| `WORK-001` a `WORK-016` | Itens de trabalho | [Roadmap](../acompanhamento/roadmap.md) ou [realizações](../acompanhamento/realizacoes.md), conforme o estado |
| `REQ-CHG-0001` a `REQ-CHG-0003` | Mudanças de requisitos | [Índice de refinamentos](../requisitos/refinamentos/README.md) |
| `CMP-01` a `CMP-04` | Componentes lógicos históricos | Inventário macro de `CTX-CMP-001` |
| `CMP-05` a `CMP-17` | Componentes lógicos históricos | Inventário de `CTX-CMP-002` |
| `CMP-18` | Componente lógico ativo | Autenticação e Identidade |
| `CMP-19` | Componente lógico ativo | Submissão e Admissão |
| `CMP-20` | Componente lógico ativo | Ciclo do Trabalho |
| `CMP-21` | Componente lógico ativo | Processamento de Mídia |
| `CMP-22` | Componente lógico ativo | Publicação de Resultados |
| `CMP-23` | Componente lógico ativo | Consulta de Trabalhos |
| `CMP-24` | Componente lógico ativo | Acesso a Resultados |
| `CMP-25` | Componente lógico ativo | Comunicação de Falhas |
| `AR-CMP-01` a `AR-CMP-08` | Rótulos lógicos históricos da análise comparativa | [`docs/arquitetura/comparacao-e-arquitetura-recomendada.md`](../arquitetura/comparacao-e-arquitetura-recomendada.md) |

Adicione novos IDs quando novos nós surgirem. Se uma fronteira for dividida, unida ou mudar de significado, crie novos IDs e conecte-os aos anteriores; não recicle a identidade antiga.

Itens de trabalho preservam o ID quando migram do roadmap para o registro de realizações. O ID deve existir em apenas um dos dois agregadores no estado corrente; o histórico do Git preserva a transição.

## Validação

Execute [`scripts/validar-documentacao.sh`](../../scripts/validar-documentacao.sh) para verificar links, âncoras e alcançabilidade a partir do README principal. Depois de alterar metadados, execute também [`scripts/validar-contexto.sh`](../../scripts/validar-contexto.sh). A segunda verificação analisa o YAML, campos obrigatórios, IDs duplicados e alvos locais ou contextuais sem resolução, além de chamar os validadores do modelo ativo, da arquitetura recomendada e do pacote R6 histórico. Esses controles são fitness functions estruturais e não substituem a revisão do raciocínio registrado.
