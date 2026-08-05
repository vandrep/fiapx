---
context_id: R6-CHAR-001
context_type: architecture_characteristic_set
status: em_analise
recorded_at: 2026-08-03
valid_from: 2026-08-03
entities:
  - R6-CA-01
  - R6-CA-02
relations:
  - type: derived_from
    target: R6-REQ-001
  - type: informed_by
    target: CTX-CHAR-001
  - type: informs
    target: R6-CMP-MODEL-001
  - type: governed_by
    target: CTX-GOV-001
---

# Características arquiteturais e quanta candidatos

> Navegação: [índice da proposta histórica](README.md) · [arquitetura canônica](../../arquitetura/README.md)

## Formato sugerido

Uma característica só orienta a rodada quando possui cenário verificável:

`fonte do estímulo → estímulo → ambiente → artefato afetado → resposta esperada → medida`

As características são propriedades do sistema. Os componentes mostram onde há pressão; não “possuem” confiabilidade ou escalabilidade isoladamente.

## Prioridades da proposta

<a id="r6-ca-01"></a>

### R6-CA-01 — Confiabilidade e recuperabilidade

- **Fonte:** usuário ou falha operacional.
- **Estímulo:** um vídeo é aceito; depois ocorre reinício, falha parcial ou fato duplicado.
- **Ambiente:** operação normal ou recuperação.
- **Artefatos afetados:** Submissão, Gerenciar Trabalhos, Processamento e Entrega.
- **Resposta esperada:** o trabalho aceito continua consultável; seu estado converge; imagens incompletas não o tornam concluído; repetição técnica não cria outro resultado visível.
- **Medidas a confirmar:** ponto de aceitação, tempo de recuperação, retenção e tolerância a perda.

**Fitness functions candidatas:** reiniciar após aceitação; repetir o mesmo fato; falhar entre extração e confirmação da entrega; reconciliar trabalho e imagens recuperáveis.

<a id="r6-ca-02"></a>

### R6-CA-02 — Escalabilidade do processamento

- **Fonte:** aumento de submissões.
- **Estímulo:** mais vídeos são aceitos do que a capacidade instantânea de extração.
- **Ambiente:** pico controlado.
- **Artefatos afetados:** Submissão, Gerenciar Trabalhos e Processamento.
- **Resposta esperada:** o excesso forma backlog observável; trabalhos permanecem isolados; a capacidade de processamento pode variar sem alterar histórias ou autoridade do estado.
- **Medidas a confirmar:** pico, concorrência, throughput, idade máxima do backlog, duração e recursos por vídeo.

**Fitness functions candidatas:** carga concorrente com artefatos isolados; balanço entre aceitos, pendentes, concluídos, cancelados e falhos; comparação ao variar a capacidade do processador.

## Características de suporte e candidatas

| Característica | Tratamento nesta rodada | Evidência necessária |
|---|---|---|
| Observabilidade | suporte às duas prioritárias | estado, duração, backlog, falhas e correlação por trabalho |
| Manutenibilidade e testabilidade | suporte | contratos pequenos, testes de transição e regras de dependência |
| Desempenho | candidata | limite de aceitação, espera, extração e geração de ZIP |
| Disponibilidade | candidata | meta de uptime distinta da recuperação de trabalhos aceitos |
| Segurança | adiada | será reintroduzida em rodada própria; não foi rejeitada |

## Tensões sobre as fronteiras

| Tensão | Benefício | Custo ou risco |
|---|---|---|
| aceitar antes de concluir | desacopla a experiência do tempo de processamento | exige aceitação recuperável e ciclo observável |
| centralizar estado em Gerenciar | reduz transições concorrentes e disputas espalhadas | concentra fan-in e exige contratos de fatos bem definidos |
| separar Processamento | permite capacidade e isolamento próprios | adiciona fronteira temporal e reconciliação |
| gerar ZIP na Entrega | mantém extração independente do formato de acesso | ZIP pode introduzir latência e custo no download |
| separar leitura da escrita | consulta evolui sem comandar o ciclo | projeção pode ficar temporariamente defasada |

<a id="alternativas-candidatas-de-quanta"></a>

## Alternativas candidatas de quanta

Quantum é uma fronteira de acoplamento estático e dinâmico. As alternativas não definem número de serviços, processos, repositórios ou bancos.

### Alternativa A — Um quantum para os seis componentes

| Aspecto | Avaliação inicial |
|---|---|
| Composição | Submissão, Gerenciar, Processamento, Entrega, Visualização e Notificação |
| Benefício | menor coordenação distribuída e menor custo operacional inicial |
| Custo | processamento intensivo compartilha evolução e implantação com interação e comunicação |
| Serve quando | volume é modesto e o objetivo principal é validar o domínio |
| Sinal para sair | processamento exige capacidade, falha ou janela operacional independente |

### Alternativa B — Ciclo e interação separados do processamento

| Quantum candidato | Componentes |
|---|---|
| Ciclo e interação | Submissão, Gerenciar, Entrega, Visualização e Notificação |
| Processamento | Processamento de Mídia |

- **Benefício:** isola a pressão de CPU/I/O e permite variar a capacidade do processador.
- **Custo:** exige contrato durável, idempotência, correlação e reconciliação entre processamento, estado e entrega.
- **Serve quando:** medições comprovam perfil operacional diferente.

### Alternativa C — Quatro regiões

| Quantum candidato | Componentes | Motivação a verificar |
|---|---|---|
| Ciclo do trabalho | Submissão, Gerenciar e Visualização | coesão de estado, comandos e leitura do ciclo |
| Execução de mídia | Processamento | escala e isolamento de recursos |
| Entrega | Entrega de Imagens | carga e evolução de formatos de acesso |
| Comunicação | Notifica Usuário | canais, volume e operação externa próprios |

- **Benefício:** maior independência de mudança e operação quando todas as pressões existirem.
- **Custo:** maior número de contratos, estados parciais, observação e recuperação distribuída.
- **Serve quando:** Entrega e Notificação também demonstrarem ciclos operacionais realmente independentes.

## Comparação e recomendação ainda não aceita

| Critério | A | B | C |
|---|---:|---:|---:|
| simplicidade inicial | alta | média | baixa |
| isolamento do processamento | baixo | alto | alto |
| coordenação distribuída | baixa | média | alta |
| independência de entrega/notificação | baixa | baixa | alta |
| evidência disponível hoje | compatível | parcial | insuficiente |

A recomendação de análise é comparar A e B primeiro com o mesmo fluxo executável e medições. Ela permanece `a confirmar`; C deve continuar como opção condicionada a evidência, não como destino presumido.

## Menor experimento

Executar um lote representativo nas alternativas A e B, exercitando aceitação, backlog, extração, confirmação das imagens e consulta. Comparar duração, recuperação após interrupção, complexidade dos contratos e capacidade de variar apenas o processamento.
