---
context_id: CTX-ROADMAP-001
context_type: roadmap
status: ativo
recorded_at: 2026-08-01
valid_from: 2026-08-01
entities:
  - WORK-011
  - WORK-012
  - WORK-013
  - WORK-014
relations:
  - type: governed_by
    target: CTX-GOV-001
  - type: governed_by
    target: CTX-GOV-002
  - type: informed_by
    target: CTX-PRJ-001
  - type: informed_by
    target: CTX-CMP-002
---

# Roadmap ativo

## Finalidade

Manter visível apenas o trabalho que ainda precisa ser realizado ou está em andamento. A ordem representa dependências e redução de incerteza, não datas prometidas.

Estados permitidos:

- `a_fazer`: possui resultado esperado, mas a execução não começou;
- `em_andamento`: existe trabalho iniciado e o próximo passo está explícito;
- `bloqueado`: não pode avançar até que a condição indicada seja resolvida.

Itens concluídos não permanecem neste arquivo. Eles são migrados, com o mesmo ID, para o [registro de realizações](realizacoes.md).

## Agora — confrontar riscos e registrar escolhas

### WORK-011 — Executar Threat Modeling inicial

- **Estado:** `a_fazer`.
- **Dependência:** fronteiras candidatas de [`WORK-010`](realizacoes.md#work-010--refinar-componentes-e-delimitar-quanta-arquiteturais), concluído.
- **Objetivo:** identificar ativos, fronteiras de confiança, ameaças, histórias de abuso, controles e riscos residuais do fluxo.
- **Resultado verificável:** ameaças priorizadas ligadas a histórias, características, componentes ou quanta; mitigação e forma de teste para os riscos relevantes.
- **Escopo inicial:** autenticação e autorização por proprietário, autogestão de credenciais e dados pessoais, upload não confiável com validação progressiva, execução do FFmpeg, novas submissões sem cota acumulada, limites operacionais, retentativas automáticas limitadas, reprocessamento, isolamento de trabalhos, consumo de recursos, retenção sem prazo, download e notificações.
- **Próxima ação:** desenhar o fluxo de dados e marcar onde dados ou identidades cruzam uma fronteira de confiança.

### WORK-012 — Registrar as primeiras decisões arquiteturais

- **Estado:** `a_fazer`.
- **Dependências:** [`WORK-010`](realizacoes.md#work-010--refinar-componentes-e-delimitar-quanta-arquiteturais), concluído; riscos relevantes de [`WORK-011`](#work-011--executar-threat-modeling-inicial) devem informar decisões afetadas.
- **Objetivo:** registrar somente escolhas duráveis que já tenham pergunta, opções e evidências suficientes.
- **Resultado verificável:** ADRs graph-ready com trade-offs, consequências, validação e sinais de revisão.
- **Decisões candidatas:** semântica de aceitação e entrega, limites de quanta, estilo inicial de implantação e escolha de Java com Quarkus.
- **Próxima ação:** ordenar as decisões pela incerteza que bloqueia a primeira fatia executável.

## Depois — preparar e validar a implementação

### WORK-013 — Ativar especialista Java e Quarkus

- **Estado:** `a_fazer`.
- **Dependência:** ADR aceito para Java com Quarkus em [`WORK-012`](#work-012--registrar-as-primeiras-decisões-arquiteturais).
- **Objetivo:** promover o candidato descrito em [`../agentes.md`](../agentes.md) para um agente com responsabilidade, contexto, permissões e contrato de entrega delimitados.
- **Resultado verificável:** configuração do agente e, se recorrente, skill executável de onboarding e validação da stack.
- **Próxima ação:** após o ADR, definir o primeiro quantum e os comandos determinísticos que o agente deverá executar.

### WORK-014 — Construir a primeira fatia de risco com feedback determinístico

- **Estado:** `a_fazer`.
- **Dependências:** decisões necessárias de [`WORK-012`](#work-012--registrar-as-primeiras-decisões-arquiteturais) e suporte de [`WORK-013`](#work-013--ativar-especialista-java-e-quarkus) se Java com Quarkus for aceito.
- **Objetivo:** validar a principal fronteira e a semântica de recuperação antes de implementar todo o produto.
- **Resultado verificável:** trabalho sintético aceito e persistido, repetição/reinício exercitados, consulta disponível e verificações automatizadas executáveis pelos agentes.
- **Sinais mínimos:** compilação, testes, formatação/análise estática e teste de dependência arquitetural proporcional à estrutura escolhida.
- **Próxima ação:** transformar os cenários de aceitação e falha do primeiro ADR em testes executáveis.

## Regra de atualização

Ao iniciar um item, altere seu estado para `em_andamento` e registre a próxima ação efetiva. Ao concluir:

1. remova o ID de `entities` e a seção completa deste arquivo;
2. acrescente o mesmo ID ao `entities` de `realizacoes.md`;
3. registre resultado, evidências, decisões ou aprendizados relevantes e data de conclusão;
4. atualize dependências e próximas ações dos itens restantes;
5. execute `scripts/validar-contexto.sh` e as demais verificações do escopo;
6. se algum erro tiver sido encontrado, conclua também a correção de processo exigida por `CTX-GOV-002`.

Um item pode ser dividido antes de começar. Depois de produzir resultados, preserve seu ID e crie IDs sucessores relacionados em vez de reescrever silenciosamente seu significado.
