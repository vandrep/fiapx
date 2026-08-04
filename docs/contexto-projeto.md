---
context_id: CTX-PRJ-001
context_type: project_context
status: ativo
recorded_at: 2026-08-01
valid_from: 2026-08-01
relations:
  - type: derived_from
    target: docs/enunciado.md
  - type: derived_from
    target: docs/referencia/projeto-original/
  - type: governed_by
    target: CTX-GOV-001
  - type: informed_by
    target: DEC-0002
  - type: informed_by
    target: DEC-0004
  - type: informed_by
    target: DEC-0005
---

# Contexto do projeto FIAP X

Este documento fornece contexto específico do projeto aos agentes. Ele não define instruções reutilizáveis nem antecipa decisões arquiteturais.

## Fontes e classificação

- **Declarado:** consta do [enunciado](enunciado.md).
- **Observado:** foi verificado no [projeto-base descompactado](referencia/projeto-original/) e, quando necessário, comparado ao [arquivo original](referencia/projeto-fiapx-original.zip).
- **Decidido:** foi aceito pelo grupo e deve apontar para uma decisão em `arquitetura/decisoes/`.
- **Hipótese:** permite avançar, mas ainda precisa de validação.

Quando fontes divergirem, preserve a divergência. O enunciado define a expectativa acadêmica; o código demonstra somente o comportamento atual; uma decisão aceita define a direção escolhida pelo grupo.

## Objetivo declarado

Evoluir um protótipo que extrai imagens de um vídeo e gera um arquivo ZIP para uma aplicação na qual usuários autenticados possam enviar vídeos, acompanhar seu processamento e baixar o resultado.

## Requisitos declarados

### Funcionais

- Processar mais de um vídeo ao mesmo tempo.
- Não perder requisições durante picos.
- Proteger o sistema por usuário e senha.
- Listar o status dos vídeos de um usuário.
- Permitir que um usuário seja notificado em caso de erro, por e-mail ou outro meio.

### Técnicos e entregáveis

- Persistir dados.
- Permitir que a solução seja escalada.
- Versionar o projeto no GitHub.
- Incluir testes que sustentem sua qualidade e um fluxo de CI/CD.
- Entregar documentação da arquitetura e scripts de criação dos recursos persistentes.
- Apresentar a documentação, a arquitetura e o sistema funcionando em um vídeo de até dez minutos.

As tecnologias listadas no enunciado nasceram como recomendações, não obrigações. Kubernetes e Keycloak foram posteriormente aceitos para o ambiente acadêmico em [`DEC-0002`](arquitetura/decisoes/0002-topologia-kubernetes.md) e [`DEC-0005`](arquitetura/decisoes/0005-keycloak-no-ambiente-de-validacao.md); RabbitMQ, PostgreSQL e object storage ainda dependem da validação de [`DEC-0003`](arquitetura/decisoes/0003-entrega-duravel-e-persistencia.md).

## Estado observado do projeto-base

Data da observação: 2026-08-01.

- O projeto-base contém uma aplicação Go 1.21 em um único `main.go`, com Gin 1.9.1 e um Dockerfile.
- A aplicação recebe upload via HTTP, grava o vídeo no sistema de arquivos local, executa `ffmpeg` de forma síncrona, extrai um frame por segundo e cria um ZIP local.
- A resposta do upload aguarda todo o processamento terminar.
- Uploads, arquivos temporários e resultados usam diretórios locais; o status é derivado da listagem de arquivos ZIP.
- Não foram observados no projeto-base: autenticação, propriedade dos vídeos por usuário, fila durável, persistência de metadados, notificação, testes automatizados ou pipeline de CI/CD.
- `main.go`, `go.mod` e `go.sum` da pasta descompactada são idênticos aos do ZIP. O Dockerfile descompactado diverge na origem do `COPY`; essa diferença deve ser esclarecida antes de usá-lo como baseline executável.

Essas observações descrevem o ponto de partida, não obrigam o novo projeto a preservar linguagem, framework, estrutura ou topologia.

## Preferências declaradas

- **Linguagem e framework:** há preferência por Java com Quarkus devido à familiaridade do responsável pelo projeto.

Uma preferência orienta a comparação de opções, mas ainda não é uma decisão arquitetural aceita. Ela deve ser confrontada com prazo, requisitos, custo operacional e capacidades necessárias; se confirmada, a escolha será registrada em ADR.

## Decisões vigentes

- [`DEC-0001`](arquitetura/decisoes/0001-refinamento-de-componentes.md) está aceita e determina o ciclo de refinamento, a granularidade modular e a separação entre componentes lógicos, quanta e unidades de implantação.
- [`DEC-0002`](arquitetura/decisoes/0002-topologia-kubernetes.md) aceita três quanta Kubernetes: `gestao-trabalhos`, `producao-resultados` e `notificador`.
- [`DEC-0004`](arquitetura/decisoes/0004-componentes-coesos-do-nucleo.md) aceita o baseline de oito componentes lógicos de [`CTX-CMP-003`](arquitetura/componentes-coesos.md).
- [`DEC-0005`](arquitetura/decisoes/0005-keycloak-no-ambiente-de-validacao.md) aceita Keycloak empacotado no Kubernetes para validação reproduzível na máquina do professor.

A arquitetura física continua sendo refinada em [`CTX-ARCH-001`](arquitetura/comparacao-e-arquitetura-recomendada.md). Aceite durável, RabbitMQ, outbox/inbox, PostgreSQL e object storage permanecem `em_analise` em [`DEC-0003`](arquitetura/decisoes/0003-entrega-duravel-e-persistencia.md) até a prova vertical.

## Questões em aberto

Estas respostas podem alterar as características prioritárias e as fronteiras dos componentes:

- Qual é o prazo, o tamanho do grupo e o tempo disponível para operação e demonstração?
- A banca exige alguma tecnologia específica além do que está descrito como recomendação?
- Quais características, se alguma, um ambiente futuro de produção terá além do Kubernetes local autocontido da demonstração?
- Quais volume, tamanho e duração de vídeo devem ser suportados na demonstração?
- O que significa "não perder uma requisição" nos casos de reinício, indisponibilidade e falha durante o processamento?
- Quais estados do processamento precisam ser visíveis e por quanto tempo resultados e vídeos devem ser retidos?
- Qual canal, consentimento e garantia de entrega atendem à notificação de falha no escopo acadêmico?
- Quais limites de CPU, memória e tempo de bootstrap a máquina usada na apresentação impõe ao ambiente autocontido?

## Manutenção deste contexto

- Atualize este arquivo quando um requisito for esclarecido ou uma observação relevante do ponto de partida mudar.
- Registre escolhas duráveis como ADR e apenas referencie-as aqui.
- Identifique hipóteses como hipóteses, com responsável ou forma de validação quando isso for útil.
- Remova questões respondidas, substituindo-as por requisito esclarecido ou referência à decisão correspondente.
