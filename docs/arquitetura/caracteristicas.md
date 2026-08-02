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
    target: CTX-CMP-001
  - type: governed_by
    target: CTX-GOV-001
---

# Características arquiteturais

## Decisão em análise

Quais características devem orientar as primeiras fronteiras e os primeiros experimentos do FIAP X?

As evidências vêm das [histórias de usuário](../requisitos/historias.md), do [enunciado](../enunciado.md) e dos riscos observados no [fluxo de upload do código-base](../referencia/projeto-original/main.go#L75). Como ainda não há volume, SLO ou ambiente de execução definidos, as medidas abaixo são verificáveis, mas seus valores-alvo continuam `A confirmar`.

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

## Agrupamento preliminar por escopo

Este agrupamento aplica o checkpoint de escopo antes de decidir componentes físicos ou topologia. Ele é uma hipótese reversível: uma característica que atravessa capacidades não cria automaticamente um quantum, e uma diferença de escopo só justifica distribuição quando exigir evolução, implantação ou operação independente.

| Grupo candidato | Características e alcance | Capacidades lógicas afetadas | Implicação ainda em análise |
|---|---|---|---|
| Interação segura e autoridade do trabalho | `CA-01` da aceitação ao estado consultável; `CA-02` da identidade ao acesso ao resultado | Identidade e Acesso; Trabalhos de Vídeo | Pode permanecer em um único limite de implantação; separar essas capacidades não possui motivador operacional confirmado |
| Execução confiável e elástica | `CA-01` na entrega e no relato do resultado; `CA-03` no backlog e nas tentativas | Trabalhos de Vídeo; Processamento de Mídia | É o único grupo que sugere um limite destacável, condicionado a carga medida e contrato durável que evite acoplamento síncrono |
| Comunicação externa de falha | Segurança de conteúdo e confiabilidade da tentativa, hoje como suporte às características primárias | Trabalhos de Vídeo; Notificações | Não há característica prioritária nem regra confirmada que exija quantum próprio; pode continuar componente local ou adaptador |

Há, portanto, mais de uma combinação candidata de características, mas ainda não existe evidência suficiente para concluir que elas precisam de unidades de implantação distintas. A comparação inicial deve permanecer entre um quantum em monólito modular e dois quanta com processamento destacável.

## Trade-offs que orientam os componentes

- Confirmar rapidamente o upload reduz acoplamento temporal com o processamento, mas exige um ponto durável de aceitação e tratamento de falhas parciais.
- Isolar processamento permite capacidade independente, mas adiciona contratos assíncronos, idempotência e observação do fluxo.
- Centralizar a autoridade sobre o estado simplifica consistência; permitir que API, processador e notificador alterem livremente o mesmo registro cria acoplamento e transições inválidas.
- Restringir uploads protege recursos, mas os limites precisam ser compatíveis com os vídeos esperados para a demonstração.
- Java com Quarkus pode melhorar a viabilidade pela familiaridade declarada. Essa escolha não resolve por si só confiabilidade, segurança ou escala e não determina a topologia de implantação.

## Ciclo de melhoria

Estas características devem ser revistas quando os valores-alvo forem esclarecidos, o primeiro incremento for medido ou uma decisão de implantação alterar seu escopo. Uma característica só permanece prioritária se continuar diferenciando opções e produzindo uma verificação objetiva.
