---
context_id: CTX-EVD-CMP-003
context_type: evidence
status: registrado
recorded_at: 2026-08-05
valid_from: 2026-08-05
relations:
  - type: derived_from
    target: CTX-REQ-001
  - type: informed_by
    target: CTX-DOM-001
  - type: informed_by
    target: CTX-DOM-002
  - type: informed_by
    target: CTX-CHAR-001
  - type: informed_by
    target: CTX-CMP-002
  - type: informed_by
    target: R6-CMP-MODEL-001
  - type: informs
    target: CTX-CMP-003
  - type: informs
    target: DEC-0004
  - type: governed_by
    target: CTX-GOV-001
---

# Evidência do refinamento que produziu `CTX-CMP-003`

> **Registro histórico:** este documento preserva o ciclo executado em 2026-08-03 e extraído do modelo ativo em 2026-08-05 para separar derivação e definição vigente. Ele explica como se chegou ao resultado; as fronteiras correntes pertencem exclusivamente ao [`CTX-CMP-003`](../../componentes-coesos.md).
>
> Navegação: [modelo ativo](../../componentes-coesos.md) · [decisão que o aceitou](../../decisoes/0004-componentes-coesos-do-nucleo.md) · [índice de arquitetura](../../README.md)

## Escopo, evidências e premissas

O ciclo confrontou o modelo granular [`CTX-CMP-002`](ctx-cmp-002-componentes-modulares.md) e a proposta [`R6-CMP-MODEL-001`](../../../propostas/base-simplificada-seis-componentes/componentes.md) com as histórias canônicas [`US-01..US-07`](../../../requisitos/historias.md), consolidadas por [`REQ-CHG-0003`](../../../requisitos/refinamentos/REQ-CHG-0003.md).

Classificação das entradas usada na análise:

| Classe | Evidência usada |
|---|---|
| **Declarada** | autenticação, envio, processamento concorrente, não perda, consulta por usuário, ZIP e possibilidade de notificação de falha |
| **Validada na descoberta** | admissão antes do aceite, distinção entre submissão, reentrega, retentativa e reprocessamento, retenção atual e ordem da comunicação |
| **Decidida naquele estágio** | ciclo de refinamento de [`DEC-0001`](../../decisoes/0001-refinamento-de-componentes.md) e consolidação conservadora confirmada por `REQ-CHG-0003` |
| **Inferida** | contratos, projeções, idempotência, outbox/inbox e detalhes de autoridade propostos para tornar as necessidades verificáveis |

Componente foi tratado como limite lógico e modular. Quantum, processo, imagem, `Deployment`, banco, fila e provedor de identidade não determinaram o inventário.

## Iteração 1 — Componentes identificados

### Técnica e inventário inicial congelado

Foi usado `Workflow`, complementado por `Actor/Action`: autenticar, submeter, governar, processar, publicar ou entregar, consultar e comunicar. O particionamento inicial foi orientado ao domínio; mecanismos como HTTP, OIDC, RabbitMQ, storage e FFmpeg não originaram componentes.

| Componente inicial | Papel derivado do fluxo | Evidência principal |
|---|---|---|
| Autenticação e Identidade | estabelecer a identidade confiável de quem realiza uma operação | `US-01` |
| Submissão de Vídeos | receber, admitir e encaminhar um vídeo para aceite | `US-02` |
| Gestão do Trabalho | preservar o trabalho e arbitrar seu ciclo | `US-04` |
| Processamento de Mídia | transformar uma origem em imagens e resultado | `US-03` |
| Entrega de Resultados | tornar o ZIP acessível ao proprietário | `US-06` |
| Consulta de Trabalhos | apresentar os trabalhos do usuário | `US-05` |
| Comunicação de Falhas | comunicar uma falha já registrada | `US-07` |

O inventário permaneceu congelado durante a atribuição e as duas análises seguintes. Não foi observado `Entity Trap`: trabalho e resultado apareciam em mais de um candidato, mas cada uso possuía comportamento, autoridade e razão de mudança a confrontar.

## Iteração 1 — Histórias atribuídas

| História | Responsável principal | Colaboradores | Observações |
|---|---|---|---|
| `US-01` | Autenticação e Identidade | provedor de identidade | autenticação permaneceu integralmente no escopo |
| `US-02` | Submissão de Vídeos | Identidade; Gestão do Trabalho | submissão coordenava a história nesta iteração |
| `US-03` | Processamento de Mídia | Gestão; Entrega | concorrência e isolamento pertenciam ao processamento |
| `US-04` | Gestão do Trabalho | Submissão; Processamento; Entrega | somente Gestão arbitrava novas tentativas e desfechos |
| `US-05` | Consulta de Trabalhos | Identidade; Gestão | leitura não alterava o ciclo |
| `US-06` | Entrega de Resultados | Identidade; Gestão; Processamento | publicação e autorização ainda estavam misturadas |
| `US-07` | Comunicação de Falhas | Gestão | comunicação ocorria depois da falha persistida |

Cada história possuía exatamente um responsável principal; colaboradores forneciam contratos e não compartilhavam essa autoridade.

## Iteração 1 — Papéis e responsabilidades analisados

O inventário continuou congelado.

| Componente inicial | Achado de responsabilidade ou acoplamento | Sinal registrado para a refatoração posterior |
|---|---|---|
| Autenticação e Identidade | autenticar credenciais, validar token e decidir propriedade eram autoridades diferentes | separar Keycloak, identidade autenticada e autorização sobre o recurso |
| Submissão de Vídeos | transferência ou admissão e aceite do trabalho possuíam transações e falhas distintas | restringir a entrada e deixar o aceite com a autoridade do ciclo |
| Gestão do Trabalho | alto `fan-in` era coerente para arbitrar estado, ciclo e tentativas | manter autoridade única e reduzir conhecimento de adaptadores a jusante |
| Processamento de Mídia | extração e publicação compartilhavam fluxo, mas publicação possuía invariante próprio de recuperabilidade | separar transformação de manifestação durável do resultado |
| Entrega de Resultados | publicação ou escrita e autorização ou leitura mudavam por motivos diferentes | dividir Publicação de Acesso |
| Consulta de Trabalhos | projeção somente leitura possuía política própria de propriedade e consistência | manter separada do escritor do ciclo |
| Comunicação de Falhas | falha de canal e retentativas externas não deveriam alterar trabalho | manter coesa e limitada à falha no núcleo |

Acoplamentos temporais registrados:

- origem recuperável precede aceite;
- aceite persistido precede despacho;
- tentativa autorizada precede execução;
- imagens, manifesto e ZIP recuperáveis precedem conclusão;
- falha persistida precede notificação.

## Iteração 1 — Características do sistema analisadas

As características permaneceram propriedades sistêmicas e não foram atribuídas aos componentes durante esta etapa.

| Característica | Pressão observada nas fronteiras | Verificação proposta |
|---|---|---|
| Confiabilidade e recuperabilidade | uma autoridade de ciclo, aceite durável, idempotência e publicação antes da conclusão | reinício depois do aceite, mensagem duplicada e reconciliação entre estado e ZIP |
| Segurança | IdP externo, identidade estável, autorização no proprietário do recurso e entrada não confiável | `401/403`, dois usuários e ausência de acesso cruzado |
| Escalabilidade do processamento | execução intensiva separável do fluxo interativo, com concorrência e scratch limitados | variar réplicas sob backlog sem colisão nem perda |
| Viabilidade operacional | poucos processos, mas perfis de falha e escala explícitos | ambiente Kubernetes reproduzível e medição do custo dos quanta |

O isolamento da execução e da comunicação apresentava como custo contratos assíncronos, consistência eventual, observabilidade e operação adicional.

## Iteração 1 — Refatoração motivada

| Origem congelada | Achado anterior | Alteração aplicada somente nesta etapa | Resultado atual |
|---|---|---|---|
| Autenticação e Identidade | autoridade sobre propriedade estava sobreposta | manter e restringir à integração OIDC e identidade autenticada | [`CMP-18`](../../componentes-coesos.md#cmp-18) |
| Submissão de Vídeos | entrada e aceite possuíam falhas ou transações distintas | unir submissão e admissão; mover aceite para o ciclo | [`CMP-19`](../../componentes-coesos.md#cmp-19) |
| Gestão do Trabalho | centralização de transições era coesa | renomear e consolidar aceite, tentativas, desfecho e outbox | [`CMP-20`](../../componentes-coesos.md#cmp-20) |
| Processamento de Mídia | publicação possuía invariante durável próprio | restringir à execução e extração | [`CMP-21`](../../componentes-coesos.md#cmp-21) |
| Entrega de Resultados | escrita e leitura possuíam segurança e escala diferentes | dividir em Publicação e Acesso | [`CMP-22`](../../componentes-coesos.md#cmp-22) e [`CMP-24`](../../componentes-coesos.md#cmp-24) |
| Consulta de Trabalhos | leitura e propriedade formavam papel coeso | manter | [`CMP-23`](../../componentes-coesos.md#cmp-23) |
| Comunicação de Falhas | canal externo tinha falha própria, sem autoridade de estado | manter e restringir à falha | [`CMP-25`](../../componentes-coesos.md#cmp-25) |

Oito componentes resultaram desses achados; a quantidade não foi uma meta de descoberta.

## Iteração 2 — Componentes identificados

O inventário refinado abaixo foi congelado para repetir atribuição e análises. Papéis, autoridades e contratos correntes permanecem definidos apenas no [modelo ativo](../../componentes-coesos.md#invent%C3%A1rio-vigente).

| ID | Componente refinado | Resultado da refatoração |
|---|---|---|
| `CMP-18` | Autenticação e Identidade | identidade separada da propriedade do recurso |
| `CMP-19` | Submissão e Admissão | entrada separada do aceite do trabalho |
| `CMP-20` | Ciclo do Trabalho | autoridade única sobre estado, tentativa e desfecho |
| `CMP-21` | Processamento de Mídia | execução separada da publicação durável |
| `CMP-22` | Publicação de Resultados | escrita e manifestação durável separadas do acesso |
| `CMP-23` | Consulta de Trabalhos | projeção somente leitura preservada |
| `CMP-24` | Acesso a Resultados | autorização e entrega separadas da publicação |
| `CMP-25` | Comunicação de Falhas | falha de canal isolada do estado do trabalho |

## Iteração 2 — Histórias atribuídas

| História | Responsável principal | Colaboradores | Contrato conceitual entre fronteiras |
|---|---|---|---|
| `US-01` | `CMP-18` | Keycloak | OIDC → `IdentidadeAutenticada` |
| `US-02` | `CMP-19` | `CMP-18`, `CMP-20` | `OrigemAdmitida` → `AceitarTrabalho` |
| `US-03` | `CMP-21` | `CMP-20`, `CMP-22` | `ProcessarTentativa` → imagens, publicação ou falha técnica |
| `US-04` | `CMP-20` | `CMP-19`, `CMP-21`, `CMP-22` | aceite, tentativa autorizada e fatos correlacionados |
| `US-05` | `CMP-23` | `CMP-18`, `CMP-20` | identidade e fatos de projeção |
| `US-06` | `CMP-24` | `CMP-18`, `CMP-20`, `CMP-22` | identidade, elegibilidade e manifesto |
| `US-07` | `CMP-25` | `CMP-20` | `TrabalhoFalhou` autossuficiente |

## Iteração 2 — Papéis e responsabilidades analisados

O inventário refinado permaneceu congelado.

| Questão | Resultado observado |
|---|---|
| História sem responsável ou responsabilidade dupla | nenhuma; cada `US-*` possuía um principal |
| Autoridade do estado | somente `CMP-20` criava e alterava o ciclo do trabalho |
| Autoridade de identidade e propriedade | Keycloak autenticava; `CMP-18` validava; `CMP-20/23/24` aplicavam propriedade no recurso conhecido |
| Autoridade de falha e retry | `CMP-21/22` relatavam falha técnica; somente `CMP-20` decidia política e estado |
| Publicação versus acesso | `CMP-22` escrevia a manifestação durável; `CMP-24` autorizava e entregava |
| Acoplamento temporal | os cinco precedentes relevantes possuíam fatos ou contratos conceituais explícitos |
| Lei de Deméter | Submissão não conhecia Produção ou Comunicação; mídia não conhecia usuário; Comunicação não consultava estado |
| Entity Trap | trabalho aparecia em várias fronteiras, mas nenhuma delas oferecia CRUD genérico |

`CMP-20` apresentava maior `fan-in`, coerente com a autoridade de transição. Na redação de trabalho de 2026-08-03, seu `fan-out` físico era descrito como reduzido por outbox e fatos. A quantificação estática de `CA/CE` permaneceu dependente dos módulos implementados.

## Iteração 2 — Características do sistema analisadas

| Característica | Evidência lógica de adequação | Custo ou pendência registrada |
|---|---|---|
| Confiabilidade | aceite, outbox, tentativa, publicação e desfecho possuíam autoridades testáveis | atomicidade física e reconciliação ainda dependiam da prova vertical |
| Segurança | credenciais ficavam no Keycloak; identidade e propriedade não se confundiam | realm, clientes, limites e Threat Modeling precisavam ser materializados |
| Escalabilidade | processamento e publicação podiam variar capacidade sem possuir o trabalho | carga, concorrência e recursos-alvo continuavam a medir |
| Operabilidade | notificação isolada impedia que falha de canal afetasse o núcleo | terceiro processo aumentava manifests, dados, observabilidade e custo de operação |

## Iteração 2 — Verificação de convergência

| Critério | Resultado em 2026-08-03 |
|---|---|
| Sete histórias com um responsável principal | atendido |
| Oito papéis distintos e justificados | atendido pelas histórias e características prioritárias |
| Autoridades não duplicadas | atendido para identidade, propriedade, estado, falha ou retry e resultado |
| Contratos e ordens relevantes explícitos | atendido conceitualmente |
| Mecanismos não tratados como componentes | atendido para IdP, broker, storage, outbox, FFmpeg e Kubernetes |
| Extensões futuras fora do núcleo | atendido conforme `REQ-CHG-0003` |
| Evidência física | permaneceu pendente de código, testes, Threat Modeling e medição |

O ciclo convergiu para o baseline modular posteriormente aceito por [`DEC-0004`](../../decisoes/0004-componentes-coesos-do-nucleo.md). Esta evidência não deve ser atualizada com definições futuras: uma mudança de fronteira exige nova evidência e, quando mudar o significado vigente, um nó sucessor do modelo.

## Reclassificação documental em 2026-08-05

A redação de trabalho de 2026-08-03 atribuía inbox e outbox ao Ciclo, deduplicação técnica ao Processamento, chaves imutáveis, promoção de temporários e outbox à Publicação, e uma inbox de entrega à Comunicação. Essas formulações são preservadas aqui como hipóteses inferidas usadas para tornar a confiabilidade verificável naquele ciclo; não constituíam escolha física aceita.

Na extração deste registro, as obrigações lógicas permaneceram no modelo ativo: identidade estável da tentativa, execução e publicação idempotentes, resultado visível único e entrega de fatos sem transferência de autoridade. Inbox, outbox, chaves e o mecanismo concreto de deduplicação foram reclassificados como realizações candidatas da [`DEC-0003`](../../decisoes/0003-entrega-duravel-e-persistencia.md), ainda `em_analise`. Esta nota registra a reclassificação sem reescrever a análise original nem promover seus mecanismos.

## Agrupamento posterior ao refinamento

Somente depois dessa convergência, [`DEC-0002`](../../decisoes/0002-topologia-kubernetes.md) aceitou três quanta para o ambiente de validação. A composição física e suas condições de revisão pertencem ao ADR, não a este registro histórico nem ao inventário lógico.
