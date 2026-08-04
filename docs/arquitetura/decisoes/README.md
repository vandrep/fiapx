# Decisões arquiteturais

Registre aqui decisões com consequência durável, efeito amplo ou custo relevante de reversão. Use um arquivo por decisão e numeração sequencial, por exemplo `0001-estilo-arquitetural.md`.

Cada decisão é um nó independente e segue a [convenção de contexto](../../contexto/README.md). Comece pelo [_template.md](_template.md), atribua um `context_id` único, substitua as datas, remova `template: true` e conecte requisitos, evidências, componentes, decisões anteriores e resultados por relações tipadas.

Cada registro deve conter, no mínimo:

- status e data;
- contexto e decisão necessária;
- características arquiteturais e restrições relevantes;
- opções consideradas e trade-offs;
- decisão e consequências;
- forma de validação;
- sinais ou condições para revisão.

Ao aceitar ou substituir uma decisão, atualize também o resumo de decisões vigentes em [`docs/contexto-projeto.md`](../../contexto-projeto.md#decisoes-vigentes). Essa referência é carregada pela rota de orientação do projeto e não pode contradizer o estado dos ADRs.

Uma decisão pode ser registrada como `em_analise` antes da escolha, preservando a pergunta, opções e evidências. Não a marque como `aceita` enquanto depender do grupo.

Quando uma decisão for substituída:

1. mantenha o arquivo anterior;
2. altere seu estado para `substituida` e encerre `valid_until`;
3. crie a nova decisão com uma relação `supersedes` para o ID anterior;
4. preserve resultados que validaram ou contradisseram cada decisão no período em que esteve vigente.

## Registros

- [`DEC-0001`](0001-refinamento-de-componentes.md) — ciclo de refinamento antes de quanta, aceita;
- [`DEC-0002`](0002-topologia-kubernetes.md) — três quanta Kubernetes, aceita;
- [`DEC-0003`](0003-entrega-duravel-e-persistencia.md) — aceite e entrega durável, em análise;
- [`DEC-0004`](0004-componentes-coesos-do-nucleo.md) — oito componentes do núcleo, aceita;
- [`DEC-0005`](0005-keycloak-no-ambiente-de-validacao.md) — Keycloak autocontido em Kubernetes, aceita.
