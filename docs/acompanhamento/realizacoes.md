---
context_id: CTX-OUTCOME-001
context_type: outcome_log
status: ativo
recorded_at: 2026-08-01
valid_from: 2026-08-01
entities:
  - WORK-001
  - WORK-002
  - WORK-003
  - WORK-004
  - WORK-005
  - WORK-006
  - WORK-007
  - WORK-008
  - WORK-009
  - WORK-010
  - WORK-015
  - WORK-016
  - WORK-017
  - WORK-019
  - WORK-020
  - WORK-021
  - WORK-028
relations:
  - type: governed_by
    target: CTX-GOV-001
  - type: derived_from
    target: CTX-ROADMAP-001
---

# Registro de realizações

## Finalidade

Preservar resultados e aprendizados relevantes depois que um item deixa o [roadmap ativo](roadmap.md). Este é um registro contextual, não uma lista de tarefas nem um diário de cada edição.

Cada realização mantém o ID estável do trabalho, data, resultado, evidências e relações úteis. Ela deve registrar o que passou a ser verdadeiro ou reutilizável, sem copiar integralmente os artefatos produzidos.

## Realizações

### WORK-001 — Avaliar o projeto-base

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-01.
- **Resultado:** o comportamento, as limitações e a divergência do Dockerfile do protótipo Go foram documentados como observações, sem torná-los direção obrigatória da solução.
- **Evidência:** seção “Estado observado do projeto-base” em [`../contexto-projeto.md`](../contexto-projeto.md).
- **Relações:** informa `CTX-PRJ-001`, `CTX-REQ-001` e `CTX-CHAR-001`.

### WORK-002 — Criar governança inicial de agentes

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-01.
- **Resultado:** foram definidos princípios compartilhados, um arquiteto consultivo somente leitura, critérios para agentes especializados e a skill de refinamento de componentes.
- **Evidência:** [`../../AGENTS.md`](../../AGENTS.md), [`../agentes.md`](../agentes.md), [`../../.codex/agents/arquiteto.toml`](../../.codex/agents/arquiteto.toml) e [`../../.agents/skills/refinar-componentes-arquiteturais/SKILL.md`](../../.agents/skills/refinar-componentes-arquiteturais/SKILL.md).
- **Informação relevante:** o especialista Java e Quarkus permanece candidato até existir uma decisão aceita e uma primeira fatia de implementação.

### WORK-003 — Executar o primeiro ciclo de componentes

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-01.
- **Resultado:** histórias foram atribuídas a quatro componentes lógicos, com papéis, autoridades, contratos, lacunas e critérios de convergência explícitos.
- **Evidência:** [`../arquitetura/historico/componentes/ctx-cmp-001-componentes-macro.md`](../arquitetura/historico/componentes/ctx-cmp-001-componentes-macro.md).
- **Relações:** produzido a partir de `CTX-REQ-001`, `CTX-DOM-001` e `CTX-CHAR-001`; informa o modelo `CTX-CMP-001`.
- **Informação relevante:** componente lógico ainda não significa serviço nem quantum; acoplamento e implantação continuam em análise.

### WORK-004 — Criar diagrama lógico de componentes

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-01.
- **Resultado:** o modelo então vigente [`CTX-CMP-001`](../arquitetura/historico/componentes/ctx-cmp-001-componentes-macro.md) ganhou uma representação Mermaid com interações e limites explícitos.
- **Evidência:** seção “Diagrama lógico” em [`../arquitetura/historico/componentes/ctx-cmp-001-componentes-macro.md`](../arquitetura/historico/componentes/ctx-cmp-001-componentes-macro.md).
- **Relações:** refina `CTX-CMP-001`.

### WORK-005 — Estabelecer glossário do domínio

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-01.
- **Resultado:** termos preferidos, definições, limites, classificações e estados candidatos do trabalho foram centralizados em um vocabulário evolutivo.
- **Evidência:** [`../requisitos/glossario.md`](../requisitos/glossario.md).
- **Relações:** produziu `CTX-DOM-001`, que informa `CTX-REQ-001` e `CTX-CMP-001`.
- **Informação relevante:** itens marcados `A confirmar` continuam questões, não requisitos aceitos.

### WORK-006 — Tornar o contexto compatível com evolução para grafo

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-01.
- **Resultado:** artefatos contextuais receberam IDs, tipos, procedência, validade temporal e relações; uma verificação estrutural automatizada foi criada.
- **Evidência:** [`../contexto/README.md`](../contexto/README.md), metadados dos documentos e [`../../scripts/validar-contexto.sh`](../../scripts/validar-contexto.sh).
- **Relações:** produziu a política `CTX-GOV-001` e governa os nós contextuais subsequentes.
- **Informação relevante:** Markdown versionado continua sendo a fonte; ainda não há necessidade comprovada de banco de grafos.

### WORK-007 — Aplicar Progressive Context Disclosure

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-01.
- **Resultado:** agentes passaram a descobrir contexto por rotas orientadas a tarefas, com pacotes mínimos, condições de expansão e limites explícitos de carregamento.
- **Evidência:** [`../contexto/roteador.md`](../contexto/roteador.md) e a seção “Curadoria de contexto” de [`../../AGENTS.md`](../../AGENTS.md).
- **Relações:** produziu `CTX-ROUTE-001` e aplica a política `CTX-GOV-001`.
- **Informação relevante:** relações do Context Graph indicam contexto potencial; somente uma lacuna concreta justifica atravessá-las.

### WORK-008 — Conduzir Event Storming enxuto

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-02.
- **Resultado:** o fluxo do envio ao resultado ou à falha foi revisado com o responsável; ficaram explícitos o ponto de aceitação, a precedência e agregação das validações de admissão, a ausência de cota funcional de novas tentativas, a retenção sem prazo, o momento de comunicação das falhas e a direção incremental de autogestão de contas.
- **Evidência:** [Event Storming validado e resultado das seis questões](../requisitos/event-storming.md#resultado-da-revisão-das-questões).
- **Relações:** produziu [`CTX-DOM-002`](../requisitos/event-storming.md), que informou [`WORK-009`](#work-009--incorporar-descobertas-do-event-storming) e a revalidação de [`CTX-CMP-001`](../arquitetura/historico/componentes/ctx-cmp-001-componentes-macro.md).
- **Informação relevante:** WebSocket e SSE permanecem opções de transporte; retenção sem prazo não impede uma futura política de exclusão; ausência de cota funcional total de tentativas não define gatilho automático nem elimina idempotência e salvaguardas operacionais.
- **Revisão arquitetural:** as descobertas preservam as autoridades atuais, mas ampliam os contratos candidatos de Trabalhos de Vídeo e Identidade e Acesso. Nenhum novo componente ou quantum foi decidido antes de incorporar os requisitos e reexecutar o refinamento.

### WORK-009 — Incorporar descobertas do Event Storming

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-02.
- **Resultado:** histórias e glossário passaram a distinguir nova submissão, cota acumulada, limite operacional, retentativa automática por ciclo, reprocessamento solicitado e reentrega duplicada; admissão, retenção, comunicação de falha e direção futura de contas também foram consolidadas.
- **Evidência:** [`../requisitos/historias.md`](../requisitos/historias.md) e [`../requisitos/glossario.md`](../requisitos/glossario.md), informados pelo [`CTX-DOM-002`](../requisitos/event-storming.md).
- **Relações:** refina `CTX-REQ-001` e `CTX-DOM-001`; informa a revalidação de [`WORK-010`](#work-010--refinar-componentes-e-delimitar-quanta-arquiteturais).
- **Informação relevante:** não existe cota acumulada de trabalhos, mas limites operacionais podem proteger capacidade; retentativas automáticas do mesmo processamento possuem ciclo finito; reprocessamento manual preserva trabalho, origem e histórico.
- **Revisão arquitetural:** as quatro fronteiras lógicas foram preservadas. Trabalhos de Vídeo continua autoridade sobre admissão, estado, ciclos e retenção; Processamento de Mídia executa tentativas autorizadas; transporte de atualização e topologia permanecem em análise.
- **Pendências:** valores de admissão e capacidade, quantidade e espera do ciclo automático, taxonomia de falhas, atomicidade da aceitação, canal de notificação, atualização em tempo real e provisionamento de contas seguem explicitamente para os próximos trabalhos.

### WORK-010 — Refinar componentes e delimitar quanta arquiteturais

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-02.
- **Resultado:** o ciclo do capítulo 8 foi reexecutado na ordem `identificar → atribuir histórias → analisar responsabilidades → analisar características do sistema → refatorar → repetir e verificar`. Seis componentes iniciais foram diagnosticados sem alterar o inventário durante as análises e refatorados em treze componentes modulares; cada história possui exatamente um responsável principal nas duas atribuições.
- **Evidência:** modelo então corrente [`CTX-CMP-002`](../arquitetura/historico/componentes/ctx-cmp-002-componentes-modulares.md), decisão [`DEC-0001`](../arquitetura/decisoes/0001-refinamento-de-componentes.md), características sistêmicas [`CTX-CHAR-001`](../arquitetura/caracteristicas.md#agrupamento-preliminar-por-escopo), skill [`refinar-componentes-arquiteturais`](../../.agents/skills/refinar-componentes-arquiteturais/SKILL.md) e fitness function [`validar-componentes.sh`](../../scripts/validar-componentes.sh), na versão vigente em 2026-08-02.
- **Relações:** `DEC-0001` produziu `CTX-CMP-002`, que substitui [`CTX-CMP-001`](../arquitetura/historico/componentes/ctx-cmp-001-componentes-macro.md) sem apagar as iterações anteriores; informa [`WORK-011`](../acompanhamento/roadmap.md#work-011--executar-threat-modeling-inicial) e [`WORK-012`](../acompanhamento/roadmap.md#work-012--registrar-as-primeiras-decisões-arquiteturais).
- **Informação relevante:** componente lógico é uma manifestação modular de comportamento, implementável como pacote, módulo ou biblioteca, e não equivale a microsserviço ou quantum. Quatro agrupamentos de quanta foram preservados apenas como hipóteses reversíveis; quantidade, limites e topologia não foram aceitos.
- **Validação:** o modelo passou na validação de contexto e nos controles de ordem das etapas, atribuição única das sete histórias, motivação dos treze componentes e quatro agrupamentos apenas candidatos. Casos contrafactuais comprovaram rejeição de fase ausente ou fora de ordem, história ausente ou duplicada, componente sem motivação e afirmação prematura de topologia.
- **Meta-PDCA aplicado:** o processo anterior permitia antecipar quanta e modificar componentes durante etapas diagnósticas. A skill passou a congelar o inventário nessas etapas, e `validar-componentes.sh` tornou a sequência e as invariantes objetivamente verificáveis. A primeira mutação de etapa ausente revelou que `set -e` encerrava o validador antes do diagnóstico; a contagem de títulos passou a tratar explicitamente ausência e duplicidade, e toda a bateria contrafactual foi reexecutada com sucesso.

### WORK-015 — Instituir Meta-PDCA para falhas

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-01.
- **Resultado:** toda falha encontrada passou a exigir correção tanto do artefato quanto do ponto de processo que deveria preveni-la ou detectá-la.
- **Evidência:** [`../contexto/meta-pdca.md`](../contexto/meta-pdca.md), instruções compartilhadas, rota de correção de falhas e regra de encerramento do roadmap.
- **Relações:** produziu `CTX-GOV-002`, que refina `CTX-GOV-001` e governa o acompanhamento.
- **Informação relevante:** a correção deve atingir a fonte mais próxima e causalmente relacionada; casos isolados não justificam inflar instruções globais.
- **Meta-PDCA aplicado:** a validação detectou uma relação contextual fora do vocabulário; o metadado foi corrigido e `CTX-ROUTE-001` passou a exigir a rota do Context Graph sempre que frontmatter contextual for criado ou alterado.

### WORK-016 — Instituir histórico semântico e governança de requisitos

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-02.
- **Resultado:** refinamentos de histórias passaram a registrar separadamente quem analisou, quem materializou, quem confirmou, quando, o que mudou e quais evidências sustentaram a alteração; um Analista de Negócio consultivo prepara futuras mudanças sem substituir a autoridade do responsável pelo produto.
- **Evidência:** política [`CTX-GOV-003`](../contexto/rastreabilidade-refinamentos.md), agente [`analista-negocio`](../../.codex/agents/analista-negocio.toml), registros [`REQ-CHG-0001`](../requisitos/refinamentos/REQ-CHG-0001.md) e [`REQ-CHG-0002`](../requisitos/refinamentos/REQ-CHG-0002.md), backlinks em [`CTX-REQ-001`](../requisitos/historias.md) e validação em [`scripts/validar-contexto.sh`](../../scripts/validar-contexto.sh).
- **Relações:** produziu `CTX-GOV-003`, `REQ-CHG-0001` e `REQ-CHG-0002`; refina a governança iniciada por [`WORK-002`](#work-002--criar-governança-inicial-de-agentes) e [`WORK-006`](#work-006--tornar-o-contexto-compatível-com-evolução-para-grafo).
- **Informação relevante:** histórias continuam agregadas; eventos imutáveis fornecem o histórico por arestas `affects` e links recíprocos. Glossário, Event Storming, características, componentes, agentes e políticas adotarão o mecanismo somente diante de uma nova mudança semântica material.
- **Validação:** os controles rejeitam registro sem ator, confirmação sem data, alvo que não seja história, arquivo divergente, link de retorno ausente e backlink ausente; autoria histórica desconhecida permanece explícita em vez de ser inferida do Git.
- **Limite:** a evidência de `WORK-009` anteriormente revertida não foi alterada; este trabalho valida apenas os links e âncoras que introduziu.

### WORK-017 — Estabelecer baseline e contrato de avaliação do harness

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-13.
- **Resultado:** três cenários repetíveis — Threat Modeling, ADR e Context Graph — foram congelados com prompts, schemas, oráculos semânticos e limite de duas rodadas de correção. A baseline executada sem modificar o harness aprovou os três cenários na primeira tentativa, sem retrabalho.
- **Evidência:** contrato, comandos, critérios e análise em [`CTX-EVD-HARNESS-001`](../avaliacoes/harness/README.md), resultado normalizado em [`baseline-2026-08-13.json`](../avaliacoes/harness/resultados/baseline-2026-08-13.json) e executor em [`avaliar-harness.sh`](../../scripts/avaliar-harness.sh).
- **Medições:** 407.429 tokens de entrada, dos quais 292.864 em cache, 7.260 tokens de saída e 1.692 tokens de raciocínio; três tentativas no total e zero rodadas de correção. Threat Modeling, ADR e Context Graph carregaram, respectivamente, 14, 5 e 13 fontes.
- **Relações:** produz `CTX-EVD-HARNESS-001` e informa [`WORK-018`](../acompanhamento/roadmap.md#work-018--adotar-harness-spec-driven-enxuto); os cenários preservam a semântica ainda pendente de [`WORK-011`](../acompanhamento/roadmap.md#work-011--executar-threat-modeling-inicial) e [`WORK-012`](../acompanhamento/roadmap.md#work-012--registrar-as-primeiras-decisões-arquiteturais).
- **Informação relevante:** os cenários de Threat Modeling e Context Graph carregaram mais fontes que o cenário de ADR. Isso é uma hipótese mensurável de simplificação para `WORK-018`, não uma falha da baseline.
- **Validação:** o executor verificou schemas, oráculos, métricas e imutabilidade do harness antes e depois da execução; a evidência normalizada registra os hashes do contrato. O autoteste cobriu respostas válidas, omissão de gate `P0`, binário ou resposta ausentes, consistência do resultado registrado e incompatibilidades conhecidas com o subconjunto de JSON Schema aceito pelo Codex.
- **Meta-PDCA aplicado:** falhas de ambiente, tratamento de saída e compatibilidade de schema encontradas durante a preparação passaram a produzir diagnóstico explícito e falha antecipada no próprio executor. Casos contrafactuais foram incorporados ao autoteste para impedir recorrência antes de consumir uma nova execução de modelo.

### WORK-019 — Formalizar o contrato das fontes

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-15.
- **Resultado:** ficaram explícitos os papéis não sobrepostos de `README.md`, `AGENTS.md`, `ARCHITECTURE.md`, `docs/` e `.codex/`; instruções específicas do Codex deixaram de repetir regras globais.
- **Evidência:** [`../../AGENTS.md`](../../AGENTS.md), [`../../.codex/instructions.md`](../../.codex/instructions.md) e [catálogo documental](../README.md).
- **Informação relevante:** o mapa arquitetural é carregado somente quando a tarefa exige visão sistêmica; não se tornou contexto obrigatório para todo trabalho.

### WORK-020 — Criar o mapa arquitetural da raiz

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-15.
- **Resultado:** [`ARCHITECTURE.md`](../../ARCHITECTURE.md) passou a distinguir estado observado, decisões aceitas, alternativas em análise, oito componentes, três quanta, invariantes e autoridades documentais sem duplicar contratos detalhados.
- **Evidência:** mapa da raiz, [catálogo de arquitetura](../arquitetura/README.md) e [`scripts/validar-mapa-arquitetural.sh`](../../scripts/validar-mapa-arquitetural.sh).
- **Informação relevante:** a árvore de código permanece ausente e não foi inventada; será registrada quando a primeira fatia existir.

### WORK-021 — Transformar validadores em gates de CI

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-15.
- **Resultado:** um comando agrega mapa, contratos v1/v2, Context Graph, documentação, fitness functions e contrafactuais; um workflow executa os mesmos gates em PR e `main` sem invocar avaliação viva paga.
- **Evidência:** [`scripts/validar-harness.sh`](../../scripts/validar-harness.sh) e [workflow de validação](../../.github/workflows/validar-harness.yml).
- **Informação relevante:** a primeira execução no GitHub depende de publicar esta mudança; localmente, os gates determinísticos passam.
- **Meta-PDCA aplicado:** a primeira varredura rejeitou um link do novo prompt com profundidade incorreta; o link foi corrigido e o validador focal do mapa passou a conferir essa referência antes da varredura documental completa. O lint também tornou explícito que backticks pesquisados são literais Markdown. Nas coletas vivas, o novo comando agregado tornou ambíguo o formato dos dois validadores exigidos pelo oráculo v1; a documentação passou a preservar seus caminhos literais. A variância de fontes revelou ainda que o manifesto não cobria toda a base consultável; ele passou a hashear Markdown mantido, e o self-test exige uma fonte semântica dos cenários.

### WORK-028 — Instrumentar telemetria autoritativa do agente principal

- **Estado:** `concluido`.
- **Concluído em:** 2026-08-15.
- **Resultado:** um agente ACP local opt-in passou a observar os eventos do App Server, agregar somente turnos raiz, persistir recibos mínimos e anexar tempo/tokens depois da resposta do modelo. O agente padrão permanece disponível e o modelo deixou de ser autoridade sobre a própria telemetria.
- **Evidência:** [`DEC-0007`](../arquitetura/decisoes/0007-recibo-pos-execucao-do-agente-principal.md), [proxy e contrato operacional](../../tools/codex-telemetry/README.md), testes do pacote e integração no [`validar-harness.sh`](../../scripts/validar-harness.sh).
- **Medição focal:** o smoke real corrigido terminou em `6.434 ms`, com um turno raiz e `17.165` tokens exatos (`17.160` de entrada, `6.912` em cache e `5` de saída); o rodapé foi emitido exatamente uma vez antes do terminal ACP.
- **Configuração local:** o IntelliJ recarregou `~/.jetbrains/acp.json`, registrou `Codex FIAPX (métricas)` e preservou o agente de registry; o arquivo anterior foi salvo como backup local com permissão restrita.
- **Validação:** doze testes cobriram agregação multturno, exclusão de filhos, interrupção, uso ausente, duplicata, persistência indisponível, framing e dados sensíveis; o handshake e um turno reais passaram, além de documentação, contexto e contratos v1/v2/v3.
- **Meta-PDCA aplicado:** o teardown inicial deixou uma thread de entrada no buffer global e ganhou encerramento limpo com contrafactual de `SIGINT`. O primeiro cliente de smoke combinou `select` com buffering de texto e expirou embora o recibo já estivesse pronto; o cliente reutilizável passou a drenar JSONL binário e o caso foi automatizado.
- **Limite:** a [`DEC-0007`](../arquitetura/decisoes/0007-recibo-pos-execucao-do-agente-principal.md) permanece `em_analise` até existirem observações interativas com ferramenta, subagente e interrupção; testes determinísticos já impedem somar filhos ou inventar tokens.

## Manutenção

- Registre somente entregas concluídas que alterem o estado, o conhecimento reutilizável ou a capacidade do projeto.
- Preserve o ID migrado do roadmap e não mantenha o mesmo ID nos dois arquivos ao mesmo tempo.
- Aponte para evidências em vez de duplicá-las.
- Registre decisões em ADRs próprios; aqui permaneçam apenas o resultado e a referência.
- Se uma realização for invalidada, preserve-a e registre o resultado ou decisão sucessora com relação explícita.
