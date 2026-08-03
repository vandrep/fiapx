---
context_id: R6-CMP-MODEL-001
context_type: component_model
status: em_analise
recorded_at: 2026-08-03
valid_from: 2026-08-03
entities:
  - R6-CMP-01
  - R6-CMP-02
  - R6-CMP-03
  - R6-CMP-04
  - R6-CMP-05
  - R6-CMP-06
relations:
  - type: derived_from
    target: R6-REQ-001
  - type: informed_by
    target: CTX-CMP-002
  - type: informed_by
    target: R6-CHAR-001
  - type: governed_by
    target: CTX-GOV-001
---

# Modelo proposto de seis componentes

## Status do ciclo

O inventário abaixo resulta da rodada conversacional e foi verificado como hipótese lógica. Ele não define microsserviços, processos, bancos, repositórios nem unidades de implantação.

`identificado → histórias atribuídas → responsabilidades analisadas → características analisadas → refatorado → verificado`

A técnica predominante foi `Workflow`, complementada pelos atos do Usuário. O termo **Trabalho de Vídeo** aparece em vários limites, mas não cria `Entity Trap`: cada componente detém um comportamento distinto, e somente Gerenciar Trabalhos de Vídeo possui autoridade sobre estado e transições.

## Inventário refinado

<a id="r6-cmp-01"></a>

### R6-CMP-01 — Submissão de Vídeos

**Papel:** receber o vídeo e iniciar um novo trabalho aceito.

- **Possui:** condução da submissão; validações de negócio necessárias à aceitação; associação entre origem e trabalho; acionamento inicial do processamento; emissão de fatos de submissão para notificação.
- **Não possui:** ciclo de estado após a aceitação; extração; ZIP; entrega; preferências ou envio de notificações.
- **Autoridade:** decisão de aceitar ou rejeitar uma nova submissão e os dados capturados nessa entrada.
- **Fornece:** `SubmeterVideo`, `SubmissaoAceita` e `SubmissaoRejeitada`.
- **Depende de:** Gerenciar Trabalhos para registrar o trabalho; Processamento para iniciar o fluxo; Notifica Usuário para comunicar o resultado da submissão.

<a id="r6-cmp-02"></a>

### R6-CMP-02 — Gerenciar Trabalhos de Vídeo

**Papel:** preservar e governar o ciclo de vida do trabalho de vídeo.

- **Possui:** estado corrente; histórico de transições; decisão de permitir reprocessamento manual; decisão e transição de cancelamento; resolução de disputas entre fatos concorrentes; registro de sucesso, falha ou interrupção; decisão de que um resultado completo está disponível ao negócio.
- **Não possui:** transferência do vídeo; extração de imagens; montagem de ZIP; consultas projetadas; entrega de mensagens externas.
- **Autoridade:** identidade, estado, histórico e transições válidas do trabalho.
- **Fornece:** `RegistrarTrabalho`, `SolicitarReprocessamento`, `CancelarTrabalho`, `RegistrarDesfecho` e fatos autossuficientes do trabalho.
- **Depende de:** Processamento para fatos da execução; Entrega para confirmar imagens recuperáveis.

<a id="r6-cmp-03"></a>

### R6-CMP-03 — Processamento de Mídia

**Papel:** transformar um vídeo de origem em um conjunto completo de imagens extraídas.

- **Possui:** leitura da origem; extração; isolamento entre trabalhos; controle do uso concorrente de recursos; classificação do resultado técnico como sucesso, falha ou interrupção.
- **Não possui:** estado do trabalho; decisão de reprocessar ou cancelar; empacotamento ZIP; entrega ao usuário; comunicação externa.
- **Autoridade:** execução da transformação e integridade do conjunto produzido antes de publicá-lo.
- **Fornece:** `ProcessarVideo`, `ImagensExtraidas` e `ProcessamentoFalhou`.
- **Depende de:** Gerenciar Trabalhos para ordens válidas; Entrega de Imagens para receber o conjunto; adaptadores técnicos de mídia e armazenamento.

<a id="r6-cmp-04"></a>

### R6-CMP-04 — Entrega de Imagens

**Papel:** tornar as imagens extraídas recuperáveis e entregá-las no formato solicitado.

- **Possui:** disponibilidade física consolidada; catálogo das imagens; download individual; geração sob demanda ou antecipada de ZIP; validação de que o conjunto entregue está completo.
- **Não possui:** extração; estado de negócio do trabalho; decisão de reprocessar; preferências de notificação.
- **Autoridade:** representações de entrega e recuperabilidade física dos artefatos.
- **Fornece:** `RegistrarImagens`, `ConfirmarImagensRecuperaveis`, `BaixarImagem` e `BaixarConjunto`.
- **Depende de:** Processamento para imagens; Gerenciar Trabalhos para elegibilidade de entrega.

<a id="r6-cmp-05"></a>

### R6-CMP-05 — Visualizar Trabalhos de Vídeo

**Papel:** oferecer uma visão somente leitura dos trabalhos e de seu histórico relevante.

- **Possui:** projeção para lista e detalhe; apresentação de estado, datas e progresso; apresentação de motivo de falha apropriado ao usuário.
- **Não possui:** alterar estado; decidir cancelamento ou reprocessamento; entregar imagens; notificar.
- **Autoridade:** formato e composição do modelo de leitura, nunca os fatos de origem.
- **Fornece:** `ListarTrabalhos` e `DetalharTrabalho`.
- **Depende de:** fatos publicados por Gerenciar Trabalhos e, se necessário, indicação de disponibilidade da Entrega.

<a id="r6-cmp-06"></a>

### R6-CMP-06 — Notifica Usuário

**Papel:** decidir e executar comunicações configuradas sobre acontecimentos do trabalho.

- **Possui:** preferências de eventos e canais; composição da mensagem; escolha do canal configurado; registro do desfecho da comunicação.
- **Não possui:** alterar estado do trabalho; interpretar diagnóstico bruto; aceitar submissão; extrair ou entregar imagens.
- **Autoridade:** configuração de comunicação do usuário e histórico próprio de envio.
- **Fornece:** `ConfigurarNotificacoes` e `NotificarAcontecimento`.
- **Depende de:** fatos autossuficientes da Submissão e de Gerenciar Trabalhos; adaptadores de canal.

## Atribuição final das histórias

| História | Responsável principal | Colaboradores | Contrato relevante |
|---|---|---|---|
| [`R6-US-01`](historias.md#r6-us-01) | [`R6-CMP-01`](#r6-cmp-01) | `R6-CMP-02`, `R6-CMP-03`, `R6-CMP-06` | submissão aceita cria trabalho e inicia processamento |
| [`R6-US-02`](historias.md#r6-us-02) | [`R6-CMP-04`](#r6-cmp-04) | `R6-CMP-02` | trabalho elegível permite entrega do conjunto |
| [`R6-US-03`](historias.md#r6-us-03) | [`R6-CMP-05`](#r6-cmp-05) | `R6-CMP-02`, `R6-CMP-04` | projeção recebe fatos, sem comandar o ciclo |
| [`R6-US-04`](historias.md#r6-us-04) | [`R6-CMP-06`](#r6-cmp-06) | `R6-CMP-01`, `R6-CMP-02` | fatos de submissão e processamento acionam comunicação |
| [`R6-US-05`](historias.md#r6-us-05) | [`R6-CMP-03`](#r6-cmp-03) | `R6-CMP-02`, `R6-CMP-04` | processamento publica imagens ou falha correlacionada |
| [`R6-US-06`](historias.md#r6-us-06) | [`R6-CMP-05`](#r6-cmp-05) | `R6-CMP-02` | falha consolidada alimenta a visão do usuário |
| [`R6-US-07`](historias.md#r6-us-07) | [`R6-CMP-02`](#r6-cmp-02) | `R6-CMP-03` | reprocessamento autorizado reutiliza origem do trabalho |
| [`R6-US-08`](historias.md#r6-us-08) | [`R6-CMP-02`](#r6-cmp-02) | `R6-CMP-03` | cancelamento muda estado e solicita interrupção quando aplicável |
| [`R6-US-09`](historias.md#r6-us-09) | [`R6-CMP-06`](#r6-cmp-06) | — | configuração permanece dentro da comunicação |
| [`R6-US-10`](historias.md#r6-us-10) | [`R6-CMP-04`](#r6-cmp-04) | `R6-CMP-02` | trabalho elegível permite entrega de uma imagem |

## Dependências e acoplamento

| Origem | Destino | Natureza | Restrição |
|---|---|---|---|
| Submissão | Gerenciar | necessário do domínio | trabalho deve existir antes do processamento |
| Submissão | Processamento | temporal | acionamento somente após aceitação recuperável |
| Processamento | Gerenciar | fatos correlacionados | processador não altera estado livremente |
| Processamento | Entrega | conjunto de imagens | ZIP não faz parte desse contrato |
| Entrega | Gerenciar | confirmação de recuperabilidade | conclusão exige conjunto completo recuperável |
| Gerenciar | Visualizar | fatos/projeção | consulta não comanda o núcleo |
| Submissão/Gerenciar | Notifica | fatos autossuficientes | falha do canal não muda o trabalho |

O maior `fan-out` está em Submissão e Gerenciar, por coordenarem entrada e ciclo. Esse acoplamento é aceitável enquanto os contratos permanecerem orientados a fatos e comandos de negócio. Métricas `CA/CE` físicas dependem da implementação.

## Responsabilidades sem componente

Não há responsabilidade de negócio identificada sem proprietário nesta rodada. Permanecem deliberadamente fora dos componentes lógicos:

- autenticação, autorização e segurança, adiadas para outra rodada;
- armazenamento, fila, broker, HTTP, FFmpeg, ZIP e canais externos, tratados como mecanismos ou adaptadores;
- observabilidade, CI/CD e testes, tratados como capacidades de suporte e verificação.

## Avaliação de novas divisões

Nenhuma divisão adicional foi adotada agora. Os sinais para reabrir as fronteiras são:

| Componente | Divisão condicional | Sinal concreto |
|---|---|---|
| Submissão | coordenação × admissão | regras de admissão crescerem ou evoluírem independentemente do fluxo |
| Processamento | controle da execução × extração | escalabilidade, falhas ou tecnologia exigirem ciclos operacionais distintos |
| Entrega | catálogo/acesso × empacotamento | geração de ZIP tiver carga, falhas ou evolução próprias |
| Notifica Usuário | preferências × envio | múltiplos canais introduzirem política e operação independentes |

Gerenciar Trabalhos não deve ser separado entre estado, histórico, reprocessamento e cancelamento enquanto essas decisões precisarem da mesma autoridade transacional.

## Verificação de convergência

- as dez histórias possuem um único responsável principal;
- os seis papéis são distintos e não duplicam autoridade;
- estado do negócio e disponibilidade física têm autoridades separadas e contrato explícito;
- ZIP pertence à entrega, não ao processamento;
- não há conceito de tentativa ou retentativa automática no modelo atual da proposta;
- quanta são avaliados somente depois deste inventário, em [características e quanta](caracteristicas-e-quanta.md).
