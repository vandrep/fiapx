---
context_id: CTX-GOV-003
context_type: policy
status: ativo
recorded_at: 2026-08-02
valid_from: 2026-08-02
relations:
  - type: refines
    target: CTX-GOV-001
  - type: derived_from
    target: WORK-016
  - type: informs
    target: CTX-REQ-001
---

# Rastreabilidade de refinamentos

## Objetivo

Permitir reconstruir quando, por quem, com qual evidência e de que maneira uma história evoluiu, sem usar o autor de um commit como substituto da autoria semântica ou da confirmação de negócio.

Esta política especializa a [convenção do Context Graph](README.md). O [Analista de Negócio](../agentes.md#analista-negocio) prepara o refinamento, mas o responsável pelo produto preserva a autoridade sobre necessidade, prioridade e aceite.

## Registro de mudança

Uma alteração semântica em uma ou mais histórias produz um nó imutável com um ID `REQ-CHG-NNNN`, `context_type: requirement_change` e ao menos uma relação `affects` para uma `US-*`.

```yaml
---
context_id: REQ-CHG-0000
context_type: requirement_change
status: registrado
recorded_at: "YYYY-MM-DD"
valid_from: "YYYY-MM-DD"
refined_by: analista_negocio
recorded_by: agente_principal
confirmed_by: responsavel_produto
confirmed_at: "YYYY-MM-DD"
relations:
  - type: affects
    target: US-00
  - type: governed_by
    target: CTX-GOV-003
---
```

Campos específicos:

| Campo | Regra |
|---|---|
| `refined_by` | Papel que realizou a análise semântica; obrigatório |
| `recorded_by` | Papel que materializou o registro; obrigatório |
| `confirmed_by` | Autoridade que confirmou a decisão de negócio; opcional |
| `confirmed_at` | Data da confirmação; obrigatória se `confirmed_by` existir e proibida sem ele |

Os atores válidos estão no [registro de agentes e atores](../agentes.md#atores-refinamento). `nao_registrado` explicita uma lacuna histórica e não pode ser usado em novos refinamentos.

O corpo do nó registra ao menos:

| História | Alteração semântica | Classificação anterior | Classificação resultante | Evidência | Confirmação |
|---|---|---|---|---|---|

Cada `US-*` afetada mantém um link de volta ao registro. O registro usa links para as âncoras estáveis das histórias; essas referências navegáveis complementam as relações `affects`.

## Granularidade e imutabilidade

- Agrupe no mesmo nó as mudanças que resultarem da mesma sessão, evidência ou decisão coerente.
- Não crie registro para ortografia, formatação, reorganização ou outra alteração sem mudança de significado.
- Não reescreva o significado de um registro publicado. Uma correção cria outro nó com relação `supersedes` para o anterior.
- O diff do Git preserva a edição física; o nó preserva o delta semântico e a autoridade.

## Adoção incremental

| Artefato | Benefício | Momento de adoção |
|---|---|---|
| Histórias `US-*` | Alto: necessidade, critério e confirmação mudam durante a descoberta | Piloto atual |
| Termos do glossário | Alto quando uma definição muda regra, contrato ou autoridade | Ao atribuir IDs próprios aos termos afetados |
| Elementos do Event Storming | Alto quando uma sessão valida, contradiz ou substitui descoberta anterior | Na próxima mudança semântica de um elemento identificado |
| Características `CA-*` | Alto quando prioridade, escopo ou medida muda | Na próxima reavaliação material |
| Componentes `CMP-*` | Alto em divisão, união ou mudança de responsabilidade e contrato | Na próxima alteração de fronteira |
| Agentes e políticas | Condicionado a mudança de responsabilidade, permissão ou validade | Somente para mudanças materiais |

ADRs já possuem nó e histórico temporal; roadmap e realizações preservam o ciclo dos trabalhos; código, testes e configuração usam Git e suas verificações. Evidências imutáveis e registros de mudança não recebem um histórico do histórico.

## Condições de revisão

Reavalie a opção de manter as histórias agregadas quando a navegação pelos eventos se tornar difícil, histórias passarem a evoluir de forma independente ou o volume de autores e mudanças justificar um nó e arquivo por história.
