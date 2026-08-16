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
  - WORK-018
  - WORK-023
  - WORK-024
  - WORK-025
  - WORK-026
  - WORK-027
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

## Agora — estabilizar o harness, confrontar riscos e registrar escolhas

### WORK-018 — Adotar harness spec-driven enxuto

- **Estado:** `em_andamento`.
- **Dependência:** baseline e contrato de avaliação de [`WORK-017`](realizacoes.md#work-017--estabelecer-baseline-e-contrato-de-avalia%C3%A7%C3%A3o-do-harness), concluído.
- **Objetivo:** tornar explícitas as fontes de verdade e reduzir contexto repetido, mantendo instruções globais, instruções locais, templates, scripts e skills nas menores fronteiras reutilizáveis.
- **Resultado verificável:** os cenários da baseline continuam aprovados sem perda de rastreabilidade ou governança e demonstram redução mensurável de contexto ou tokens; instruções não são duplicadas e tecnologias ainda candidatas não se tornam obrigações do harness.
- **Desdobramento:** [`WORK-019`](realizacoes.md#work-019--formalizar-o-contrato-das-fontes), [`WORK-020`](realizacoes.md#work-020--criar-o-mapa-arquitetural-da-raiz), [`WORK-021`](realizacoes.md#work-021--transformar-validadores-em-gates-de-ci) e [`WORK-022`](realizacoes.md#work-022--avaliar-a-navega%C3%A7%C3%A3o-arquitetural-do-harness) concluídos; `WORK-023..27` preservam enforcement no código, legibilidade do runtime, autonomia, coleta de lixo e eficiência mensurável.
- **Progresso:** `AGENTS.md`, `ARCHITECTURE.md`, `docs/`, `.codex/` e `README.md` possuem papéis não sobrepostos; contratos v1/v2, mapa e contrafactuais passam localmente. A comparação viva de fontes e métricas ainda depende do Codex CLI congelado.
- **Condição de encerramento:** concluir `WORK-023..27`, preservando evidências históricas e promovendo autonomia somente depois dos gates correspondentes.
- **Próxima ação:** encerrar em `WORK-027` o ciclo de eficiência com a v3 ainda opt-in; manter `WORK-023/24` condicionados à primeira fatia de aplicação.

### WORK-011 — Executar Threat Modeling inicial

- **Estado:** `em_andamento`.
- **Dependência:** fronteiras candidatas de [`WORK-010`](realizacoes.md#work-010--refinar-componentes-e-delimitar-quanta-arquiteturais), concluído.
- **Objetivo:** identificar ativos, fronteiras de confiança, ameaças, histórias de abuso, controles e riscos residuais do fluxo.
- **Resultado verificável:** ameaças priorizadas ligadas a histórias, características, componentes ou quanta; mitigação e forma de teste para os riscos relevantes.
- **Escopo inicial:** Keycloak/OIDC e autorização por proprietário, bootstrap sem segredo no Git, upload não confiável com validação progressiva, execução do FFmpeg, novas submissões sem cota acumulada, limites operacionais, retentativas automáticas limitadas, reprocessamento, isolamento de trabalhos, consumo de recursos, retenção sem prazo, download e comunicação de falha.
- **Progresso:** o [`CTX-THREAT-001`](../arquitetura/modelo-ameacas.md) registrou o fluxo, doze ativos, dez fronteiras e a primeira onda de vinte ameaças rastreáveis: nove `P0`, dez `P1` e uma `P2` condicional. Controles decididos, mitigações propostas, testes e risco residual provisório permanecem separados.
- **Condição de encerramento:** preservar a baseline concluída em [`WORK-017`](realizacoes.md#work-017--estabelecer-baseline-e-contrato-de-avalia%C3%A7%C3%A3o-do-harness) e concluir [`WORK-018`](#work-018--adotar-harness-spec-driven-enxuto), sem alterar a semântica das ameaças para atender ao harness.
- **Próxima ação:** transformar os testes das ameaças `P0` em gates da primeira fatia e entradas para as decisões afetadas; enumerar a onda restante de `TB-07..10` antes de concluir o modelo.

### WORK-012 — Registrar as primeiras decisões arquiteturais

- **Estado:** `em_andamento`.
- **Dependências:** [`WORK-010`](realizacoes.md#work-010--refinar-componentes-e-delimitar-quanta-arquiteturais), concluído; riscos relevantes de [`WORK-011`](#work-011--executar-threat-modeling-inicial) devem informar decisões afetadas.
- **Objetivo:** registrar somente escolhas duráveis que já tenham pergunta, opções e evidências suficientes.
- **Resultado verificável:** ADRs graph-ready com trade-offs, consequências, validação e sinais de revisão.
- **Decisões aceitas:** [`DEC-0002`](../arquitetura/decisoes/0002-topologia-kubernetes.md), três quanta Kubernetes; [`DEC-0004`](../arquitetura/decisoes/0004-componentes-coesos-do-nucleo.md), oito componentes; [`DEC-0005`](../arquitetura/decisoes/0005-keycloak-no-ambiente-de-validacao.md), Keycloak autocontido.
- **Decisão em análise:** [`DEC-0003`](../arquitetura/decisoes/0003-entrega-duravel-e-persistencia.md), sobre aceite, RabbitMQ, outbox/inbox, PostgreSQL e object storage. Java com Quarkus continua apenas preferência.
- **Condição de encerramento:** preservar a baseline concluída em [`WORK-017`](realizacoes.md#work-017--estabelecer-baseline-e-contrato-de-avalia%C3%A7%C3%A3o-do-harness) e concluir [`WORK-018`](#work-018--adotar-harness-spec-driven-enxuto), mantendo como candidatas as escolhas ainda `em_analise`.
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

### WORK-027 — Otimizar custo e relato da avaliação do harness

- **Estado:** `em_andamento`.
- **Dependências:** runner e baseline de [`WORK-017`](realizacoes.md#work-017--estabelecer-baseline-e-contrato-de-avalia%C3%A7%C3%A3o-do-harness); medições e manifesto ampliado de [`WORK-022`](realizacoes.md#work-022--avaliar-a-navega%C3%A7%C3%A3o-arquitetural-do-harness).
- **Objetivo:** ordenar feedback por custo, eliminar preflight redundante, medir tempo/tokens/tool output e relatar o consumo ao concluir cada execução sem confundir telemetria do agente principal com processos filhos.
- **Progresso:** contrato de relato, preflight único, `--fail-fast`, `--repeat`, telemetria por fase e contrato v3 estrutural foram implementados. A coleta focal [`CTX-EVD-HARNESS-003`](../avaliacoes/harness/resultados/eficiencia-v3-2026-08-15.json) confirmou o lote v2 em `3/3` sem retrabalho e reprovou a promoção v3 por piora de tokens, tempo e saída de ferramentas; v1/v2 permanecem como padrão. A baseline [`CTX-EVD-HARNESS-004`](../avaliacoes/harness/resultados/baseline-multiexecucao-v1-2026-08-16.json) registrou três suítes v1 limpas com medianas de `158 s`, `299.560` tokens de entrada, `113.448` não cacheados e `245.965` caracteres de ferramentas. A [`WORK-028`](realizacoes.md#work-028--instrumentar-telemetria-autoritativa-do-agente-principal) separou o recibo autoritativo do agente principal do relato de processos filhos.
- **Resultado verificável:** v1/v2 permanecem aprovados; três execuções completas produzem estatísticas sem amostras herdadas ou censuradas; v3 só é promovido se cumprir os limites documentados sem perda semântica.
- **Próxima ação:** consolidar os limites aprendidos em `WORK-022`, preservar v1/v2 como padrão e encerrar este ciclo sem executar três suítes v3 até que uma hipótese nova reduza primeiro o custo no cenário focal.

### WORK-023 — Aplicar as fronteiras arquiteturais ao código

- **Estado:** `a_fazer`.
- **Dependências:** stack aceita em `WORK-012`, agente de stack de `WORK-013` quando aplicável e início de `WORK-014`.
- **Objetivo:** codificar direções de dependência, autoridades de dados e arestas permitidas em testes estruturais da stack escolhida.
- **Resultado verificável:** uma dependência proibida falha com mensagem de correção; módulos válidos, contratos de borda e invariantes de autoridade passam no build.
- **Próxima ação:** depois do esqueleto da aplicação, mapear diretórios reais em `ARCHITECTURE.md` e criar o primeiro contrafactual estrutural.

### WORK-024 — Tornar o runtime legível e isolado para agentes

- **Estado:** `a_fazer`.
- **Dependência:** primeira fatia executável de `WORK-014`.
- **Objetivo:** oferecer bootstrap e teardown isolados por worktree, dados sintéticos, jornadas reproduzíveis e consultas locais de logs, métricas e traces.
- **Resultado verificável:** um agente reproduz uma falha, observa sua evidência e valida a correção sem contexto externo nem colisão com outra worktree.
- **Próxima ação:** definir comandos e isolamento a partir do runtime real, sem antecipar portas, namespaces ou ferramentas ainda não escolhidas.

## Depois da primeira evidência operacional

### WORK-025 — Definir autonomia progressiva

- **Estado:** `a_fazer`.
- **Dependências:** gates de `WORK-021`, avaliação concluída de [`WORK-022`](realizacoes.md#work-022--avaliar-a-navega%C3%A7%C3%A3o-arquitetural-do-harness) e repositório remoto com fluxo de PR disponível.
- **Objetivo:** explicitar níveis de leitura, edição local validada, PR draft, resposta a revisão e merge, com escalonamento humano e trilha de auditoria.
- **Resultado verificável:** um piloto chega até PR draft e responde a falhas dos gates; merge autônomo permanece desabilitado até existir evidência específica para promovê-lo.
- **Próxima ação:** após a coleta viva, definir o piloto de menor risco e registrar seus limites de permissão.

### WORK-026 — Instituir coleta de lixo incremental do harness

- **Estado:** `a_fazer`.
- **Dependências:** início do desenvolvimento da aplicação e gates de `WORK-021`.
- **Objetivo:** auditar duplicações, documentos obsoletos, divergências de estado e dívida arquitetural em correções pequenas e revisáveis.
- **Resultado verificável:** achados registram evidência, idade e ação; decisões e históricos nunca são apagados silenciosamente; falhas recorrentes ganham contrafactual no controle mais próximo.
- **Próxima ação:** executar a primeira auditoria manual após dez PRs ou antes do próximo marco acadêmico, o que ocorrer primeiro.

## Regra de atualização

Ao iniciar um item, altere seu estado para `em_andamento` e registre a próxima ação efetiva. Ao concluir:

1. remova o ID de `entities` e a seção completa deste arquivo;
2. acrescente o mesmo ID ao `entities` de `realizacoes.md`;
3. registre resultado, evidências, decisões ou aprendizados relevantes e data de conclusão;
4. atualize dependências e próximas ações dos itens restantes;
5. execute `scripts/validar-contexto.sh` e as demais verificações do escopo;
6. se algum erro tiver sido encontrado, conclua também a correção de processo exigida por `CTX-GOV-002`.

Um item pode ser dividido antes de começar. Depois de produzir resultados, preserve seu ID e crie IDs sucessores relacionados em vez de reescrever silenciosamente seu significado.
