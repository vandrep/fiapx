---
context_id: CTX-REQ-001
context_type: requirement_set
status: em_refinamento
recorded_at: 2026-08-01
valid_from: 2026-08-01
entities:
  - US-01
  - US-02
  - US-03
  - US-04
  - US-05
  - US-06
  - US-07
  - RT-01
  - RT-02
  - RT-03
  - RT-04
  - RT-05
relations:
  - type: derived_from
    target: docs/enunciado.md
  - type: informed_by
    target: CTX-DOM-001
  - type: informed_by
    target: CTX-DOM-002
  - type: informs
    target: CTX-CHAR-001
  - type: informs
    target: CTX-CMP-002
  - type: informs
    target: CTX-CMP-003
  - type: governed_by
    target: CTX-GOV-001
  - type: governed_by
    target: CTX-GOV-003
---

# Histórias de usuário

## Escopo e fontes

Estas histórias traduzem o [enunciado](../enunciado.md) para unidades que possam ser atribuídas a componentes lógicos. O [glossário](glossario.md) define o vocabulário do domínio, o [contexto do projeto](../contexto-projeto.md) registra a classificação das evidências, e o [código-base](../referencia/projeto-original/main.go#L30) demonstra apenas o comportamento atual.

- `Declarada`: a necessidade consta do enunciado.
- `Validada na descoberta`: a regra foi confirmada pelo responsável durante o Event Storming.
- `Inferida`: a formulação ou o critério foi deduzido de uma necessidade declarada e ainda pode ser corrigido.
- `A confirmar`: falta uma decisão que altera o comportamento esperado.

O ator principal é denominado `Usuário`. Cadastro, recuperação de senha e administração de contas não integram as histórias deste primeiro incremento porque o enunciado exige proteção por usuário e senha, mas não descreve autogestão. O provisionamento reproduzível das contas da demonstração foi decidido em [`DEC-0005`](../arquitetura/decisoes/0005-keycloak-no-ambiente-de-validacao.md); a autogestão de credenciais e dados pessoais permanece direção futura, com primeiro recorte `A confirmar`.

## Histórias do primeiro ciclo

<a id="us-01"></a>

### US-01 — Autenticar-se

**Histórico de refinamento:** [`REQ-CHG-0001`](refinamentos/REQ-CHG-0001.md) · [`REQ-CHG-0002`](refinamentos/REQ-CHG-0002.md)

**Classificação:** Declarada.

Como usuário, quero me autenticar com minhas credenciais para acessar as funcionalidades e os recursos que me pertencem.

Critérios candidatos:

- credenciais válidas estabelecem uma identidade utilizável nas operações protegidas;
- credenciais inválidas não concedem acesso;
- uma requisição não autenticada a uma operação protegida é recusada.

**Realização técnica vigente:** [`DEC-0005`](../arquitetura/decisoes/0005-keycloak-no-ambiente-de-validacao.md) escolhe Keycloak/OIDC e ao menos dois usuários reproduzíveis para a demonstração. Essa decisão não acrescenta critério de negócio nem inclui autogestão de contas no incremento.

<a id="us-02"></a>

### US-02 — Enviar um vídeo

**Histórico de refinamento:** [`REQ-CHG-0001`](refinamentos/REQ-CHG-0001.md) · [`REQ-CHG-0002`](refinamentos/REQ-CHG-0002.md)

**Classificação:** Declarada; identificador e confirmação assíncrona são Inferidos; política de admissão `Validada na descoberta`.

Como usuário autenticado, quero enviar um vídeo e receber uma identificação do trabalho para poder acompanhar o processamento sem aguardar sua conclusão na mesma requisição.

Critérios candidatos:

- todas as validações de admissão aplicáveis, inclusive formato e tamanho, precedem a aceitação;
- uma violação definitiva que possa ser verificada com segurança antes ou durante a transferência interrompe o envio antecipadamente;
- a rejeição não cria um trabalho processável e reúne os problemas que puderem ser verificados com segurança na mesma submissão;
- um vídeo aceito gera um identificador único associado ao usuário somente depois que trabalho, proprietário, estado e referência da origem puderem ser recuperados;
- cada nova submissão cria outro trabalho e não está sujeita a uma cota acumulada; frequência, concorrência e capacidade podem ser limitadas operacionalmente;
- formatos aceitos, tamanho, duração e valores dos limites operacionais estão `A confirmar`.

<a id="us-03"></a>

### US-03 — Processar vídeos concorrentemente

**Histórico de refinamento:** [`REQ-CHG-0001`](refinamentos/REQ-CHG-0001.md) · [`REQ-CHG-0003`](refinamentos/REQ-CHG-0003.md)

**Classificação:** Declarada; isolamento por trabalho é Inferido.

Como usuário, quero que meu vídeo seja processado para obter as imagens extraídas, mesmo quando existirem outros trabalhos.

Critérios candidatos:

- trabalhos diferentes usam identificadores, arquivos temporários e resultados isolados;
- a quantidade de execuções simultâneas é controlada, sem concorrência ilimitada;
- a falha de um trabalho não altera o estado nem os artefatos de outro;
- volume e concorrência-alvo estão `A confirmar`.

<a id="us-04"></a>

### US-04 — Preservar trabalhos aceitos durante picos e falhas

**Histórico de refinamento:** [`REQ-CHG-0001`](refinamentos/REQ-CHG-0001.md) · [`REQ-CHG-0002`](refinamentos/REQ-CHG-0002.md) · [`REQ-CHG-0003`](refinamentos/REQ-CHG-0003.md)

**Classificação:** Declarada; semântica de recuperação e duplicidade é Inferida; distinção entre submissão e retentativa `Validada na descoberta`.

Como usuário, quero que um trabalho aceito não seja perdido durante picos ou falhas para que eu não precise reenviar o vídeo sem saber o que aconteceu.

Critérios candidatos:

- um trabalho confirmado permanece consultável após reinício da aplicação;
- uma reentrega duplicada não cria outro trabalho, tentativa ou resultado visível;
- uma falha de processamento resulta em estado recuperável e diagnosticável;
- falhas transitórias de infraestrutura podem iniciar retentativas automáticas do mesmo trabalho, limitadas dentro de cada ciclo;
- falhas permanentes não entram em repetição automática e o esgotamento do ciclo deixa o trabalho em `FALHOU`;
- o proprietário pode solicitar reprocessamento, iniciando outro ciclo no mesmo trabalho e sem reenviar o vídeo;
- quantidade automática por ciclo, espera progressiva, classificação concreta das falhas e garantias exatas de entrega e recuperação estão `A confirmar`.

<a id="us-05"></a>

### US-05 — Consultar os próprios trabalhos

**Histórico de refinamento:** [`REQ-CHG-0001`](refinamentos/REQ-CHG-0001.md) · [`REQ-CHG-0002`](refinamentos/REQ-CHG-0002.md) · [`REQ-CHG-0003`](refinamentos/REQ-CHG-0003.md)

**Classificação:** Declarada; conjunto de estados é Inferido.

Como usuário autenticado, quero listar meus vídeos e seus estados para acompanhar o andamento e saber quando um resultado está disponível.

Critérios candidatos:

- a listagem retorna somente trabalhos pertencentes ao usuário autenticado;
- cada item possui identificador, estado e datas relevantes;
- o conjunto candidato de estados consultáveis é `AGUARDANDO`, `PROCESSANDO`, `CONCLUÍDO` e `FALHOU`;
- um reprocessamento autorizado preserva o histórico e pode levar o mesmo trabalho de `FALHOU` a `AGUARDANDO`;
- histórico e datas relevantes permanecem disponíveis sem expiração automática por enquanto;
- paginação, ordenação e terminologia final dos estados estão `A confirmar`.

<a id="us-06"></a>

### US-06 — Baixar o resultado

**Histórico de refinamento:** [`REQ-CHG-0001`](refinamentos/REQ-CHG-0001.md) · [`REQ-CHG-0002`](refinamentos/REQ-CHG-0002.md) · [`REQ-CHG-0003`](refinamentos/REQ-CHG-0003.md)

**Classificação:** Declarada; autorização por propriedade é Inferida da proteção por usuário.

Como usuário autenticado, quero baixar o ZIP produzido para obter as imagens extraídas do meu vídeo.

Critérios candidatos:

- o download é oferecido somente para um trabalho concluído;
- somente o proprietário autorizado acessa o resultado;
- um resultado ausente não é apresentado como disponível;
- vídeo de origem, resultado e histórico não expiram automaticamente por enquanto; exclusão explícita e futura revisão por custo, privacidade ou obrigação legal permanecem fora deste incremento.

<a id="us-07"></a>

### US-07 — Ser notificado sobre falha

**Histórico de refinamento:** [`REQ-CHG-0001`](refinamentos/REQ-CHG-0001.md) · [`REQ-CHG-0002`](refinamentos/REQ-CHG-0002.md) · [`REQ-CHG-0003`](refinamentos/REQ-CHG-0003.md)

**Classificação:** Declarada como possibilidade; opt-in, canal e garantias são `A confirmar`.

Como usuário, quero ser notificado quando o processamento falhar para tomar conhecimento sem precisar consultar repetidamente o status.

Critérios candidatos:

- uma transição para falha pode solicitar uma notificação associada ao usuário e ao trabalho;
- a notificação de processamento ocorre somente depois que a falha foi registrada e os problemas aplicáveis foram consolidados;
- problemas de admissão pertencem à resposta da submissão e não à notificação assíncrona de processamento;
- a falha do canal de comunicação não desfaz nem oculta o estado do processamento;
- mensagens externas não expõem caminhos internos, comandos, credenciais ou diagnósticos sensíveis;
- notificações de submissão, sucesso ou progresso e a configuração de preferências ou múltiplos canais são candidatas futuras, fora desta história; para a notificação de falha, transporte, canal externo, consentimento, quantidade de tentativas de entrega e confirmação estão `A confirmar`.

## Consolidação conservadora da proposta R6

O refinamento [`REQ-CHG-0003`](refinamentos/REQ-CHG-0003.md) confrontou as dez histórias da [proposta R6](../propostas/base-simplificada-seis-componentes/historias.md) com este conjunto canônico. A decisão confirmada mantém `US-01..07`: sobreposições não criam novas histórias e possibilidades futuras não passam a integrar o incremento atual.

| História R6 | Tratamento confirmado | Destino ou limite no conjunto canônico |
|---|---|---|
| [`R6-US-01`](../propostas/base-simplificada-seis-componentes/historias.md#r6-us-01) — Submeter vídeo | Sobreposição | Já coberta por [`US-02`](#us-02), sem alterar seus critérios de admissão e aceite recuperável |
| [`R6-US-02`](../propostas/base-simplificada-seis-componentes/historias.md#r6-us-02) — Baixar imagens em conjunto | Sobreposição | Já coberta por [`US-06`](#us-06); o ZIP continua sendo o resultado obrigatório |
| [`R6-US-03`](../propostas/base-simplificada-seis-componentes/historias.md#r6-us-03) — Visualizar trabalhos de vídeo | Sobreposição | Já coberta por [`US-05`](#us-05), sem ampliar os campos confirmados da consulta |
| [`R6-US-04`](../propostas/base-simplificada-seis-componentes/historias.md#r6-us-04) — Receber notificações do trabalho | Candidata futura na parte que amplia o escopo | [`US-07`](#us-07) permanece restrita à falha; submissão, sucesso e progresso não são promovidos |
| [`R6-US-05`](../propostas/base-simplificada-seis-componentes/historias.md#r6-us-05) — Processar vídeo | Sobreposição | O valor de extrair imagens foi explicitado em [`US-03`](#us-03), preservando concorrência controlada e isolamento |
| [`R6-US-06`](../propostas/base-simplificada-seis-componentes/historias.md#r6-us-06) — Consultar motivo da falha | `A confirmar` | Pode refinar [`US-05`](#us-05), mas conteúdo, sanitização e nível de detalhe ainda não foram confirmados |
| [`R6-US-07`](../propostas/base-simplificada-seis-componentes/historias.md#r6-us-07) — Reprocessar trabalho com falha | Refinamento já preservado | Corresponde ao reprocessamento do mesmo trabalho já previsto em [`US-04`](#us-04); não cria nova história nem remove tentativas e retentativas automáticas |
| [`R6-US-08`](../propostas/base-simplificada-seis-componentes/historias.md#r6-us-08) — Cancelar trabalho | Candidata futura | Cancelamento permanece fora de [`US-04`](#us-04) e do incremento atual |
| [`R6-US-09`](../propostas/base-simplificada-seis-componentes/historias.md#r6-us-09) — Configurar notificações | Candidata futura | Preferências, eventos adicionais e múltiplos canais permanecem fora de [`US-07`](#us-07) |
| [`R6-US-10`](../propostas/base-simplificada-seis-componentes/historias.md#r6-us-10) — Baixar imagem individual | Candidata futura | Download individual permanece fora de [`US-06`](#us-06); o download vigente continua sendo o ZIP |

`US-01` continua obrigatória, embora a proposta R6 tenha adiado identidade. Permanecem igualmente preservados o processamento concorrente de `US-03` e, em `US-04`, não perda, reentrega idempotente, retentativa automática limitada e reprocessamento manual no mesmo trabalho.

## Contratos conceituais candidatos

Estes contratos descrevem intenção e informação mínima, sem escolher protocolo, endpoint ou formato físico.

| Contrato | Responsabilidade | Resultado esperado | Classificação |
|---|---|---|---|
| `EnvioRejeitado(problemas[])` | Comunicar uma submissão que não satisfez a admissão | Coleção sanitizada dos problemas verificáveis sem criar trabalho processável | `Validada na descoberta`; estrutura física `A confirmar` |
| `SolicitarReprocessamento(trabalhoId)` | Iniciar outro ciclo depois de uma falha, preservando trabalho, origem e histórico | Trabalho autorizado volta a `AGUARDANDO` e uma nova tentativa pode ser criada | Inferida da ausência de cota acumulada e da distinção entre submissão e retentativa |

## Requisitos técnicos relacionados

Estes itens não são histórias de usuário e, portanto, não recebem um componente de negócio artificial. Eles orientam características, implementação e validação.

| ID | Classificação | Requisito | Tratamento no ciclo |
|---|---|---|---|
| RT-01 | Declarado | Persistir dados | Influencia confiabilidade, propriedade dos trabalhos e recuperação |
| RT-02 | Declarado | Permitir escala | Influencia o isolamento e a capacidade do processamento |
| RT-03 | Declarado | Possuir testes | Origina mecanismos de verificação e fitness functions |
| RT-04 | Declarado | Possuir CI/CD | Influencia entrega e governança; não cria componente lógico |
| RT-05 | Preferência | Usar Java com Quarkus | Influencia viabilidade e implementação; não define fronteiras |

## Questões ainda abertas

1. Quais formatos, tamanhos, durações, volumes, concorrência e tempo de espera precisam ser demonstrados?
2. Quantas retentativas automáticas compõem um ciclo, quais falhas são transitórias e como aplicar espera progressiva e controle concorrente?
3. Que mecanismo comprova atomicidade entre aceitação, preservação e entrega ao processamento?
4. Qual será o primeiro recorte futuro de autogestão de credenciais e dados pessoais?
5. A notificação exige consentimento, canal externo ou garantia de entrega? Atualização em tempo real será necessária e, se for, com qual transporte?
6. A consulta deve oferecer detalhe além da listagem?
7. O usuário poderá consultar um motivo de falha sanitizado e, se puder, com qual nível de detalhe?

Essas lacunas mantêm detalhes como `A confirmar`, mas não invalidam as regras de admissão, retentativa, retenção e comunicação já validadas.
