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
  - type: informs
    target: CTX-CMP-001
  - type: governed_by
    target: CTX-GOV-001
---

# Glossário do domínio

## Objetivo

Este glossário estabelece termos de negócio consistentes para as [histórias de usuário](historias.md), os componentes e os futuros contratos do FIAP X. Ele traduz o [enunciado](../enunciado.md) sem transformar inferências ainda em análise em requisitos confirmados.

Classificações usadas:

- `Declarado`: o conceito aparece diretamente no enunciado;
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
| Trabalho de vídeo | Registro identificável que representa o pedido de processar um vídeo para um proprietário | Possui ciclo de vida e referências aos arquivos; não é o vídeo nem uma execução do processador | Inferido |
| Identificador do trabalho | Valor único e estável usado para correlacionar submissão, processamento, consulta e resultado | Não deve depender apenas de nome de arquivo ou timestamp; formato ainda não foi escolhido | Inferido |
| Aceitação do trabalho | Momento em que o sistema confirma ao usuário que assumiu responsabilidade pelo trabalho | Deve ocorrer somente quando o trabalho puder ser recuperado; falhas que essa garantia deve tolerar estão `A confirmar` | Inferido; semântica `A confirmar` |
| Rejeição do envio | Recusa do vídeo antes de o sistema aceitar um trabalho processável | Pode decorrer de formato, conteúdo ou limite inválido; não é falha de processamento | Inferido |
| Estado do trabalho | Fase vigente do ciclo de vida de um trabalho de vídeo | É autoridade de Trabalhos de Vídeo; o processador relata fatos e não altera o estado livremente | Inferido |
| Processamento de mídia | Transformação do vídeo de origem em imagens extraídas e em um resultado empacotado | Não inclui autenticação, propriedade, consulta do trabalho ou entrega de notificação | Declarado; delimitação Inferida |
| Tentativa de processamento | Uma execução correlacionada do processamento de um trabalho | O mesmo trabalho pode exigir nova tentativa sem se tornar outro trabalho; política e limite de retentativas estão `A confirmar` | Inferido |
| Imagem extraída | Imagem produzida a partir de um instante do vídeo de origem | `Frame` é sinônimo técnico aceito; frequência e formato da extração estão `A confirmar` | Declarado; detalhes `A confirmar` |
| Resultado do processamento | Conteúdo produzido quando o processamento termina com sucesso | No escopo atual, é um arquivo ZIP com as imagens extraídas; não inclui o vídeo de origem | Declarado |
| Falha de processamento | Término sem resultado utilizável devido a erro ao transformar ou empacotar o vídeo | Deve ser distinguida de rejeição do envio e de falha ao notificar | Inferido |
| Notificação de falha | Comunicação ao usuário sobre uma falha de processamento já registrada | Não define nem altera o estado do trabalho; obrigatoriedade, consentimento e garantias estão `A confirmar` | Declarado como possibilidade; detalhes `A confirmar` |
| Canal de notificação | Meio externo utilizado para entregar uma notificação | E-mail é um exemplo do enunciado, não uma escolha aceita | Declarado; escolha `A confirmar` |
| Falha de notificação | Tentativa sem sucesso de entregar uma notificação por um canal | Não altera uma falha de processamento já registrada nem torna o trabalho bem-sucedido | Inferido |

## Estados candidatos do trabalho

Os nomes abaixo formam o conjunto candidato atual, não uma máquina de estados aceita.

| Estado | Significado candidato | Não significa |
|---|---|---|
| `RECEBIDO` | O envio terminou e o trabalho foi registrado | Que o processamento já começou ou que o vídeo é processável |
| `AGUARDANDO` | O trabalho está apto a aguardar uma tentativa de processamento | Que existe um executor disponível ou prazo garantido |
| `PROCESSANDO` | Existe uma tentativa ativa de produzir o resultado | Que o resultado parcial pode ser baixado |
| `CONCLUÍDO` | O processamento terminou com sucesso e o resultado está disponível | Que o resultado será retido indefinidamente |
| `FALHOU` | O processamento terminou sem resultado utilizável e a falha foi registrada | Que a notificação foi entregue ou que uma nova tentativa é impossível |

Estados de rejeição, cancelamento, expiração e nova tentativa ainda não possuem evidência suficiente para integrar o vocabulário principal.

A relação exata entre a aceitação do trabalho e as transições para `RECEBIDO` ou `AGUARDANDO` está `A confirmar`.

## Termos a normalizar

| Evitar como sinônimo impreciso | Preferir | Motivo |
|---|---|---|
| Job, pedido, processo ou requisição | Trabalho de vídeo | Distingue o registro durável da requisição HTTP e da execução |
| Vídeo processado | Resultado do processamento | O resultado atual é um ZIP de imagens, não outro vídeo |
| Dono do arquivo | Proprietário do trabalho | A autorização decorre do trabalho e cobre suas entradas e resultados |
| Status | Estado do trabalho | `Estado` representa o conceito do domínio; `status` pode permanecer como rótulo de interface |
| Erro | Rejeição do envio, falha de processamento ou falha de notificação | Cada falha ocorre em uma responsabilidade e produz consequências diferentes |
| Arquivo final | Resultado do processamento | Mantém o vocabulário independente do formato futuro |

## Vocabulário técnico fora deste glossário

Fila, broker, tópico, banco de dados, bucket, endpoint, container, microsserviço, quantum, porta e adaptador descrevem implementação ou arquitetura. Eles podem aparecer nos documentos técnicos, mas não devem substituir os termos do domínio nem criar requisitos de negócio.

## Manutenção

- Use o termo preferido nas histórias, componentes, contratos, testes e apresentação.
- Ao introduzir um termo, registre sua definição, autoridade e relação com os conceitos existentes.
- Quando uma questão for respondida, substitua `A confirmar` por uma referência ao requisito ou ADR correspondente.
- Reabra as fronteiras dos componentes se dois componentes passarem a reivindicar autoridade diferente sobre o mesmo termo.
