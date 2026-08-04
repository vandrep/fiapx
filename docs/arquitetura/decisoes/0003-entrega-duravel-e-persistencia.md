---
context_id: DEC-0003
context_type: decision
status: em_analise
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
    target: DEC-0002
  - type: informed_by
    target: CTX-ARCH-001
  - type: affects
    target: CTX-ARCH-001
  - type: governed_by
    target: CTX-GOV-001
---

# DEC-0003 — Aceitação, entrega durável e persistência

## Pergunta

Quando uma submissão pode ser confirmada como aceita, e quais mecanismos preservam trabalho, tentativa, mensagens e artefatos diante de falhas, reinícios e reentregas sem prometer processamento exatamente uma vez?

## Contexto e invariantes

A [`US-02`](../../requisitos/historias.md#us-02) só permite devolver um identificador depois que trabalho, proprietário, estado e referência da origem puderem ser recuperados. A [`US-04`](../../requisitos/historias.md#us-04) exige que um trabalho aceito não desapareça, que reentregas sejam idempotentes e que falhas transitórias possam iniciar retentativas automáticas finitas. O proprietário ainda pode solicitar reprocessamento manual no mesmo trabalho depois de falha; isso inicia outro ciclo e não é nova submissão.

A [confiabilidade de `CTX-CHAR-001`](../caracteristicas.md#ca-01--confiabilidade-e-recuperabilidade) torna o intervalo entre persistir o trabalho e entregar a tentativa o principal risco. O modelo ativo [`CTX-CMP-003`](../componentes-coesos.md#depend%C3%AAncias-e-contratos-conceituais) consolida a autoridade: [`CMP-20 — Ciclo do Trabalho`](../componentes-coesos.md#cmp-20) é o único escritor do estado. [`CMP-21`](../componentes-coesos.md#cmp-21) e [`CMP-22`](../componentes-coesos.md#cmp-22) relatam fatos/categorias técnicas; não decidem se uma falha é transitória, não autorizam retry e não aplicam transições.

Processamento de Mídia, Publicação de Resultados, Consulta e Comunicação de Falhas não atualizam livremente esse estado nem leem as tabelas internas do Ciclo. Eles recebem comandos ou fatos autossuficientes e devolvem resultados correlacionados. Essa regra evita transições concorrentes e preserva uma única máquina de estados.

## Opções e trade-offs

| Opção | Benefícios | Custos e riscos | Avaliação preliminar |
|---|---|---|---|
| **Processamento síncrono e filesystem local** | Poucas dependências e fluxo simples dentro da requisição | Resposta fica acoplada ao `ffmpeg`; reinício ou troca de pod perde origem/resultado; não absorve pico nem comprova recuperação | Incompatível com aceitação assíncrona, Kubernetes e não perda após aceite |
| **Polling de trabalhos no PostgreSQL** | Aceitação, tentativa e disponibilidade para consumo podem compartilhar uma transação; dispensa broker inicial | Polling e locks aumentam carga; Produção de Resultados passa a conhecer o contrato físico do banco de Gestão; priorização, backpressure e isolamento de credenciais ficam mais difíceis | Alternativa viável para baixo volume, mas enfraquece a separação entre quanta |
| **Broker sem outbox transacional** | Desacopla Gestão e Produção e permite backlog/escala | Dual write entre banco e broker cria janelas: trabalho persistido sem mensagem ou mensagem sem trabalho confirmado; retry da publicação pode duplicar efeitos | Não atende a garantia de aceitação sem reconciliação adicional equivalente a uma outbox |
| **RabbitMQ com outbox/inbox** | Trabalho, tentativa e intenção de despacho são atômicos no banco; entrega `at-least-once` tolera falhas com idempotência; quanta mantêm contratos explícitos | Acrescenta broker, relay, tabelas de deduplicação, consistência eventual, DLQ e operação de reconciliação | Recomendação condicionada por representar diretamente as falhas relevantes |

## Recomendação condicionada

Recomenda-se, sem aceitar ainda a decisão:

- PostgreSQL como registro durável de trabalhos, ciclos/tentativas, estado, histórico, outbox e inbox pertinentes a cada quantum;
- object storage S3-compatible para vídeo de origem, imagens extraídas, manifesto e ZIP;
- RabbitMQ com filas e mensagens duráveis, acknowledgements explícitos, publisher confirms, entrega `at-least-once` e DLQ;
- outbox/inbox, chaves idempotentes e reconciliação em vez de uma promessa de `exactly-once`;
- schemas e credenciais separados por quantum, sem leitura cruzada;
- `CMP-20 — Ciclo do Trabalho` como único escritor do estado do trabalho.

Redis não integra a recomendação atual. Cache ou coordenação adicional só devem ser introduzidos após uma medição demonstrar gargalo e um cenário de invalidação/recuperação seguro; sua presença na stack sugerida não constitui evidência suficiente.

## Semântica de aceitação

Uma submissão é aceita somente depois desta sequência:

1. Submissão e Admissão recebem a identidade já autenticada, aplicam validações possíveis e geram identificadores estáveis.
2. O vídeo de origem é gravado em object storage sob chave não reutilizável; a gravação e sua recuperabilidade são confirmadas. Arquivo apenas no pod ou upload multipart incompleto não conta como origem recuperável.
3. Em uma única transação PostgreSQL de `gestao-trabalhos`, Ciclo do Trabalho cria o trabalho com proprietário `(issuer, subject)` e estado inicial, cria a tentativa inicial do ciclo e grava a entrada de outbox `ProcessRequested` correlacionada.
4. Somente depois do commit a API devolve o identificador e confirma a aceitação, preferencialmente com resposta assíncrona `202`.

Se o object storage tiver sucesso e a transação falhar, a submissão não foi aceita; uma reconciliação pode remover o objeto órfão depois de uma janela segura. Se a transação fizer commit e a publicação no RabbitMQ falhar, o trabalho continua aceito e recuperável: o relay volta a publicar a outbox até obter confirmação.

Aceitação significa que o sistema assumiu responsabilidade durável pelo trabalho. Não significa que o broker já entregou a mensagem, que há consumidor de Produção disponível ou que o processamento terminará com sucesso.

## Fluxo de entrega e desfecho

1. Um relay lê entradas confirmadas da outbox, publica mensagem persistente com `messageId`, `workId`, `cycleId`, `attemptId` e versão do contrato e só registra a publicação depois do publisher confirm.
2. Falha entre publicar e marcar a outbox pode repetir a mensagem; isso é esperado sob `at-least-once`.
3. `producao-resultados` registra `messageId`/`attemptId` em sua inbox e rejeita efeitos duplicados. O acknowledgement ocorre somente depois de persistir o efeito local necessário.
4. `producao-resultados` usa scratch efêmero e isolado, mas lê a origem e publica imagens sob chaves imutáveis no object storage.
5. Publicação de Resultados grava manifesto com referências/checksums e o ZIP recuperável antes de emitir `ResultadoPublicado`. Quando Processamento ou Publicação falham, emitem apenas `FalhaTecnicaDaTentativa` ou `FalhaTecnicaDaPublicacao`, sempre correlacionada, sem classificar a falha nem criar outra tentativa.
6. Ciclo do Trabalho recebe `ResultadoPublicado` ou a falha técnica por sua inbox e valida correlação. Como único escritor, conclui o trabalho ou classifica a falha segundo sua política, autoriza uma retentativa automática ou registra `FALHOU`; somente depois do estado terminal publica `TrabalhoFalhou` mínimo e sanitizado para Comunicação de Falhas.
7. Transições que precisam alimentar outro quantum gravam sua própria outbox na mesma transação do novo estado.

O trabalho nunca fica `CONCLUÍDO` antes de manifesto e ZIP estarem recuperáveis. Reconciliações procuram, ao menos, outboxes sem progresso, mensagens na DLQ, tentativas ativas sem lease/heartbeat válido, artefatos órfãos e divergência entre `CONCLUÍDO` e resultado disponível. Reconciliação detecta e agenda correção pela autoridade apropriada; não concede a outro quantum escrita direta no estado.

## Propriedade física dos dados

Uma instância PostgreSQL inicial pode reduzir custo, mas isolamento lógico continua obrigatório:

| Quantum | Dados próprios candidatos | Regra de acesso |
|---|---|---|
| Gestão de Trabalhos de Vídeo (`gestao-trabalhos`) | trabalho, proprietário, ciclos, tentativas, estado, histórico, inbox e outbox do ciclo; projeções de consulta/acesso | Somente a credencial desse quantum escreve; projeções são expostas por contrato, não por `SELECT` externo |
| Produção de Resultados (`producao-resultados`) | inbox/deduplicação, lease da execução, manifesto e outbox de fatos técnicos/publicação | Não lê nem escreve o schema de `gestao-trabalhos` |
| Comunicação de Falhas (`notificador`) | inbox e tentativas de entrega da notificação de falha | Não lê estado, Keycloak ou credenciais do usuário; recebe fato mínimo e sanitizado |

Cada quantum possui schema, usuário e migrations próprios. Compartilhar a mesma instância não autoriza joins, foreign keys ou leitura cruzada. Uma futura separação em instâncias físicas deve preservar os mesmos contratos.

No object storage, buckets ou prefixes e políticas distinguem origem, imagens, manifestos e ZIP. `producao-resultados` recebe referências opacas e permissões mínimas; `gestao-trabalhos` não publica bucket inteiro. Criptografia, retenção, exclusão, versionamento e backup dependem de Threat Modeling, custo e obrigações ainda não definidos.

## Retentativas, reprocessamento e DLQ

- **Reentrega técnica:** repete a mesma mensagem e o mesmo `attemptId`; inbox/idempotência impedem outra tentativa ou resultado visível.
- **Retentativa automática:** somente Ciclo do Trabalho cria nova tentativa no mesmo ciclo após falha classificada como transitória; quantidade é finita, com espera progressiva e valores ainda a confirmar.
- **Falha permanente ou esgotamento:** encerra o ciclo em `FALHOU`; não entra em repetição infinita.
- **Reprocessamento manual:** pedido autorizado do proprietário cria outro ciclo e tentativa no mesmo trabalho, preservando origem e histórico, sem novo upload.
- **DLQ:** isola mensagens que excederam a política técnica de entrega ou não podem ser processadas; mover para DLQ não altera sozinho o estado do trabalho. Diagnóstico, correção e replay precisam de runbook e idempotência.

Retry do cliente, redelivery do RabbitMQ, retentativa automática de negócio e reprocessamento manual são mecanismos diferentes e não compartilham contadores implicitamente.

## Consequências

- O aceite passa a possuir fronteira verificável: origem recuperável mais transação de trabalho, tentativa e outbox.
- Falha do broker após o commit deixa atraso observável, não trabalho perdido.
- Entrega duplicada é comportamento normal e exige consumidores idempotentes, chaves estáveis e efeitos imutáveis.
- O banco continua a fonte de verdade do estado; RabbitMQ transporta comandos e fatos e o object storage preserva conteúdo, sem substituir a autoridade do domínio.
- Separação de schemas reduz acoplamento e blast radius de credenciais, mas impede atalhos por joins e exige contratos/projeções explícitos.
- Outbox, inbox, relay, DLQ e reconciliação aumentam custo de implementação e operação.
- Object storage evita depender do pod, mas introduz custo, consistência operacional, objetos órfãos e políticas de ciclo de vida a administrar.

## Verificações antes do aceite

- falhar a transação depois de gravar a origem e comprovar que nenhum trabalho foi aceito e que o órfão é reconciliável;
- matar a API depois do commit e antes da publicação e comprovar publicação posterior pela outbox;
- publicar duas vezes `ProcessRequested` e observar uma única execução efetiva/um único resultado visível;
- matar pods de `producao-resultados` antes e depois do upload do resultado e comprovar redelivery ou reconciliação sem conclusão prematura;
- impedir temporariamente o object storage e comprovar que o estado nunca se torna `CONCLUÍDO` sem manifesto e ZIP recuperáveis;
- reiniciar banco, broker e pods depois do aceite e preservar trabalho consultável e mensagens duráveis;
- esgotar retry automático finito, observar `FALHOU` e então executar reprocessamento manual em novo ciclo no mesmo trabalho;
- colocar mensagem inválida na DLQ e exercitar diagnóstico/replay sem transição duplicada;
- verificar por testes de credenciais e dependência que `producao-resultados` e `notificador` não leem o schema de `gestao-trabalhos` nem consultam o Keycloak;
- fazer Processamento/Publicação emitir uma falha técnica e comprovar que somente `CMP-20` decide retry e transição;
- reconciliar a igualdade entre aceitos e a soma dos estados vigentes, explicando explicitamente itens em transição.

Resultados ainda não foram produzidos; a recomendação permanece `em_analise` até essas verificações e os alvos operacionais serem acordados.

## Condições de revisão

- Testes demonstrarem que polling transacional no PostgreSQL atende volume, isolamento e operação com menor risco total.
- Throughput, ordenação, retenção ou replay exigirem outro broker ou particionamento.
- O volume tornar outbox polling, índices, banco ou object storage um gargalo medido.
- Uma obrigação de residência, criptografia, retenção ou auditoria mudar a propriedade física dos dados.
- A restauração não conseguir preservar a relação entre banco, mensagens e artefatos.
- Um novo estado ou comando introduzir outro escritor direto do estado do trabalho.
- Retentativas automáticas ou reprocessamento manual deixarem de preservar as identidades e limites definidos nos requisitos.
- Processamento, Publicação ou Comunicação de Falhas passarem a decidir política de retry do trabalho.

## Histórico temporal

| Data | Estado | Alteração | Evidência ou responsável |
|---|---|---|---|
| 2026-08-03 | `em_analise` | Registro da semântica de aceite e recomendação de PostgreSQL, object storage e RabbitMQ com outbox/inbox | Requisitos de persistência e não perda; experimentos e aceite pendentes |
