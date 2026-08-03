---
context_id: R6-DEC-LOG-001
context_type: decision_log
status: ativo
recorded_at: 2026-08-03
valid_from: 2026-08-03
relations:
  - type: derived_from
    target: R6-PROP-001
  - type: informed_by
    target: CTX-CMP-002
  - type: governed_by
    target: CTX-GOV-001
---

# Histórico de decisões e sugestões

## Convenções

Este é um registro curado da conversa, não uma transcrição literal. A ordem preserva a evolução do raciocínio; nenhuma data intermediária foi inventada.

| Situação | Significado neste pacote |
|---|---|
| `aceita_na_conversa` | o usuário confirmou a direção para esta proposta |
| `substituida` | uma formulação posterior tomou seu lugar nesta proposta |
| `adiada` | permanece possível, mas fora do escopo atual |
| `condicional` | só deve ser adotada quando aparecer o sinal registrado |
| `nao_adotada_agora` | foi avaliada e não integra a base atual |
| `a_confirmar` | ainda não houve escolha suficiente |

## Linha de evolução

| Ordem | Proposta ou decisão | Situação final | Consequência preservada |
|---:|---|---|---|
| 1 | Uma história combinava envio do vídeo e obtenção das imagens | `substituida` | dividida em `R6-US-01` e `R6-US-02` |
| 2 | Tratar segurança e autenticação junto ao ciclo de negócio | `adiada` | não significa acesso público nem rejeição do requisito canônico |
| 3 | Usar quatro componentes: Recebe Vídeos, Baixar Imagens, Processador de Vídeo e Notifica Usuário | `substituida` | serviu como inventário inicial da conversa |
| 4 | Notificar somente falhas | `substituida` | `R6-US-04` inclui submissão e processamento, sucesso e falha |
| 5 | Usar o ator e nome “cliente” | `substituida` | vocabulário padronizado como **Usuário** |
| 6 | Adicionar visão do andamento | `aceita_na_conversa` | originou `R6-CMP-05` e histórias de consulta |
| 7 | Adicionar reprocessamento, cancelamento, preferências e download individual | `aceita_na_conversa` | originou `R6-US-07..10` |
| 8 | Criar Gerenciar Trabalho em Andamento para H7 e H8 | `aceita_na_conversa` com ajuste de nome | `R6-CMP-02` detém estado, histórico, reprocessamento, cancelamento e disputas |
| 9 | Chamar componentes de “trabalho em andamento” | `substituida` | “Trabalhos de Vídeo” inclui também estados terminais |
| 10 | Colocar disponibilidade consolidada do resultado na Entrega | `aceita_na_conversa` | Entrega possui disponibilidade física; Gerenciar decide disponibilidade no negócio |
| 11 | Manter tentativas, contador e retentativas automáticas | `nao_adotada_agora` | reprocessamento atua no mesmo trabalho sem entidade Tentativa |
| 12 | Processamento gerar o ZIP | `substituida` | Processamento termina em imagens; Entrega resolve ZIP e formatos de acesso |
| 13 | Dividir imediatamente componentes com muitas responsabilidades | `nao_adotada_agora` | seis fronteiras permanecem; quatro divisões ficam condicionais |
| 14 | Usar a base de seis componentes como proposta de continuidade | `aceita_na_conversa` | inventário registrado em `R6-CMP-MODEL-001` |
| 15 | Escolher um quantum ou uma quantidade de serviços | `a_confirmar` | alternativas A, B e C permanecem candidatas |

## Divisões condicionais

| Sugestão | Situação | Condição de revisão |
|---|---|---|
| Submissão: coordenação × admissão | `condicional` | regras e testes de admissão evoluírem independentemente |
| Processamento: controle × extração | `condicional` | escala ou falha exigirem ciclo operacional diferente |
| Entrega: acesso × empacotamento | `condicional` | ZIP adquirir carga, falhas ou evolução próprias |
| Notificação: preferências × envio | `condicional` | multiplicidade de canais ou regras justificar autoridade separada |
| Gerenciar: estado/histórico × comandos | `nao_adotada_agora` | separar agora duplicaria a autoridade das transições |

## Recomendações ainda não aceitas como decisão

- comparar primeiro as alternativas de quantum A e B por meio de um fluxo executável;
- medir backlog, duração do processamento e custo de geração do ZIP antes de separar implantação;
- reintroduzir segurança numa rodada própria, antes de tratar a proposta como produto pronto;
- promover a proposta somente com registros de mudança e decisões que reconciliem os artefatos canônicos.

## Condições de revisão

Reabra este histórico por acréscimo no [histórico do roadmap](acompanhamento/historico.md), sem mudar retroativamente a situação relatada, quando o usuário confirmar uma opção aberta, uma implementação contradizer a fronteira ou uma medição justificar divisão ou agrupamento.
