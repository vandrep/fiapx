---
context_id: R6-ROADMAP-001
context_type: roadmap
status: ativo
recorded_at: 2026-08-03
valid_from: 2026-08-03
entities:
  - R6-WORK-01
  - R6-WORK-02
  - R6-WORK-03
  - R6-WORK-04
  - R6-WORK-05
relations:
  - type: derived_from
    target: R6-PROP-001
  - type: governed_by
    target: CTX-GOV-001
---

# Roadmap local da proposta

## Finalidade

Este roadmap acompanha somente a evolução do pacote de seis componentes. Não altera prioridades, estados ou dependências do [roadmap oficial](../../../acompanhamento/roadmap.md). A ordem reduz incerteza e não promete datas.

Estados permitidos: `a_fazer`, `em_andamento` e `bloqueado`. Conclusões são removidas deste arquivo e acrescentadas, com o mesmo ID, ao [histórico local](historico.md).

## Agora — confirmar a base

<a id="r6-work-01"></a>

### R6-WORK-01 — Revisar o pacote em outro computador

- **Estado:** `a_fazer`.
- **Objetivo:** confirmar que histórias, decisões, diagramas e comparações preservam a rodada.
- **Resultado verificável:** revisão registrada sem lacuna material ou com correções identificadas.
- **Próxima ação:** clonar ou atualizar o repositório e executar o validador local.

<a id="r6-work-02"></a>

### R6-WORK-02 — Confirmar histórias e vocabulário propostos

- **Estado:** `a_fazer`.
- **Dependência:** revisão de `R6-WORK-01`.
- **Objetivo:** confirmar valor, ator, estados, cancelamento, reprocessamento e eventos de notificação.
- **Resultado verificável:** questões abertas das [histórias](../historias.md#questoes-abertas) respondidas e deltas semânticos preparados para promoção ou rejeição explícita.
- **Próxima ação:** ordenar as questões pelo impacto no ciclo do trabalho.

## Depois — testar as pressões arquiteturais

<a id="r6-work-03"></a>

### R6-WORK-03 — Quantificar características prioritárias

- **Estado:** `a_fazer`.
- **Dependência:** escopo confirmado em `R6-WORK-02`.
- **Objetivo:** substituir medidas abertas de confiabilidade e escala por alvos demonstráveis.
- **Resultado verificável:** cenários `R6-CA-01` e `R6-CA-02` com valores e método de medição.
- **Próxima ação:** definir lote, tamanho e duração representativos dos vídeos.

<a id="r6-work-04"></a>

### R6-WORK-04 — Comparar as alternativas de quantum A e B

- **Estado:** `a_fazer`.
- **Dependência:** medidas de `R6-WORK-03`.
- **Objetivo:** confrontar simplicidade inicial e isolamento do processamento com evidência executável.
- **Resultado verificável:** mesma fatia de risco medida nas duas alternativas, incluindo recuperação e complexidade de contratos.
- **Próxima ação:** desenhar o experimento descrito em [características e quanta](../caracteristicas-e-quanta.md#menor-experimento).

## Por fim — decidir a relação com o canônico

<a id="r6-work-05"></a>

### R6-WORK-05 — Decidir promoção, revisão ou arquivamento

- **Estado:** `a_fazer`.
- **Dependências:** `R6-WORK-02` e evidência arquitetural suficiente de `R6-WORK-04`.
- **Objetivo:** decidir se a proposta deve alterar as fontes canônicas.
- **Resultado verificável:** decisão rastreável; se promovida, mudanças de requisitos e arquitetura registradas conforme as políticas do repositório.
- **Próxima ação:** confrontar a [comparação](../comparacao-com-modelo-atual.md#diferencas-que-exigem-decisao-antes-de-promocao) com as evidências reunidas.

## Regra de atualização

Ao mudar um item, acrescente primeiro um evento ao [histórico](historico.md), depois atualize este arquivo. Ao concluir, remova a entidade e a seção daqui e registre o resultado com o mesmo ID no histórico. Execute o validador do pacote e `scripts/validar-contexto.sh`.
