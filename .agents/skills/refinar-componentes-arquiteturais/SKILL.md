---
name: refinar-componentes-arquiteturais
description: Identifica e refatora iterativamente componentes lógicos a partir de fluxos ou atores, histórias de usuário, responsabilidades, características arquiteturais e acoplamento estático ou temporal. Use ao analisar fronteiras, granularidade, coesão, conhecimento entre componentes, quanta ou distribuição de responsabilidades; não use para simples organização de classes sem impacto arquitetural.
---

# Refinar componentes arquiteturais

Esta skill segue as [instruções compartilhadas do repositório](../../../AGENTS.md) e usa o [roteador de contexto](../../../docs/contexto/roteador.md) para selecionar as fontes do projeto.

## Objetivo

Conduzir um ciclo iterativo de identificação e reestruturação de componentes, inspirado no fluxo de pensamento baseado em componentes apresentado na 2ª edição de *Fundamentos da Arquitetura de Software*.

Um componente, neste processo, é a manifestação modular de um conjunto coeso de comportamento, com papel, responsabilidades e contrato claros. Ele pode ser implementado como pacote, módulo ou biblioteca dentro do mesmo projeto e do mesmo processo que outros componentes. Não o confunda com capacidade macro, bounded context, serviço, processo, repositório, banco de dados, quantum ou unidade de implantação.

## Reunir evidências

1. Leia as instruções do repositório e os arquivos diretamente relacionados ao escopo.
2. Reúna motivadores, requisitos, histórias de usuário, critérios de aceite, restrições e decisões existentes.
3. Classifique cada entrada como `Observada`, `Declarada`, `Decidida` ou `Inferida`. Toda inferência deve expor sua evidência e poder ser corrigida.
4. Localize as características arquiteturais já registradas, mas não as use para antecipar o inventário inicial. Elas serão analisadas somente depois da atribuição das histórias e da análise de papéis e responsabilidades.
5. Registre lacunas que possam mudar substancialmente as fronteiras. Não bloqueie a primeira iteração quando for seguro trabalhar com hipóteses explícitas.

## Executar o ciclo

Cada iteração percorre obrigatoriamente estes estados, nesta ordem:

`identificado → histórias atribuídas → responsabilidades analisadas → características analisadas → refatorado → verificado`

Regras do ciclo:

- congele o inventário depois de identificá-lo;
- não adicione, remova, una, divida ou renomeie componentes durante a atribuição ou as duas análises;
- atribua cada história integralmente a exatamente um componente responsável principal; colaboradores não compartilham essa responsabilidade;
- registre achados durante as análises, sem aplicar a solução sugerida por eles;
- altere o inventário somente em `refatorado`, ligando cada alteração a um achado anterior;
- depois da refatoração, repita atribuição e análises para o novo inventário;
- trate agrupamento em quanta e quantidade de serviços somente depois de verificar o inventário refinado; não use uma contagem-alvo para orientar a descoberta.

### 1. Identificar componentes centrais

- Parta de capacidades de negócio, mudanças que o sistema precisa acomodar e fluxos observáveis.
- Escolha uma técnica inicial e registre por que ela serve ao problema:
  - use `Workflow` para derivar candidatos dos principais fluxos felizes ou de processamento, sem criar necessariamente um componente para cada passo;
  - use `Actor/Action` quando vários atores, incluindo o próprio sistema, realizarem ações relevantes;
  - combine as duas somente quando cada uma revelar responsabilidades distintas.
- Verifique o `Entity Trap`: candidatos nomeados apenas por entidades ou concentrados em operações CRUD tendem a esconder comportamentos e virar depósitos de responsabilidades. Prefira nomes que revelem finalidade ou ação; trate sufixos vagos como `Manager`, `Handler`, `Controller`, `Engine` ou `Processor` como sinais para inspeção, não como erro automático.
- Escolha conscientemente uma estratégia inicial de particionamento, como domínio ou organização técnica, e explique o trade-off.
- Para cada candidato, registre nome orientado ao negócio quando aplicável, finalidade, evidências e fronteira inicial.
- Reaproveite componentes existentes quando forem coesos. O primeiro inventário é uma hipótese de trabalho, não um desenho definitivo.
- Não derive um componente para cada passo técnico. Derive candidatos comportamentais e deixe granularidade, coesão e características serem confrontadas nas etapas posteriores.

### 2. Atribuir histórias de usuário aos componentes

- Atribua cada história a um componente responsável principal.
- Registre colaboradores somente quando houver interação necessária e identifique o contrato esperado.
- Sinalize histórias sem responsável, com mais de um responsável principal, concentradas demais em um componente ou atravessando fronteiras sem contrato claro.
- Não duplique a mesma regra ou autoridade sobre dados entre componentes.
- Uma história pode atravessar colaboradores, mas permanece dentro de um único responsável em cada iteração.
- Vários componentes podem atuar sobre a mesma entidade quando possuem comportamentos ou transições distintos; compartilhar entidade, banco, transação local ou quantum não obriga a uni-los.

### 3. Analisar papéis e responsabilidades

Para cada componente, registre:

- papel em uma frase;
- responsabilidades que possui;
- responsabilidades que não possui;
- regras e dados sob sua autoridade;
- contratos fornecidos;
- dependências necessárias.

Revise coesão, acoplamento, granularidade e direção das dependências. Papéis vagos, puramente tecnológicos, sobrepostos ou extensos demais são achados para a etapa de refatoração; não altere o inventário enquanto os analisa.

Analise o acoplamento proporcionalmente ao risco:

- mapeie dependências aferentes e eferentes (`fan-in` e `fan-out`); conte `CA` e `CE` quando a medida ajudar a comparar alternativas, sem impor limiares universais;
- registre acoplamento temporal quando uma ordem, janela de tempo, transação ou unidade de trabalho fizer componentes mudarem ou falharem juntos;
- aplique a Lei de Deméter perguntando quanto cada componente conhece sobre colaboradores e consequências a jusante; conhecimento excessivo ou coordenação espalhada exige contrato, mediador ou redistribuição explícita;
- diferencie acoplamento necessário do domínio de acoplamento acidental de tecnologia e registre impacto em mudança, teste, falha e implantação.

### 4. Analisar características arquiteturais

- Avalie primeiro cada característica prioritária no escopo do sistema e depois registre onde ela pressiona fronteiras, contratos, dados e interações.
- Defina escopo e evidência verificável; não use termos como desempenho, segurança ou escalabilidade como justificativas genéricas.
- Explicite conflitos entre características e o custo de otimizar cada uma.
- Diferencie uma necessidade lógica de uma escolha de implantação ou tecnologia.
- Não atribua uma característica a um componente e não altere o inventário nesta etapa.

### 5. Reestruturar componentes

- Considere manter, renomear, dividir, unir, adicionar ou remover componentes.
- Justifique cada alteração com um achado registrado nas análises de responsabilidades ou características.
- Prefira a menor mudança que esclareça propriedade, reduza acoplamento relevante ou melhore coesão.
- Registre impactos em contratos, dados, dependências, operação, migração e testes.
- Não persiga uma quantidade previamente desejada de componentes ou quanta.

### 6. Repetir e verificar convergência

Após cada reestruturação, volte à atribuição das histórias e execute novamente as duas análises sem modificar o novo inventário. Compare a hipótese com a anterior e registre o que melhorou, piorou ou permaneceu incerto.

Encerre a análise quando:

- todas as histórias do escopo tiverem um responsável principal;
- os papéis forem distintos e as responsabilidades não estiverem duplicadas;
- contratos, dependências aferentes/eferentes e acoplamentos temporais relevantes estiverem explícitos;
- conhecimento excessivo entre componentes tiver sido reduzido ou justificado;
- as características prioritárias tiverem mecanismos de verificação proporcionais;
- todo componente estiver justificado por evidência do escopo.

Somente depois dessa verificação agrupe componentes em quanta candidatos. Mantenha separados o inventário de componentes, os agrupamentos de quanta e a quantidade de serviços ou processos. Uma hipótese de quantum não retroage para redefinir os componentes.

Se o ciclo não convergir, não force uma resposta definitiva. Declare quais evidências faltam, que decisões dependem do usuário e qual é o menor experimento capaz de reduzir a incerteza.

## Melhoria contínua

- Trate cada execução como uma hipótese arquitetural sujeita a feedback de implementação e operação.
- Associe riscos importantes a testes, regras de dependência, métricas, rastreamento ou revisões que funcionem como fitness functions.
- Defina sinais concretos para reabrir a decisão, como mudança de volume, novo requisito, violação de contrato ou crescimento de acoplamento.
- Registre aprendizados duráveis na fonte apropriada, evitando duplicar requisitos ou criar documentação sem responsável.

## Formato da entrega

Apresente, conforme a complexidade exigir:

1. escopo, evidências, histórias e premissas;
2. técnica de descoberta, `Entity Trap` e inventário inicial congelado;
3. matriz inicial `História | Responsável principal | Colaboradores | Observações`;
4. análise de papéis e responsabilidades, sem alterações;
5. análise das características no escopo do sistema, sem alterações;
6. tabela de refatorações, cada uma ligada ao achado que a motivou;
7. inventário refinado e nova atribuição das histórias;
8. repetição das análises, dependências e verificação de convergência;
9. agrupamentos candidatos de quanta, separados do inventário de componentes;
10. riscos, pendências, fitness functions e menor próximo incremento verificável.

Inclua referências precisas ao repositório. Quando usada por um agente somente leitura, entregue a análise sem editar arquivos.
