---
context_id: DEC-0004
context_type: decision
status: aceita
recorded_at: 2026-08-03
valid_from: 2026-08-03
relations:
  - type: derived_from
    target: CTX-REQ-001
  - type: informed_by
    target: REQ-CHG-0003
  - type: informed_by
    target: CTX-CMP-002
  - type: informed_by
    target: R6-CMP-MODEL-001
  - type: informed_by
    target: CTX-EVD-CMP-003
  - type: produces
    target: CTX-CMP-003
  - type: governed_by
    target: CTX-GOV-001
---

# DEC-0004 — Consolidar o núcleo em oito componentes lógicos

## Pergunta

Qual inventário lógico deve orientar o primeiro código sem perder as autoridades e garantias do modelo canônico nem carregar como requisitos as extensões da proposta R6?

## Contexto e evidências

O modelo [`CTX-CMP-002`](../historico/componentes/ctx-cmp-002-componentes-modulares.md) tornou explícitas treze responsabilidades, mas algumas fronteiras podem virar módulos anêmicos no primeiro incremento. A proposta [`R6-CMP-MODEL-001`](../../propostas/base-simplificada-seis-componentes/componentes.md) trouxe uniões úteis, porém adiou identidade, retirou tentativas e misturou publicação com acesso.

O responsável pelo produto confirmou em [`REQ-CHG-0003`](../../requisitos/refinamentos/REQ-CHG-0003.md) uma consolidação conservadora das sete histórias: concorrência, não perda, tentativas, reprocessamento e ZIP permanecem; cancelamento, download individual, detalhe/motivo de falha e notificações ampliadas não entram no núcleo.

A evidência [`CTX-EVD-CMP-003`](../historico/componentes/ctx-cmp-003-refinamento.md) preserva o inventário inicial, as atribuições, as análises e a refatoração que informaram esta decisão sem competir com a definição vigente.

## Opções e trade-offs

| Opção | Benefícios | Custos e riscos |
|---|---|---|
| Manter treze componentes | maior granularidade comportamental e histórico já auditado | coordenação interna extensa e risco de módulos que apenas encaminham chamadas |
| Promover os seis componentes R6 | desenho mais curto | regressões de segurança/recuperação e autoridades sobrepostas |
| **Consolidar em oito componentes** | preserva autoridades e reduz granularidade sem derivar serviços por contagem | exige novo modelo, migração de IDs e verificação no código |

## Decisão

Adotar o modelo [`CTX-CMP-003`](../componentes-coesos.md) como baseline lógico do núcleo:

1. `CMP-18` Autenticação e Identidade;
2. `CMP-19` Submissão e Admissão;
3. `CMP-20` Ciclo do Trabalho;
4. `CMP-21` Processamento de Mídia;
5. `CMP-22` Publicação de Resultados;
6. `CMP-23` Consulta de Trabalhos;
7. `CMP-24` Acesso a Resultados;
8. `CMP-25` Comunicação de Falhas.

As autoridades são parte da decisão:

- Keycloak possui credenciais e autenticação; `CMP-18` valida o token e fornece `(issuer, subject)`;
- `CMP-20`, `CMP-23` e `CMP-24` aplicam propriedade somente sobre dados que conhecem;
- apenas `CMP-20` altera estado e decide retentativa de processamento;
- `CMP-21` e `CMP-22` relatam fatos/categorias técnicas e não decidem retry;
- `CMP-25` tenta entregar comunicação de falha, sem alterar o trabalho.

Componentes não são quanta, processos, bancos ou `Deployment`s. A topologia é decidida separadamente em [`DEC-0002`](0002-topologia-kubernetes.md).

## Consequências

- `CTX-CMP-002` permanece íntegro como evidência histórica e é marcado como substituído.
- Os IDs `AR-CMP-*` da análise comparativa permanecem rastreáveis, mas não se tornam IDs canônicos.
- O primeiro código deverá representar os oito limites como módulos/pacotes, mesmo quando coimplantados.
- A consolidação reduz contratos internos, mas concentra `fan-in` no Ciclo de forma deliberada.
- Uma fronteira poderá ser unida ou dividida apenas por nova evidência e nó sucessor, não por conveniência de framework.

## Validação

- cada `US-01..07` possui exatamente um responsável principal;
- regra estática impede Processamento/Publicação/Comunicação de depender de repositórios do Ciclo;
- testes demonstram que Identidade não decide propriedade e que mídia não cria tentativa;
- a implementação mede dependências aferentes/eferentes e sinaliza componentes que se reduzam a encaminhamento;
- extensões futuras não aparecem nos contratos do núcleo.

## Condições de revisão

- um componente não apresentar comportamento, política ou razão de mudança próprios no código;
- dependência circular ou leitura cruzada de dados contrariar as autoridades decididas;
- uma extensão futura for confirmada e introduzir nova autoridade;
- carga, equipe, segurança ou operação exigirem outro limite lógico.

## Histórico temporal

| Data | Estado | Alteração | Evidência ou responsável |
|---|---|---|---|
| 2026-08-03 | `aceita` | Adoção do núcleo conservador com oito componentes e autoridades exclusivas | confirmação do responsável pelo produto e refinamento arquitetural |
