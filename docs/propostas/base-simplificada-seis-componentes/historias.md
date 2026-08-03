---
context_id: R6-REQ-001
context_type: requirement_set
status: em_analise
recorded_at: 2026-08-03
valid_from: 2026-08-03
entities:
  - R6-US-01
  - R6-US-02
  - R6-US-03
  - R6-US-04
  - R6-US-05
  - R6-US-06
  - R6-US-07
  - R6-US-08
  - R6-US-09
  - R6-US-10
relations:
  - type: derived_from
    target: CTX-REQ-001
  - type: informed_by
    target: CTX-DOM-001
  - type: informs
    target: R6-CMP-MODEL-001
  - type: governed_by
    target: CTX-GOV-001
---

# Histórias propostas

## Escopo

Esta rodada foca o negócio de submissão, processamento, acompanhamento, entrega e notificação. Segurança e identidade foram adiadas, não rejeitadas. Concorrência, preservação do trabalho e não perda são tratadas como critérios ou características, sem criar histórias artificiais.

O ator padronizado é **Usuário**. Cada história tem exatamente um responsável principal no [modelo proposto](componentes.md#atribuicao-final-das-historias).

## Inventário

<a id="r6-us-01"></a>

### R6-US-01 — Submeter vídeo

Como usuário, quero submeter um vídeo para que suas imagens possam ser extraídas.

- **Origem:** separação da história inicial que combinava envio e download.
- **Responsável principal:** [`R6-CMP-01`](componentes.md#r6-cmp-01), Submissão de Vídeos.
- **Situação:** aceita na conversa; critérios de admissão permanecem a confirmar.

<a id="r6-us-02"></a>

### R6-US-02 — Baixar imagens em conjunto

Como usuário, quero baixar em conjunto as imagens extraídas do meu vídeo para obter o resultado de forma conveniente.

- **Origem:** metade de entrega separada da história inicial.
- **Responsável principal:** [`R6-CMP-04`](componentes.md#r6-cmp-04), Entrega de Imagens.
- **Situação:** aceita na conversa; ZIP é uma representação de entrega, não produto do processamento.

<a id="r6-us-03"></a>

### R6-US-03 — Visualizar trabalhos de vídeo

Como usuário, quero visualizar meus trabalhos de vídeo e seus estados para acompanhar o andamento e saber quando agir.

- **Origem:** necessidade de acompanhamento do trabalho em andamento, ampliada para incluir estados terminais.
- **Responsável principal:** [`R6-CMP-05`](componentes.md#r6-cmp-05), Visualizar Trabalhos de Vídeo.
- **Situação:** aceita na conversa; campos, paginação e ordenação estão a confirmar.

<a id="r6-us-04"></a>

### R6-US-04 — Receber notificações do trabalho

Como usuário, quero receber notificações sobre a submissão e o processamento do meu vídeo para acompanhar seus resultados, sejam eles de sucesso ou de falha.

- **Origem:** substitui a formulação restrita à notificação de falha.
- **Responsável principal:** [`R6-CMP-06`](componentes.md#r6-cmp-06), Notifica Usuário.
- **Situação:** aceita na conversa; eventos exatos e garantias de entrega estão a confirmar.

<a id="r6-us-05"></a>

### R6-US-05 — Processar vídeo

Como usuário, quero que meu vídeo seja processado para que imagens sejam extraídas dele.

- **Origem:** capacidade central declarada pelo problema.
- **Responsável principal:** [`R6-CMP-03`](componentes.md#r6-cmp-03), Processamento de Mídia.
- **Situação:** aceita na conversa; frequência, formato e resolução das imagens estão a confirmar.

<a id="r6-us-06"></a>

### R6-US-06 — Consultar motivo da falha

Como usuário, quero consultar o motivo de uma falha para entender o que ocorreu e decidir o próximo passo.

- **Origem:** história adicional sugerida e aceita.
- **Responsável principal:** [`R6-CMP-05`](componentes.md#r6-cmp-05), Visualizar Trabalhos de Vídeo.
- **Situação:** aceita na conversa; nível de detalhe apresentado está a confirmar.

<a id="r6-us-07"></a>

### R6-US-07 — Reprocessar trabalho com falha

Como usuário, quero solicitar o reprocessamento do mesmo trabalho após uma falha para tentar obter as imagens sem reenviar o vídeo.

- **Origem:** história adicional sugerida e aceita.
- **Responsável principal:** [`R6-CMP-02`](componentes.md#r6-cmp-02), Gerenciar Trabalhos de Vídeo.
- **Situação:** aceita na conversa; não introduz tentativas, contadores ou retentativas automáticas no domínio.

<a id="r6-us-08"></a>

### R6-US-08 — Cancelar trabalho

Como usuário, quero cancelar um trabalho pendente ou em processamento para interromper um resultado que não desejo mais.

- **Origem:** história adicional sugerida e aceita.
- **Responsável principal:** [`R6-CMP-02`](componentes.md#r6-cmp-02), Gerenciar Trabalhos de Vídeo.
- **Situação:** aceita na conversa; semântica de interrupção quando já existe execução está a confirmar.

<a id="r6-us-09"></a>

### R6-US-09 — Configurar notificações

Como usuário, quero configurar quais eventos e por qual canal desejo ser notificado para receber comunicações úteis para mim.

- **Origem:** história adicional sugerida e aceita.
- **Responsável principal:** [`R6-CMP-06`](componentes.md#r6-cmp-06), Notifica Usuário.
- **Situação:** aceita na conversa; canais disponíveis e padrão inicial estão a confirmar.

<a id="r6-us-10"></a>

### R6-US-10 — Baixar imagem individual

Como usuário, quero baixar uma imagem extraída individualmente para obter somente o item de que preciso.

- **Origem:** história adicional sugerida e aceita.
- **Responsável principal:** [`R6-CMP-04`](componentes.md#r6-cmp-04), Entrega de Imagens.
- **Situação:** aceita na conversa; seleção e nomenclatura das imagens estão a confirmar.

## Questões abertas

- Quais formatos, tamanhos e duração de vídeo serão admitidos?
- Quais estados compõem o ciclo do trabalho e quando o cancelamento ainda é permitido?
- Quais eventos de submissão e processamento geram comunicação por padrão?
- Qual conteúdo de falha é útil ao usuário sem expor detalhe técnico desnecessário?
- Quando e por quanto tempo vídeo, imagens e histórico permanecem recuperáveis?
