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
| `context_type` | Tipo do nó, como `decision`, `evidence`, `assumption`, `requirement_set`, `component_model`, `policy`, `context_router`, `roadmap` ou `outcome_log` |
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

## Identificadores atuais

| ID | Tipo | Artefato |
|---|---|---|
| `CTX-GOV-001` | Política | Este documento |
| `CTX-GOV-002` | Política | `docs/contexto/meta-pdca.md` |
| `CTX-ROUTE-001` | Roteador de contexto | `docs/contexto/roteador.md` |
| `CTX-PRJ-001` | Contexto do projeto | `docs/contexto-projeto.md` |
| `CTX-DOM-001` | Vocabulário do domínio | `docs/requisitos/glossario.md` |
| `CTX-DOM-002` | Descoberta do domínio | `docs/requisitos/event-storming.md` |
| `CTX-REQ-001` | Conjunto de requisitos | `docs/requisitos/historias.md` |
| `CTX-CHAR-001` | Características arquiteturais | `docs/arquitetura/caracteristicas.md` |
| `CTX-CMP-001` | Modelo de componentes | `docs/arquitetura/componentes.md` |
| `CTX-ROADMAP-001` | Roadmap ativo | `docs/acompanhamento/roadmap.md` |
| `CTX-OUTCOME-001` | Registro de realizações | `docs/acompanhamento/realizacoes.md` |
| `WORK-001` a `WORK-015` | Itens de trabalho | Roadmap ou registro de realizações, conforme o estado |
| `CMP-01` | Componente lógico | Identidade e Acesso |
| `CMP-02` | Componente lógico | Trabalhos de Vídeo |
| `CMP-03` | Componente lógico | Processamento de Mídia |
| `CMP-04` | Componente lógico | Notificações |

Adicione novos IDs quando novos nós surgirem. Se uma fronteira for dividida, unida ou mudar de significado, crie novos IDs e conecte-os aos anteriores; não recicle a identidade antiga.

Itens de trabalho preservam o ID quando migram do roadmap para o registro de realizações. O ID deve existir em apenas um dos dois agregadores no estado corrente; o histórico do Git preserva a transição.

## Validação

Execute `scripts/validar-contexto.sh` depois de alterar metadados. A verificação analisa o YAML, campos obrigatórios, IDs duplicados e alvos locais ou contextuais sem resolução. Ela é uma fitness function estrutural inicial e não avalia a qualidade do raciocínio registrado.
