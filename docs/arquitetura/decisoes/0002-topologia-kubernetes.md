---
context_id: DEC-0002
context_type: decision
status: aceita
recorded_at: 2026-08-03
valid_from: 2026-08-03
relations:
  - type: derived_from
    target: CTX-REQ-001
  - type: informed_by
    target: CTX-CHAR-001
  - type: informed_by
    target: CTX-CMP-002
  - type: informed_by
    target: CTX-CMP-003
  - type: informed_by
    target: DEC-0004
  - type: informed_by
    target: DEC-0005
  - type: informed_by
    target: CTX-ARCH-001
  - type: affects
    target: CTX-ARCH-001
  - type: governed_by
    target: CTX-GOV-001
---

# DEC-0002 — Estilo arquitetural e topologia Kubernetes

## Pergunta

Qual estilo arquitetural e qual topologia de implantação devem atender escala, confiabilidade, segurança e operação do FIAP X sem transformar cada componente lógico em um microsserviço?

## Contexto e evidências

As [histórias e os requisitos técnicos](../../requisitos/historias.md#requisitos-t%C3%A9cnicos-relacionados) exigem persistência, escala, testes e CI/CD. Kubernetes aparece na [stack recomendada do enunciado](../../enunciado.md#stack-tecnol%C3%B3gica-recomendada), não como tecnologia obrigatória ou escolha já aceita. Nesta análise ele é tratado como parte da arquitetura corrente porque a solicitação que originou este ADR pediu explicitamente uma solução em Kubernetes; essa solicitação não transforma a recomendação tecnológica em requisito de negócio nem comprova sua viabilidade operacional.

O modelo histórico [`CTX-CMP-002`](../componentes.md) demonstrou que uma unidade de implantação não pode ser inferida por componente. O sucessor ativo [`CTX-CMP-003`](../componentes-coesos.md), aceito por [`DEC-0004`](0004-componentes-coesos-do-nucleo.md), consolida oito componentes lógicos. A [arquitetura `CTX-ARCH-001`](../comparacao-e-arquitetura-recomendada.md) agrupa esses componentes em três quanta. As três abstrações permanecem distintas:

- **componente lógico** encapsula comportamento, autoridade e contratos e pode ser um módulo dentro de um processo;
- **quantum arquitetural** agrupa capacidades que compartilham características, acoplamento e unidade de evolução;
- **serviço/processo/Deployment** é uma unidade física de execução e implantação.

Assim, três quanta não significam três componentes, e oito componentes não justificam oito microsserviços.

## Características arquiteturais

As [características `CTX-CHAR-001`](../caracteristicas.md) que diferenciam as opções são:

| Característica | Escopo | Evidência a obter |
|---|---|---|
| Confiabilidade e recuperabilidade | Da aceitação ao estado terminal, inclusive durante reinícios e rolling updates | Trabalho aceito sobrevive à remoção de pods e à reentrega duplicada |
| Segurança | Ingress, upload não confiável, propriedade, tráfego interno, identidades de workload e artefatos | Acesso cruzado é negado e os fluxos permitidos funcionam sob política de rede restritiva |
| Escalabilidade do processamento | Backlog e execução de `ffmpeg`, sem escalar obrigatoriamente a API na mesma proporção | Réplicas de `producao-resultados` variam com carga medida, mantendo concorrência limitada e artefatos isolados |
| Operabilidade e viabilidade | Implantação, diagnóstico, recuperação, custo e capacidade do grupo | Runbooks, restauração, observação de filas e operação da DLQ são exercitados pelo grupo |

Não há volume, orçamento ou SLO registrados. A topologia foi aceita para o ambiente acadêmico reproduzível por decisão explícita do responsável, com o custo operacional dos três processos reconhecido. Essas lacunas impedem fixar recursos, réplicas e alegar ganho de escala antes das medições, mas não reabrem silenciosamente a escolha da primeira topologia.

## Opções e trade-offs

| Opção | Benefícios | Custos e riscos | Quando é proporcional |
|---|---|---|---|
| **Um quantum e um Deployment** | Menor custo operacional; transações e execução local mais simples; demonstração rápida | API, `ffmpeg` e notificação escalam e falham juntos; maior contenção e blast radius; um pico de mídia pode degradar acesso e consulta | Protótipo com carga pequena e Kubernetes apenas demonstrativo, desde que a persistência seja externa ao pod |
| **Três quanta e três Deployments** | Isola o perfil intensivo de mídia e falhas de canal; permite escala e limites de recursos diferenciados; preserva poucos contratos físicos | Exige mensageria durável, idempotência, consistência eventual, observabilidade distribuída e maior maturidade operacional | Escolhida para a primeira entrega acadêmica, com consequências a validar |
| **Um microsserviço por componente** | Implantação e escala potencialmente independentes para cada fronteira | Multiplica processos, contratos, credenciais, deploys, falhas parciais e custo de diagnóstico; induz transações distribuídas sem equipes, SLOs ou cargas independentes | Somente se medições e razões de mudança independentes surgirem para componentes específicos |

## Decisão

Adota-se um estilo modular orientado a eventos, distribuído em três quanta e três `Deployment`s de aplicação Kubernetes:

| Quantum | Deployment | Componentes internos | Exposição e escala |
|---|---|---|---|
| Gestão de Trabalhos de Vídeo | `gestao-trabalhos` | `CMP-18` Autenticação e Identidade, `CMP-19` Submissão e Admissão, `CMP-20` Ciclo, `CMP-23` Consulta e `CMP-24` Acesso | `Service` `ClusterIP` e `Ingress`/Gateway com TLS; HPA somente após medição |
| Produção de Resultados | `producao-resultados` | `CMP-21` Processamento de Mídia e `CMP-22` Publicação de Resultados | sem endpoint público; KEDA/HPA por profundidade e idade da fila, CPU e concorrência máxima por pod |
| Comunicação de Falhas | `notificador` | `CMP-25` Comunicação de Falhas | sem exposição pública; KEDA/HPA somente quando backlog e canal justificarem |

O isolamento de Produção de Resultados possui motivação física forte: CPU, memória, I/O, scratch e concorrência diferem da interação. O `notificador` é separado desde o início por escolha consciente: falhas e latência do canal não consomem capacidade da gestão, ao custo de mais uma imagem, contrato, credencial, observabilidade e operação.

Keycloak é instalado no mesmo ambiente por [`DEC-0005`](0005-keycloak-no-ambiente-de-validacao.md), mas permanece workload de plataforma. Ele, PostgreSQL, RabbitMQ, object storage e observabilidade não são quanta nem microsserviços do FIAP X.

A prova vertical deve confrontar, no mínimo:

1. carga e concorrência esperadas, pico, throughput e idade máxima tolerada do backlog;
2. orçamento e custo operacional dos três quanta e dos workloads de plataforma;
3. capacidade operacional para cluster, broker, persistência, backups, restauração, DLQ, atualização e incidentes;
4. Threat Modeling das fronteiras externas e internas e validação das mitigações prioritárias.

## Recursos e operação no Kubernetes

### Workloads e rede

- um `Namespace` por ambiente e os três `Deployment`s de aplicação sem estado durável em disco local;
- `Service` e `Ingress`/Gateway de negócio somente para `gestao-trabalhos`; `producao-resultados` e `notificador` consomem contratos assíncronos;
- Keycloak com `Service` e entrada OIDC próprios; console/administração não é exposto pela mesma rota pública;
- `requests`, `limits`, `startupProbe`, `readinessProbe` e `livenessProbe` próprios para cada perfil;
- `PodDisruptionBudget`, estratégia de rolling update e afinidade/anti-afinidade somente quando réplicas e disponibilidade-alvo as justificarem;
- `Job` versionado para migrações compatíveis com rolling update; rollback de imagem não deve depender de rollback destrutivo de schema;
- `emptyDir` limitado para scratch do `ffmpeg`; origem e resultados duráveis nunca dependem do ciclo de vida do pod.

### Autoscaling e capacidade

- `gestao-trabalhos`: HPA com réplicas stateless, orientado por CPU e métrica de tráfego somente depois de um teste de carga estabelecer alvo;
- `producao-resultados`: KEDA ou HPA com profundidade e idade da fila, combinado com CPU; `maxReplicas` e concorrência por pod protegem broker, banco e object storage;
- `notificador`: KEDA/HPA pelo backlog e limites do canal externo, somente depois de medição;
- Cluster Autoscaler e node pool próprio para mídia são opções do ambiente, não pressupostos deste ADR.

Escala não substitui backpressure: admissão, prefetch, concorrência, limites de recursos e backlog precisam permanecer controlados. Valores concretos continuam pendentes de medição.

### Persistência

PostgreSQL, RabbitMQ e object storage S3-compatible são a recomendação de persistência em análise em [`DEC-0003`](0003-entrega-duravel-e-persistencia.md); se aceitos para uma expectativa real de disponibilidade, devem preferir serviços gerenciados com backup e recuperação. A topologia candidata da demonstração os instala no cluster com armazenamento persistente, mas a escolha e a semântica ainda dependem da prova de `DEC-0003`. Na opção PostgreSQL, Keycloak usa database/schema e credencial próprios. PVC único não comprova alta disponibilidade nem restauração.

### Segurança

- TLS na entrada; autenticação no Keycloak; validação OIDC e autorização por proprietário na aplicação;
- `ServiceAccount`, RBAC e credencial de dados mínimos por quantum, com `NetworkPolicy` deny-by-default;
- `Secrets` fora da imagem e, quando disponível, integração com gerenciador externo; `ConfigMap` somente para configuração não sensível;
- containers sem root, capabilities removidas, perfil `seccomp`, filesystem raiz somente leitura e imagens fixadas por digest;
- upload com limites de tamanho/formato, scratch isolado e comandos `ffmpeg` sem interpolação de shell;
- resultados acessíveis por streaming autorizado ou URL assinada de curta duração, nunca por bucket ou diretório público;
- análise de dependências, SBOM, scan de imagens e política de admissão proporcionais ao ambiente.

### Observabilidade

Logs estruturados, métricas e traces devem correlacionar `workId`, `attemptId` e `messageId` sem registrar credenciais, URLs assinadas ou conteúdo sensível. O painel mínimo cobre:

- trabalhos aceitos, aguardando, processando, concluídos e falhos;
- profundidade e idade do backlog, duração e recursos por vídeo;
- retentativas, duplicidades, DLQ e mensagens sem progresso;
- divergência entre estado concluído e artefato recuperável;
- falhas de notificação, respostas `401/403` e saturação de dependências.

Prometheus/Grafana e coleta centralizada de logs são candidatos compatíveis com o enunciado; a ferramenta específica continua substituível.

### CI/CD

Um pipeline candidato em GitHub Actions deve:

1. compilar e executar testes unitários, de transição, integração, contratos e dependências modulares;
2. validar manifests/Helm/Kustomize e executar smoke tests em cluster efêmero, como `kind`;
3. produzir imagens OCI imutáveis, SBOM e scans de código, dependências, secrets e vulnerabilidades;
4. publicar por digest e promover de forma controlada para staging e demonstração;
5. executar migrações compatíveis, smoke test pós-deploy e rollback da imagem sem perda de dados.

GitHub Actions é uma opção coerente com a stack recomendada, não uma decisão aceita por este ADR.

## Consequências

- Gestão de Trabalhos, Produção de Resultados e Comunicação de Falhas podem evoluir e escalar com perfis distintos sem multiplicar a implantação por componente.
- A fronteira de processo exige contratos assíncronos versionados, idempotência e diagnóstico de consistência eventual.
- O cluster deixa de ser apenas empacotamento: passa a exigir capacidade para operar workloads, dados, segredos, rede, observabilidade e recuperação.
- Um ambiente gerenciado reduz trabalho operacional, mas aumenta dependência e custo; `StatefulSet` em demonstração reduz custo externo, mas transfere risco ao grupo.
- Separar o notificador desde o início aceita custo operacional antes de haver volume que prove escala própria; uma mudança futura exigirá revisar esta decisão, sem redefinir automaticamente os componentes lógicos.

## Validação das consequências

Uma fatia vertical deve ser implantada em cluster e verificar:

- exclusão/reinício de pods depois da aceitação sem desaparecimento do trabalho;
- reentrega duplicada com um único resultado visível;
- aumento e redução das réplicas de `producao-resultados` sob carga, sem alterar a API nem perder trabalhos;
- isolamento de CPU, memória e scratch entre trabalhos e entre quanta;
- rolling update com mensagens em trânsito e contratos retrocompatíveis;
- bootstrap do Keycloak, tentativa de acesso cruzado entre dois usuários, tráfego bloqueado por `NetworkPolicy` e execução sem privilégios;
- restauração de backup e tratamento operacional de uma mensagem na DLQ;
- medição de custo, throughput, backlog e esforço operacional de cada quantum e dependência de plataforma.

Resultados ainda não foram produzidos; esta seção define verificações, não alega implementação.

## Condições de revisão

- A demonstração, orçamento ou capacidade operacional não sustentarem três Deployments e suas dependências.
- O custo do `notificador` separado superar de modo material o isolamento de falha escolhido.
- Produção de Resultados não precisar de isolamento ou escala independente nos testes de carga.
- Um componente adquirir equipe, SLO, requisito regulatório ou perfil de escala realmente independente.
- Custo, latência ou falhas de rede superarem o benefício da separação.
- O Threat Modeling exigir outra fronteira de confiança ou mecanismo de identidade entre workloads.

## Histórico temporal

| Data | Estado | Alteração | Evidência ou responsável |
|---|---|---|---|
| 2026-08-03 | `em_analise` | Registro das opções e da recomendação condicionada de três quanta em Kubernetes | Solicitação de avaliação arquitetural; medições e aceite pendentes |
| 2026-08-03 | `aceita` | Três quanta nomeados `gestao-trabalhos`, `producao-resultados` e `notificador`; Keycloak separado como plataforma | decisão explícita do responsável; consequências ficam para a prova vertical |
