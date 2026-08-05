---
context_id: CTX-CHAR-001
context_type: architecture_characteristic_set
status: em_analise
recorded_at: 2026-08-01
valid_from: 2026-08-01
entities:
  - CA-01
  - CA-02
  - CA-03
relations:
  - type: derived_from
    target: CTX-REQ-001
  - type: informed_by
    target: CTX-PRJ-001
  - type: informs
    target: CTX-CMP-002
  - type: informs
    target: CTX-CMP-003
  - type: governed_by
    target: CTX-GOV-001
---

# Características arquiteturais

## Decisão em análise

Quais características devem orientar as primeiras fronteiras e os primeiros experimentos do FIAP X?

As evidências vêm das [histórias de usuário](../requisitos/historias.md), do [enunciado](../enunciado.md) e dos riscos observados no [fluxo de upload do código-base](../referencia/projeto-original/main.go#L75). Kubernetes e Keycloak já foram aceitos para o ambiente de validação em [`DEC-0002`](decisoes/0002-topologia-kubernetes.md) e [`DEC-0005`](decisoes/0005-keycloak-no-ambiente-de-validacao.md); volume, SLO, capacidade, ambiente de produção e valores-alvo continuam `A confirmar`.

## Planilha de seleção

| Seleção | Característica | Classificação | Escopo e justificativa |
|---|---|---|---|
| [x] | Confiabilidade e recuperabilidade | Primária | Da confirmação do upload até um estado terminal. O enunciado exige que picos não causem perda; hoje todo o fluxo ocorre na requisição e em disco local |
| [x] | Segurança | Primária | Autenticação, autorização por propriedade, upload não confiável e download. O projeto-base expõe diretórios e não possui identidade |
| [x] | Escalabilidade do processamento | Primária | Fila de trabalhos e execução de `ffmpeg`. O sistema deve processar mais de um vídeo e permitir escala sem concorrência descontrolada |
| [ ] | Desempenho | Candidata | Tempo de aceitação, espera e processamento será relevante, mas nenhum limite foi declarado; permanece subordinado à confiabilidade neste ciclo |
| [ ] | Disponibilidade | Candidata | Reinícios e falhas importam para trabalhos aceitos, porém não existe meta de uptime; a recuperação é mais orientadora agora |
| [ ] | Interoperabilidade | Candidata | Existem integrações com processador de mídia, armazenamento e canal de notificação, mas nenhuma interface externa obrigatória foi escolhida |
| [ ] | Observabilidade | Suporte | Necessária para estados, falhas e operação; deve instrumentar os três fluxos primários sem se tornar um componente de negócio |
| [ ] | Manutenibilidade e testabilidade | Suporte | Necessárias para o requisito de qualidade e para evoluir o protótipo; contratos pequenos e testes automatizados serão os mecanismos iniciais |
| [ ] | Viabilidade | Restrição | Prazo acadêmico, familiaridade e custo operacional limitam a solução. A preferência por Java com Quarkus reduz risco de aprendizado, mas ainda requer decisão registrada |

Exatamente três características foram selecionadas porque são as que mais alteram a propriedade dos dados, o limite entre aceitação e processamento e os contratos entre os componentes.

## Cenários e verificação

### CA-01 — Confiabilidade e recuperabilidade

**Escopo:** trabalho de vídeo aceito, seus estados e a entrega ao processamento.

**Resposta esperada:** depois de confirmar a aceitação, o sistema preserva identidade, proprietário e estado do trabalho; reinício ou entrega repetida não o apagam nem criam dois resultados visíveis.

**Verificações iniciais:**

- teste de integração que reinicia a aplicação depois da aceitação e comprova que o trabalho continua consultável;
- teste de idempotência com entrega repetida da mesma solicitação de processamento;
- teste de falha no processador que comprova a transição para um estado terminal ou recuperável;
- reconciliação entre trabalho concluído e resultado disponível.

**Medidas a confirmar:** ponto exato de aceitação, quantidade de tentativas, tempo de recuperação e semântica de entrega.

### CA-02 — Segurança

**Escopo:** operações autenticadas, propriedade do trabalho, entrada de arquivo e exposição do resultado.

**Resposta esperada:** somente o proprietário autenticado lista ou baixa seus recursos; entradas inválidas são limitadas e recusadas; detalhes internos não vazam nas respostas.

**Verificações iniciais:**

- testes `401/403` para acesso ausente e acesso cruzado entre dois usuários;
- testes de extensão, conteúdo, tamanho, nome malicioso e travessia de diretório no upload e download;
- verificação de que arquivos não são publicados por diretórios estáticos;
- inspeção de logs e mensagens para impedir exposição de credenciais, caminhos e saída bruta de comandos.

**Medidas a confirmar:** limites de arquivo, política de credenciais, expiração de acesso e retenção dos artefatos.

### CA-03 — Escalabilidade do processamento

**Escopo:** trabalhos aguardando e execuções do processador de mídia; a API de consulta não precisa escalar da mesma forma neste ciclo.

**Resposta esperada:** um pico é absorvido como backlog controlado, e a capacidade de processamento pode crescer sem compartilhar diretórios temporários nem produzir resultados conflitantes.

**Verificações iniciais:**

- teste concorrente com trabalhos identificados e artefatos isolados;
- teste de pico que compara quantidade aceita, processada, falha e pendente, sem desaparecimento de trabalhos;
- medição de profundidade e idade do backlog, duração do processamento e utilização de recursos;
- alteração controlada da quantidade de processadores sem alterar a API nem a autoridade sobre o estado.

**Medidas a confirmar:** pico esperado, concorrência, throughput, tempo máximo de espera e recursos disponíveis.

<a id="agrupamento-preliminar-por-escopo"></a>

## Registro histórico do agrupamento preliminar por escopo

Esta seção preserva a análise feita sobre o modelo [`CTX-CMP-002`](historico/componentes/ctx-cmp-002-componentes-modulares.md), vigente em 2026-08-02 e posteriormente substituído. As características abaixo são propriedades do sistema. Elas foram analisadas depois da atribuição das histórias e antes da refatoração, sem criar, unir ou dividir componentes durante essa etapa. Somente a etapa seguinte usou as tensões encontradas para refatorar o inventário lógico.

Naquele estágio, quatro regiões apareceram como hipóteses de agrupamento. Elas ajudaram a estudar quanta, mas não estabeleceram unidades de implantação nem transferiram a responsabilidade por uma característica sistêmica para um componente isolado.

| Região candidata | Características e alcance no sistema | Componentes afetados no modelo então corrente (`CTX-CMP-002`) | Evidência então necessária antes de decidir topologia |
|---|---|---|---|
| Interação e acesso | `CA-02` na identidade, submissão, admissão, consulta e acesso ao resultado; `CA-01` na entrada aceita e recuperável | [`CMP-05`](historico/componentes/ctx-cmp-002-componentes-modulares.md#cmp-05), [`CMP-06`](historico/componentes/ctx-cmp-002-componentes-modulares.md#cmp-06), [`CMP-07`](historico/componentes/ctx-cmp-002-componentes-modulares.md#cmp-07), [`CMP-09`](historico/componentes/ctx-cmp-002-componentes-modulares.md#cmp-09), [`CMP-16`](historico/componentes/ctx-cmp-002-componentes-modulares.md#cmp-16) | Perfil de acesso, requisitos de isolamento e necessidade de evolução ou operação independente |
| Controle do ciclo | `CA-01` na aceitação, despacho, política de tentativas e consolidação do desfecho | [`CMP-08`](historico/componentes/ctx-cmp-002-componentes-modulares.md#cmp-08), [`CMP-10`](historico/componentes/ctx-cmp-002-componentes-modulares.md#cmp-10), [`CMP-11`](historico/componentes/ctx-cmp-002-componentes-modulares.md#cmp-11), [`CMP-15`](historico/componentes/ctx-cmp-002-componentes-modulares.md#cmp-15) | Semântica de transação, falha e recuperação entre os componentes |
| Execução de mídia | `CA-03` no backlog e na concorrência; `CA-01` na execução, extração e empacotamento | [`CMP-12`](historico/componentes/ctx-cmp-002-componentes-modulares.md#cmp-12), [`CMP-13`](historico/componentes/ctx-cmp-002-componentes-modulares.md#cmp-13), [`CMP-14`](historico/componentes/ctx-cmp-002-componentes-modulares.md#cmp-14) | Carga medida, custo de isolamento e contrato durável com o controle do ciclo |
| Comunicação | Segurança do conteúdo e confiabilidade da entrega, hoje como suporte às características primárias | [`CMP-17`](historico/componentes/ctx-cmp-002-componentes-modulares.md#cmp-17) | Canais, volume, política de reentrega e necessidade real de implantação independente |

Desde 2026-08-03, o [modelo ativo `CTX-CMP-003`](componentes-coesos.md) consolida oito componentes, e [`DEC-0002`](decisoes/0002-topologia-kubernetes.md) aceita três quanta para validação. A tabela acima continua como evidência da etapa anterior; a composição vigente pertence ao modelo ativo e ao ADR. Medidas de capacidade e a arquitetura de produção ainda dependem de experimentos.

## Trade-offs que orientam os componentes

- Confirmar rapidamente o upload reduz acoplamento temporal com o processamento, mas exige um ponto durável de aceitação e tratamento de falhas parciais.
- Isolar processamento permite capacidade independente, mas adiciona contratos assíncronos, idempotência e observação do fluxo.
- Centralizar a autoridade sobre o estado simplifica consistência; permitir que API, processador e notificador alterem livremente o mesmo registro cria acoplamento e transições inválidas.
- Restringir uploads protege recursos, mas os limites precisam ser compatíveis com os vídeos esperados para a demonstração.
- Java com Quarkus pode melhorar a viabilidade pela familiaridade declarada. Essa escolha não resolve por si só confiabilidade, segurança ou escala e não determina a topologia de implantação.

## Ciclo de melhoria

Estas características devem ser revistas quando os valores-alvo forem esclarecidos, o primeiro incremento for medido ou uma decisão de implantação alterar seu escopo. Uma característica só permanece prioritária se continuar diferenciando opções e produzindo uma verificação objetiva.
