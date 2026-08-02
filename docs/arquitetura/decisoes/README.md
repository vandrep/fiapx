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

Uma decisão pode ser registrada como `em_analise` antes da escolha, preservando a pergunta, opções e evidências. Não a marque como `aceita` enquanto depender do grupo.

Quando uma decisão for substituída:

1. mantenha o arquivo anterior;
2. altere seu estado para `substituida` e encerre `valid_until`;
3. crie a nova decisão com uma relação `supersedes` para o ID anterior;
4. preserve resultados que validaram ou contradisseram cada decisão no período em que esteve vigente.
