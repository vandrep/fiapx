---
context_id: DEC-0001
context_type: decision
status: aceita
recorded_at: 2026-08-02
valid_from: 2026-08-02
relations:
  - type: derived_from
    target: WORK-010
  - type: motivated_by
    target: https://www.oreilly.com/library/view/fundamentals-of-software/9781492043447/ch08.html
  - type: affects
    target: CTX-CMP-001
  - type: produces
    target: CTX-CMP-002
  - type: governed_by
    target: CTX-GOV-001
---

# DEC-0001 — Refinar componentes antes de delimitar quanta

## Pergunta

Qual granularidade e qual ordem de análise devem orientar a identificação dos componentes lógicos do FIAP X?

## Contexto e evidências

O modelo [`CTX-CMP-001`](../componentes-macro.md) agrupava responsabilidades em quatro capacidades amplas. A revisão do capítulo 8 de *Fundamentals of Software Architecture* mostrou que esses limites estavam mais próximos de quanta ou serviços candidatos do que de manifestações modulares: mais de um componente pode tratar a mesma entidade, desde que cada um encapsule um comportamento coeso.

O ciclo descrito pela referência atribui as histórias aos componentes antes de analisar responsabilidades e características. Essas duas análises diagnosticam o inventário congelado; somente a etapa posterior refatora ou adiciona componentes. Antecipar a quantidade de quanta inverteria essa relação e poderia fazer a topologia desejada determinar os componentes.

## Características arquiteturais

Confiabilidade e recuperabilidade, segurança e escalabilidade do processamento diferenciam responsabilidades e contratos. Elas continuam características do sistema: seu alcance pode revelar uma pressão para refatorar, mas não lhes atribui um proprietário isolado nem determina automaticamente um limite de implantação.

## Opções e trade-offs

| Opção | Benefício | Custo ou risco |
|---|---|---|
| Preservar quatro componentes macro | Modelo pequeno e fácil de visualizar | Esconde razões de mudança e confunde componente com possível serviço ou quantum |
| Partir diretamente para o inventário mais granular imaginado | Expõe comportamentos específicos cedo | Introduz componentes sem evidência e perde a trilha entre diagnóstico e refatoração |
| Executar o ciclo ordenado e congelar o inventário durante as análises | Torna cada divisão rastreável a histórias, papéis e pressões sistêmicas | Produz mais artefatos e exige repetir atribuição e análises depois de refatorar |

## Decisão

Adotar o ciclo `identificar → atribuir histórias → analisar responsabilidades → analisar características do sistema → refatorar → repetir e verificar`.

Um componente lógico representa comportamento modular implementável como pacote, módulo ou biblioteca. Não equivale por si só a processo, microsserviço, banco, bounded context ou quantum. Cada história possui exatamente um componente responsável principal; colaboradores participam por contratos sem compartilhar essa responsabilidade.

Durante as etapas de atribuição e análise, o inventário permanece congelado. Toda divisão, união ou adição ocorre apenas na etapa de refatoração e precisa citar um achado anterior. Quanta são avaliados depois do inventário refinado, considerando também acoplamento, dados, operação e características arquiteturais. Os quatro agrupamentos atuais são candidatos reversíveis, não uma decisão de topologia.

## Consequências

- O modelo anterior permanece como evidência histórica e é substituído por [`CTX-CMP-002`](../componentes.md).
- As sete histórias possuem um responsável principal em cada iteração registrada.
- O inventário refinado contém treze componentes comportamentais; componentes diferentes podem agir sobre `Trabalho` sem formar um único componente por entidade.
- Implementações futuras devem preservar as dependências modulares ou registrar nova refatoração quando código e medições contradisserem a hipótese.
- A escolha da quantidade de quanta, do estilo de implantação e da propriedade física dos dados continua aberta.

## Validação e resultados

O script [`validar-componentes.sh`](../../../scripts/validar-componentes.sh) verifica a ordem das etapas, a atribuição única das histórias, a motivação dos componentes refinados e a presença de quatro agrupamentos apenas candidatos. O modelo também registra uma segunda atribuição e repete as análises para verificar convergência.

## Condições de revisão

- Uma história não encontrar responsável coeso no inventário corrente.
- Código ou testes evidenciarem dependência circular, componente anêmico ou duplicidade de autoridade.
- Medições das características sistêmicas exigirem nova separação ou mostrarem que uma divisão não se sustenta.
- Uma decisão de quantum exigir contratos físicos incompatíveis com as fronteiras lógicas atuais.

## Histórico temporal

| Data | Estado | Alteração | Evidência ou responsável |
|---|---|---|---|
| 2026-08-02 | `aceita` | Ciclo ordenado, granularidade modular e separação entre componente e quantum aceitos | Refinamento conduzido com o responsável pelo produto e registrado em `WORK-010` |
