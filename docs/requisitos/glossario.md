---
context_id: CTX-DOM-001
context_type: domain_vocabulary
status: em_evolucao
recorded_at: 2026-08-01
valid_from: 2026-08-01
relations:
  - type: derived_from
    target: docs/enunciado.md
  - type: informed_by
    target: CTX-REQ-001
  - type: informed_by
    target: CTX-DOM-002
  - type: informs
    target: CTX-CMP-002
  - type: informs
    target: CTX-CMP-003
  - type: governed_by
    target: CTX-GOV-001
---

# Glossário do domínio

## Objetivo

Este glossário estabelece termos de negócio consistentes para as [histórias de usuário](historias.md), os componentes e os futuros contratos do FIAP X. Ele traduz o [enunciado](../enunciado.md) sem transformar inferências ainda em análise em requisitos confirmados.

Classificações usadas:

- `Declarado`: o conceito aparece diretamente no enunciado;
- `Validado na descoberta`: o significado foi confirmado pelo responsável durante o Event Storming;
- `Inferido`: o conceito foi introduzido para tornar uma necessidade declarada mais precisa;
- `A confirmar`: o significado ainda depende de uma decisão do responsável pelo projeto.

## Termos fundamentais

| Termo preferido | Definição no domínio | Limites e relações | Classificação |
|---|---|---|---|
| Usuário | Pessoa que acessa o sistema para enviar vídeos, acompanhar trabalhos e obter resultados | Não implica papel administrativo nem mecanismo de cadastro | Declarado |
| Credencial | Informação apresentada para comprovar a identidade de um usuário | O enunciado menciona usuário e senha; formato, armazenamento e recuperação ainda não foram definidos | Declarado; detalhes `A confirmar` |
| Identidade autenticada | Representação confiável do usuário depois da autenticação | É usada para associar e autorizar recursos; não é o mesmo que senha, sessão ou token | Inferido |
| Proprietário do trabalho | Usuário ao qual um trabalho de vídeo pertence | Somente o proprietário autorizado pode consultar o trabalho ou obter seu resultado, salvo regra futura explícita | Inferido |
| Vídeo de origem | Conteúdo audiovisual fornecido pelo usuário para extração de imagens | É uma entrada do trabalho, não o próprio trabalho; formatos e limites estão `A confirmar` | Declarado; qualificador Inferido |
| Envio de vídeo | Ação de transferir um vídeo de origem e solicitar sua aceitação | `Upload` pode aparecer em interfaces técnicas, mas a linguagem de negócio preferida é `envio de vídeo` | Declarado |
| Nova submissão de vídeo | Intenção do usuário de criar outro trabalho por meio de um envio | Gera novo identificador somente depois da aceitação; não é retentativa do processamento de um trabalho existente | `Validado na descoberta` |
| Validação de admissão | Verificação aplicada à submissão antes que o sistema aceite um trabalho | Inclui formato e tamanho; pode começar antes do término da transferência, mas somente evidência confiável permite interrupção antecipada | `Validado na descoberta`; conjunto e valores `A confirmar` |
| Problema de admissão | Violação sanitizada detectada por uma validação de admissão | Uma rejeição reúne os problemas verificáveis com segurança na mesma submissão; não é falha de processamento | Inferido da regra validada |
| Trabalho de vídeo | Registro identificável que representa o pedido de processar um vídeo para um proprietário | Possui ciclo de vida e referências aos arquivos; não é o vídeo nem uma execução do processador | Inferido |
| Identificador do trabalho | Valor único e estável usado para correlacionar submissão, processamento, consulta e resultado | Não deve depender apenas de nome de arquivo ou timestamp; formato ainda não foi escolhido | Inferido |
| Aceitação do trabalho | Momento em que o sistema confirma ao usuário que assumiu responsabilidade pelo trabalho | Ocorre depois das validações de admissão e somente quando trabalho, proprietário, estado e referência da origem podem ser recuperados; mecanismo e atomicidade estão `A confirmar` | Inferido; regra `Validada na descoberta` |
| Rejeição do envio | Recusa da submissão antes de o sistema aceitar um trabalho processável | Pode interromper antecipadamente a transferência e comunica os problemas de admissão verificáveis; não é falha de processamento | Inferido; regra `Validada na descoberta` |
| Cota acumulada de trabalhos | Número máximo total de trabalhos que um usuário pode criar ao longo do tempo | Não será aplicada neste ciclo; não deve ser confundida com proteção de frequência, concorrência ou capacidade | `Validado na descoberta` |
| Limite operacional de submissões | Restrição de frequência, concorrência ou capacidade aplicada aos envios e trabalhos ativos | Protege recursos sem reduzir a quantidade acumulada de trabalhos que o usuário pode criar | Inferido; valores `A confirmar` |
| Estado do trabalho | Fase vigente do ciclo de vida de um trabalho de vídeo | É autoridade de Trabalhos de Vídeo; o processador relata fatos e não altera o estado livremente | Inferido |
| Processamento de mídia | Transformação do vídeo de origem em imagens extraídas e em um resultado empacotado | Não inclui autenticação, propriedade, consulta do trabalho ou entrega de notificação | Declarado; delimitação Inferida |
| Tentativa de processamento | Uma execução correlacionada do processamento de um trabalho e de seu vídeo de origem | Possui identidade própria, mas não cria outro trabalho nem representa nova submissão | Inferido |
| Reentrega duplicada | Repetição técnica da mesma solicitação ou mensagem já tratada | Deve ser idempotente e não cria trabalho, tentativa, ciclo ou resultado adicional | Inferido |
| Retentativa automática de processamento | Nova tentativa do mesmo trabalho iniciada pelo sistema depois de falha transitória de infraestrutura | Usa o mesmo vídeo de origem e está sujeita ao limite do ciclo; não é nova submissão | `Validado na descoberta`; mecanismo Inferido |
| Ciclo de retentativas automáticas | Tentativa inicial e repetições automáticas autorizadas para recuperar uma falha transitória | Possui limite finito; quantidade, espera progressiva e controles estão `A confirmar` | Inferido da regra validada |
| Limite de retentativas automáticas por ciclo | Quantidade máxima de execuções automáticas dentro de um ciclo | Evita repetição infinita por falha de infraestrutura; não limita novas submissões nem o reprocessamento manual autorizado | `Validado na descoberta`; valor `A confirmar` |
| Reprocessamento solicitado | Ação do proprietário que inicia outro ciclo no mesmo trabalho depois de uma falha | Preserva identificador, vídeo de origem e histórico; não requer novo envio e não está sujeito a cota acumulada | Inferido; autorização e contrato físico `A confirmar` |
| Imagem extraída | Imagem produzida a partir de um instante do vídeo de origem | `Frame` é sinônimo técnico aceito; frequência e formato da extração estão `A confirmar` | Declarado; detalhes `A confirmar` |
| Resultado do processamento | Conteúdo produzido quando o processamento termina com sucesso | No escopo atual, é um arquivo ZIP com as imagens extraídas; não inclui o vídeo de origem | Declarado |
| Falha de processamento | Término sem resultado utilizável devido a erro ao transformar ou empacotar o vídeo | Deve ser distinguida de rejeição do envio e de falha ao notificar | Inferido |
| Falha transitória | Falha de infraestrutura ou dependência para a qual uma repetição posterior pode progredir sem alterar o vídeo | Pode iniciar retentativa automática; taxonomia concreta está `A confirmar` | Inferido |
| Falha permanente | Falha para a qual repetir automaticamente o mesmo processamento não produz progresso esperado | Encerra o ciclo automático e deixa o trabalho falho até nova decisão; taxonomia concreta está `A confirmar` | Inferido |
| Histórico do trabalho | Registro estruturado de estados, ciclos e tentativas relevantes de um trabalho | Não significa reter logs brutos, credenciais, comandos ou diagnósticos sensíveis | Inferido |
| Retenção do trabalho | Política de disponibilidade do vídeo de origem, resultado e histórico | Não há expiração automática por enquanto; exclusão explícita e revisão por custo, privacidade ou obrigação legal podem ser definidas depois | `Validado na descoberta` |
| Notificação de falha | Comunicação ao usuário sobre uma falha de processamento já registrada | Não define nem altera o estado do trabalho; obrigatoriedade, consentimento e garantias estão `A confirmar` | Declarado como possibilidade; detalhes `A confirmar` |
| Canal de notificação | Meio externo utilizado para entregar uma notificação | E-mail é um exemplo do enunciado, não uma escolha aceita | Declarado; escolha `A confirmar` |
| Falha de notificação | Tentativa sem sucesso de entregar uma notificação por um canal | Não altera uma falha de processamento já registrada nem torna o trabalho bem-sucedido | Inferido |
| Atualização em tempo real do trabalho | Comunicação posterior à aceitação sobre andamento ou falha assíncrona | Não substitui a resposta da submissão nem implica WebSocket, SSE ou responsabilidade de Notificações | Inferido; necessidade e transporte `A confirmar` |

## Estados candidatos do trabalho

Os nomes abaixo formam o conjunto candidato atual, não uma máquina de estados aceita.

| Estado | Significado candidato | Não significa |
|---|---|---|
| `AGUARDANDO` | O trabalho foi aceito e está apto a aguardar uma tentativa de processamento | Que existe um executor disponível ou prazo garantido |
| `PROCESSANDO` | Existe uma tentativa ativa de produzir o resultado | Que o resultado parcial pode ser baixado |
| `CONCLUÍDO` | O processamento terminou com sucesso e o resultado está disponível sem expiração automática por enquanto | Que exclusão explícita ou futura revisão da retenção seja impossível |
| `FALHOU` | O ciclo de processamento terminou sem resultado utilizável e a falha foi registrada | Que a notificação foi entregue ou que reprocessamento no mesmo trabalho é impossível |

`Envio recebido` permanece fato da submissão anterior à aceitação, não estado consultável do trabalho. Um reprocessamento autorizado preserva o histórico e permite a transição de `FALHOU` para `AGUARDANDO`; não é necessário um estado próprio de retentativa.

Estados de rejeição, cancelamento e expiração não integram o vocabulário principal atual.

## Termos a normalizar

| Evitar como sinônimo impreciso | Preferir | Motivo |
|---|---|---|
| Job, pedido, processo ou requisição | Trabalho de vídeo | Distingue o registro durável da requisição HTTP e da execução |
| Vídeo processado | Resultado do processamento | O resultado atual é um ZIP de imagens, não outro vídeo |
| Dono do arquivo | Proprietário do trabalho | A autorização decorre do trabalho e cobre suas entradas e resultados |
| Status | Estado do trabalho | `Estado` representa o conceito do domínio; `status` pode permanecer como rótulo de interface |
| Erro | Rejeição do envio, falha de processamento ou falha de notificação | Cada falha ocorre em uma responsabilidade e produz consequências diferentes |
| Tentativa | Nova submissão, tentativa de processamento, retentativa automática, reprocessamento solicitado ou reentrega duplicada | O termo isolado esconde identidades, gatilhos e efeitos diferentes |
| Limite de tentativas | Cota acumulada de trabalhos, limite operacional de submissões ou limite de retentativas automáticas por ciclo | Cada limite protege um aspecto distinto e somente a retentativa automática possui teto funcional confirmado |
| Arquivo final | Resultado do processamento | Mantém o vocabulário independente do formato futuro |

## Vocabulário técnico fora deste glossário

Fila, broker, tópico, banco de dados, bucket, endpoint, container, microsserviço, quantum, porta e adaptador descrevem implementação ou arquitetura. Eles podem aparecer nos documentos técnicos, mas não devem substituir os termos do domínio nem criar requisitos de negócio.

## Manutenção

- Use o termo preferido nas histórias, componentes, contratos, testes e apresentação.
- Ao introduzir um termo, registre sua definição, autoridade e relação com os conceitos existentes.
- Quando uma questão for respondida, substitua `A confirmar` por uma referência ao requisito ou ADR correspondente.
- Reabra as fronteiras dos componentes se dois componentes passarem a reivindicar autoridade diferente sobre o mesmo termo.
