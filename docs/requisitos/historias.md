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
  - type: informs
    target: CTX-CHAR-001
  - type: informs
    target: CTX-CMP-001
  - type: governed_by
    target: CTX-GOV-001
---

# Histórias de usuário

## Escopo e fontes

Estas histórias traduzem o [enunciado](../enunciado.md) para unidades que possam ser atribuídas a componentes lógicos. O [glossário](glossario.md) define o vocabulário do domínio, o [contexto do projeto](../contexto-projeto.md) registra a classificação das evidências, e o [código-base](../referencia/projeto-original/main.go#L30) demonstra apenas o comportamento atual.

- `Declarada`: a necessidade consta do enunciado.
- `Inferida`: a formulação ou o critério foi deduzido de uma necessidade declarada e ainda pode ser corrigido.
- `A confirmar`: falta uma decisão que altera o comportamento esperado.

O ator principal é denominado `Usuário`. Cadastro, recuperação de senha e administração de contas não foram incluídos porque o enunciado exige proteção por usuário e senha, mas não descreve como as contas são provisionadas.

## Histórias do primeiro ciclo

### US-01 — Autenticar-se

**Classificação:** Declarada.

Como usuário, quero me autenticar com minhas credenciais para acessar as funcionalidades e os recursos que me pertencem.

Critérios candidatos:

- credenciais válidas estabelecem uma identidade utilizável nas operações protegidas;
- credenciais inválidas não concedem acesso;
- uma requisição não autenticada a uma operação protegida é recusada;
- o mecanismo de sessão ou token e o provisionamento das contas estão `A confirmar`.

### US-02 — Enviar um vídeo

**Classificação:** Declarada; identificador e confirmação assíncrona são Inferidos.

Como usuário autenticado, quero enviar um vídeo e receber uma identificação do trabalho para poder acompanhar o processamento sem aguardar sua conclusão na mesma requisição.

Critérios candidatos:

- um vídeo aceito gera um identificador único associado ao usuário;
- o sistema confirma a aceitação somente depois que o trabalho puder ser recuperado;
- um arquivo recusado não cria um trabalho processável e retorna um motivo seguro;
- formatos, tamanho, duração e demais limites estão `A confirmar`.

### US-03 — Processar vídeos concorrentemente

**Classificação:** Declarada; isolamento por trabalho é Inferido.

Como usuário, quero que meu vídeo seja processado mesmo quando existirem outros trabalhos para que a solução suporte mais de um processamento ao mesmo tempo.

Critérios candidatos:

- trabalhos diferentes usam identificadores, arquivos temporários e resultados isolados;
- a quantidade de execuções simultâneas é controlada, sem concorrência ilimitada;
- a falha de um trabalho não altera o estado nem os artefatos de outro;
- volume e concorrência-alvo estão `A confirmar`.

### US-04 — Preservar trabalhos aceitos durante picos e falhas

**Classificação:** Declarada; semântica de recuperação e duplicidade é Inferida.

Como usuário, quero que um trabalho aceito não seja perdido durante picos ou falhas para que eu não precise reenviar o vídeo sem saber o que aconteceu.

Critérios candidatos:

- um trabalho confirmado permanece consultável após reinício da aplicação;
- uma entrega repetida não produz dois resultados visíveis para o mesmo trabalho;
- uma falha de processamento resulta em estado recuperável e diagnosticável;
- garantias exatas de entrega, retentativa e recuperação estão `A confirmar`.

### US-05 — Consultar os próprios trabalhos

**Classificação:** Declarada; conjunto de estados é Inferido.

Como usuário autenticado, quero listar meus vídeos e seus estados para acompanhar o andamento e saber quando um resultado está disponível.

Critérios candidatos:

- a listagem retorna somente trabalhos pertencentes ao usuário autenticado;
- cada item possui identificador, estado e datas relevantes;
- o conjunto candidato de estados é `RECEBIDO`, `AGUARDANDO`, `PROCESSANDO`, `CONCLUÍDO` e `FALHOU`;
- paginação, ordenação, retenção e terminologia dos estados estão `A confirmar`.

### US-06 — Baixar o resultado

**Classificação:** Declarada; autorização por propriedade é Inferida da proteção por usuário.

Como usuário autenticado, quero baixar o ZIP produzido para obter as imagens extraídas do meu vídeo.

Critérios candidatos:

- o download é oferecido somente para um trabalho concluído;
- somente o proprietário autorizado acessa o resultado;
- um resultado ausente ou expirado não é apresentado como disponível;
- prazo de retenção e comportamento de expiração estão `A confirmar`.

### US-07 — Ser notificado sobre falha

**Classificação:** Declarada como possibilidade; opt-in, canal e garantias são `A confirmar`.

Como usuário, quero ser notificado quando o processamento falhar para tomar conhecimento sem precisar consultar repetidamente o status.

Critérios candidatos:

- uma transição para falha pode solicitar uma notificação associada ao usuário e ao trabalho;
- a falha do canal de comunicação não desfaz nem oculta o estado do processamento;
- mensagens externas não expõem caminhos internos, comandos, credenciais ou diagnósticos sensíveis;
- canal, consentimento, quantidade de tentativas e confirmação de entrega estão `A confirmar`.

## Requisitos técnicos relacionados

Estes itens não são histórias de usuário e, portanto, não recebem um componente de negócio artificial. Eles orientam características, implementação e validação.

| ID | Classificação | Requisito | Tratamento no ciclo |
|---|---|---|---|
| RT-01 | Declarado | Persistir dados | Influencia confiabilidade, propriedade dos trabalhos e recuperação |
| RT-02 | Declarado | Permitir escala | Influencia o isolamento e a capacidade do processamento |
| RT-03 | Declarado | Possuir testes | Origina mecanismos de verificação e fitness functions |
| RT-04 | Declarado | Possuir CI/CD | Influencia entrega e governança; não cria componente lógico |
| RT-05 | Preferência | Usar Java com Quarkus | Influencia viabilidade e implementação; não define fronteiras |

## Questões que mais alteram o desenho

1. Em que momento uma requisição é considerada aceita e quais falhas devem ser toleradas depois disso?
2. Quais volumes, tamanhos de vídeo, concorrência e tempo de espera precisam ser demonstrados?
3. Como as contas serão criadas e qual mecanismo de autenticação é suficiente para o trabalho acadêmico?
4. Por quanto tempo vídeos enviados, resultados e histórico devem ser preservados?
5. A notificação é obrigatória, opcional por usuário ou apenas uma capacidade demonstrável?

Até que essas respostas existam, os critérios candidatos servem para o primeiro refinamento e não constituem compromisso definitivo.
