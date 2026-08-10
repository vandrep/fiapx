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
  - type: informed_by
    target: CTX-CMP-003
  - type: informed_by
    target: CTX-ARCH-001
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

- **Estado:** `em_andamento`.
- **Dependência:** fronteiras candidatas de [`WORK-010`](realizacoes.md#work-010--refinar-componentes-e-delimitar-quanta-arquiteturais), concluído.
- **Objetivo:** identificar ativos, fronteiras de confiança, ameaças, histórias de abuso, controles e riscos residuais do fluxo.
- **Resultado verificável:** ameaças priorizadas ligadas a histórias, características, componentes ou quanta; mitigação e forma de teste para os riscos relevantes.
- **Escopo inicial:** Keycloak/OIDC e autorização por proprietário, bootstrap sem segredo no Git, upload não confiável com validação progressiva, execução do FFmpeg, novas submissões sem cota acumulada, limites operacionais, retentativas automáticas limitadas, reprocessamento, isolamento de trabalhos, consumo de recursos, retenção sem prazo, download e comunicação de falha.
- **Progresso:** o [`CTX-THREAT-001`](../arquitetura/modelo-ameacas.md) registrou o fluxo, doze ativos, dez fronteiras e a primeira onda de vinte ameaças rastreáveis: nove `P0`, dez `P1` e uma `P2` condicional. Controles decididos, mitigações propostas, testes e risco residual provisório permanecem separados.
- **Próxima ação:** transformar os testes das ameaças `P0` em gates da primeira fatia e entradas para as decisões afetadas; enumerar a onda restante de `TB-07..10` antes de concluir o modelo.

### WORK-012 — Registrar as primeiras decisões arquiteturais

- **Estado:** `em_andamento`.
- **Dependências:** [`WORK-010`](realizacoes.md#work-010--refinar-componentes-e-delimitar-quanta-arquiteturais), concluído; riscos relevantes de [`WORK-011`](#work-011--executar-threat-modeling-inicial) devem informar decisões afetadas.
- **Objetivo:** registrar somente escolhas duráveis que já tenham pergunta, opções e evidências suficientes.
- **Resultado verificável:** ADRs graph-ready com trade-offs, consequências, validação e sinais de revisão.
- **Decisões aceitas:** [`DEC-0002`](../arquitetura/decisoes/0002-topologia-kubernetes.md), três quanta Kubernetes; [`DEC-0004`](../arquitetura/decisoes/0004-componentes-coesos-do-nucleo.md), oito componentes; [`DEC-0005`](../arquitetura/decisoes/0005-keycloak-no-ambiente-de-validacao.md), Keycloak autocontido.
- **Decisão em análise:** [`DEC-0003`](../arquitetura/decisoes/0003-entrega-duravel-e-persistencia.md), sobre aceite, RabbitMQ, outbox/inbox, PostgreSQL e object storage. Java com Quarkus continua apenas preferência.
- **Próxima ação:** usar os riscos de [`WORK-011`](#work-011--executar-threat-modeling-inicial) e a primeira fatia executável para confrontar `DEC-0003` e registrar a escolha de Java/Quarkus separadamente.

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
- **Resultado verificável:** cluster criado do zero com Keycloak e três deployments de aplicação; dois usuários autenticados; trabalho sintético aceito e persistido; repetição/reinício, acesso cruzado, ZIP e falha do notificador exercitados por verificações automatizadas.
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
