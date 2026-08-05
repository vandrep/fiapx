---
context_id: R6-DELTA-001
context_type: comparison
status: em_analise
recorded_at: 2026-08-03
valid_from: 2026-08-03
relations:
  - type: derived_from
    target: R6-CMP-MODEL-001
  - type: informed_by
    target: CTX-CMP-002
  - type: informed_by
    target: CTX-REQ-001
  - type: governed_by
    target: CTX-GOV-001
---

# Comparação com o modelo canônico de 2026-08-02

> Esta comparação retrata o baseline [`CTX-CMP-002`](../../arquitetura/componentes.md) vigente quando a proposta foi registrada. Desde 2026-08-03, o modelo ativo é [`CTX-CMP-003`](../../arquitetura/componentes-coesos.md), produzido pela consolidação conservadora de [`REQ-CHG-0003`](../../requisitos/refinamentos/REQ-CHG-0003.md). A tabela abaixo permanece histórica e não deve ser lida como estado corrente.

## Como ler

Quando registrada, esta comparação tornou explícitas divergências e preservações sem promover a proposta nem encerrar a validade do [modelo então canônico `CTX-CMP-002`](../../arquitetura/componentes.md). A atualização temporal acima define a leitura vigente.

Estados usados:

- **mantida:** mesma intenção principal;
- **absorvida:** responsabilidade reunida numa fronteira mais ampla;
- **transferida:** responsabilidade permanece, mas muda de proprietário;
- **expandida:** proposta inclui comportamento adicional;
- **adiada:** sai apenas desta rodada;
- **removida da proposta:** não integra o modelo atual proposto, sem reescrever o canônico.

## Histórias canônicas

| História canônica | Tratamento na proposta | Destino ou observação |
|---|---|---|
| [`US-01`](../../requisitos/historias.md#us-01) Autenticar-se | adiada | segurança e identidade ficam fora desta rodada de negócio |
| [`US-02`](../../requisitos/historias.md#us-02) Enviar vídeo | mantida e simplificada | [`R6-US-01`](historias.md#r6-us-01); detalhes assíncronos retornam como critérios futuros |
| [`US-03`](../../requisitos/historias.md#us-03) Processar concorrentemente | transferida de história para característica | [`R6-US-05`](historias.md#r6-us-05) preserva valor; concorrência pressiona `R6-CA-02` |
| [`US-04`](../../requisitos/historias.md#us-04) Preservar trabalhos | parcialmente mantida | estado e recuperação ficam em `R6-CMP-02`; tentativas e retentativas automáticas saem da proposta |
| [`US-05`](../../requisitos/historias.md#us-05) Consultar trabalhos | expandida | [`R6-US-03`](historias.md#r6-us-03) e [`R6-US-06`](historias.md#r6-us-06) |
| [`US-06`](../../requisitos/historias.md#us-06) Baixar resultado | expandida | [`R6-US-02`](historias.md#r6-us-02) e [`R6-US-10`](historias.md#r6-us-10); ZIP migra para Entrega |
| [`US-07`](../../requisitos/historias.md#us-07) Notificação de falha | expandida | [`R6-US-04`](historias.md#r6-us-04) cobre submissão e processamento, sucesso e falha; `R6-US-09` configura comunicações |

As histórias locais `R6-US-07` (reprocessar) e `R6-US-08` (cancelar) tornam explícitas ações antes misturadas ao ciclo de trabalho.

<a id="componentes-canonicos"></a>

## Componentes canônicos

| Componente canônico | Tratamento | Componente proposto | Mudança relevante |
|---|---|---|---|
| `CMP-05` Identidade e Acesso | adiado | — | não rejeitado nem substituído |
| `CMP-06` Submissão de Vídeos | mantido | [`R6-CMP-01`](componentes.md#r6-cmp-01) | coordena entrada, aceitação e acionamento inicial |
| `CMP-07` Admissão de Vídeos | absorvido | `R6-CMP-01` | reabrir divisão se regras adquirirem evolução independente |
| `CMP-08` Aceitação de Trabalhos | absorvido | `R6-CMP-01` + [`R6-CMP-02`](componentes.md#r6-cmp-02) | Submissão decide aceitação; Gerenciar preserva trabalho e estado |
| `CMP-09` Consulta de Trabalhos | mantido e renomeado | [`R6-CMP-05`](componentes.md#r6-cmp-05) | visão inclui motivo de falha |
| `CMP-10` Política de Tentativas | removido da proposta | `R6-CMP-02` somente para reprocessamento manual | conceito de tentativas foi retirado por decisão explícita |
| `CMP-11` Despacho de Processamento | absorvido | `R6-CMP-01` e `R6-CMP-02` | início e reprocessamento acionam o processador por razões distintas |
| `CMP-12` Execução de Tentativas | absorvido e simplificado | [`R6-CMP-03`](componentes.md#r6-cmp-03) | mantém execução e concorrência sem entidade Tentativa |
| `CMP-13` Extração de Imagens | absorvido | `R6-CMP-03` | permanece núcleo da transformação |
| `CMP-14` Empacotamento de Resultados | transferido | [`R6-CMP-04`](componentes.md#r6-cmp-04) | ZIP passa a ser representação de entrega |
| `CMP-15` Registro de Desfecho | absorvido | `R6-CMP-02` | mesma autoridade sobre estado, histórico e disputas |
| `CMP-16` Acesso a Resultados | expandido e renomeado | `R6-CMP-04` | entrega conjunto ou item individual e consolida disponibilidade física |
| `CMP-17` Comunicação de Falhas | expandido e renomeado | [`R6-CMP-06`](componentes.md#r6-cmp-06) | Notifica Usuário cobre mais eventos e configurações |

<a id="diferencas-que-exigem-decisao-antes-de-promocao"></a>

## Diferenças que exigem decisão antes de promoção

- reintroduzir ou não identidade e segurança na mesma rodada canônica;
- reconciliar a retirada de tentativas com regras já validadas em `CTX-REQ-001` e no glossário;
- decidir se admissão e aceitação simplificadas preservam as garantias de confiabilidade necessárias;
- confirmar a semântica de trabalho concluído com imagens recuperáveis, sem exigir ZIP pré-gerado;
- confirmar eventos, canais e garantias de notificação.
