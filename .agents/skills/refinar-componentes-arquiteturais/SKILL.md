---
name: refinar-componentes-arquiteturais
description: Identifica e refatora iterativamente componentes lógicos a partir de fluxos ou atores, histórias de usuário, responsabilidades, características arquiteturais e acoplamento estático ou temporal. Use ao analisar fronteiras, granularidade, coesão, conhecimento entre componentes, quanta ou distribuição de responsabilidades; não use para simples organização de classes sem impacto arquitetural.
---

# Refinar componentes arquiteturais

## Objetivo

Conduzir um ciclo iterativo de identificação e reestruturação de componentes, inspirado no fluxo de pensamento baseado em componentes apresentado na 2ª edição de *Fundamentos da Arquitetura de Software*.

Um componente, neste processo, é primeiro uma unidade lógica coesa, com papel, responsabilidades e contrato claros. Não o converta em serviço, processo, repositório, banco de dados ou unidade de implantação sem um motivador arquitetural explícito.

## Reunir evidências

1. Leia as instruções do repositório e os arquivos diretamente relacionados ao escopo.
2. Reúna motivadores, requisitos, histórias de usuário, critérios de aceite, restrições e decisões existentes.
3. Classifique cada entrada como `Observada`, `Declarada`, `Decidida` ou `Inferida`. Toda inferência deve expor sua evidência e poder ser corrigida.
4. Identifique as características arquiteturais prioritárias para o escopo e defina onde cada uma se aplica. Se elas não estiverem documentadas, trate a seleção inicial como hipótese.
5. Agrupe as características por escopo. Quando a tarefa incluir quanta ou implantação, registre antes do ciclo uma hipótese reversível sobre uma ou várias combinações de características e as alternativas monolítica ou distribuída que merecem análise; não trate essa hipótese como topologia decidida.
6. Registre lacunas que possam mudar substancialmente as fronteiras. Não bloqueie a primeira iteração quando for seguro trabalhar com hipóteses explícitas.

## Executar o ciclo

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

### 2. Atribuir histórias de usuário aos componentes

- Atribua cada história a um componente responsável principal.
- Registre colaboradores somente quando houver interação necessária e identifique o contrato esperado.
- Sinalize histórias sem responsável, com mais de um responsável principal, concentradas demais em um componente ou atravessando fronteiras sem contrato claro.
- Não duplique a mesma regra ou autoridade sobre dados entre componentes.

### 3. Analisar papéis e responsabilidades

Para cada componente, registre:

- papel em uma frase;
- responsabilidades que possui;
- responsabilidades que não possui;
- regras e dados sob sua autoridade;
- contratos fornecidos;
- dependências necessárias.

Revise coesão, acoplamento, granularidade e direção das dependências. Papéis vagos, puramente tecnológicos, sobrepostos ou extensos demais são sinais para reconsiderar a fronteira.

Analise o acoplamento proporcionalmente ao risco:

- mapeie dependências aferentes e eferentes (`fan-in` e `fan-out`); conte `CA` e `CE` quando a medida ajudar a comparar alternativas, sem impor limiares universais;
- registre acoplamento temporal quando uma ordem, janela de tempo, transação ou unidade de trabalho fizer componentes mudarem ou falharem juntos;
- aplique a Lei de Deméter perguntando quanto cada componente conhece sobre colaboradores e consequências a jusante; conhecimento excessivo ou coordenação espalhada exige contrato, mediador ou redistribuição explícita;
- diferencie acoplamento necessário do domínio de acoplamento acidental de tecnologia e registre impacto em mudança, teste, falha e implantação.

### 4. Analisar características arquiteturais

- Avalie como cada característica prioritária afeta as fronteiras, os contratos, os dados e as interações.
- Defina escopo e evidência verificável; não use termos como desempenho, segurança ou escalabilidade como justificativas genéricas.
- Explicite conflitos entre características e o custo de otimizar cada uma.
- Diferencie uma necessidade lógica de uma escolha de implantação ou tecnologia.

### 5. Reestruturar componentes

- Considere manter, renomear, dividir, unir, adicionar ou remover componentes.
- Justifique cada alteração com histórias, responsabilidades, características ou riscos concretos.
- Prefira a menor mudança que esclareça propriedade, reduza acoplamento relevante ou melhore coesão.
- Registre impactos em contratos, dados, dependências, operação, migração e testes.

### 6. Repetir e verificar convergência

Após cada reestruturação, volte à atribuição das histórias e execute novamente as análises. Compare a nova hipótese com a anterior e registre o que melhorou, piorou ou permaneceu incerto.

Encerre a análise quando:

- todas as histórias do escopo tiverem um responsável principal;
- os papéis forem distintos e as responsabilidades não estiverem duplicadas;
- contratos, dependências aferentes/eferentes e acoplamentos temporais relevantes estiverem explícitos;
- conhecimento excessivo entre componentes tiver sido reduzido ou justificado;
- as características prioritárias tiverem mecanismos de verificação proporcionais;
- todo componente estiver justificado por evidência do escopo.

Se o ciclo não convergir, não force uma resposta definitiva. Declare quais evidências faltam, que decisões dependem do usuário e qual é o menor experimento capaz de reduzir a incerteza.

## Melhoria contínua

- Trate cada execução como uma hipótese arquitetural sujeita a feedback de implementação e operação.
- Associe riscos importantes a testes, regras de dependência, métricas, rastreamento ou revisões que funcionem como fitness functions.
- Defina sinais concretos para reabrir a decisão, como mudança de volume, novo requisito, violação de contrato ou crescimento de acoplamento.
- Registre aprendizados duráveis na fonte apropriada, evitando duplicar requisitos ou criar documentação sem responsável.

## Formato da entrega

Apresente, conforme a complexidade exigir:

1. escopo, evidências, histórias e premissas;
2. características arquiteturais prioritárias, seu escopo e forma de verificação;
3. técnica de descoberta escolhida, verificação do `Entity Trap` e inventário inicial dos componentes;
4. matriz `História | Responsável principal | Colaboradores | Observações`;
5. tabela `Componente | Papel | Responsabilidades | Fora do escopo | Contratos/dependências`;
6. matriz `Origem | Destino | Tipo estático/temporal | CA/CE | Conhecimento | Contrato | Impacto` quando o acoplamento alterar fronteiras;
7. alterações de cada iteração e seus trade-offs;
8. inventário final, riscos, pendências, critérios de validação e sinais de revisão;
9. menor próximo incremento verificável.

Inclua referências precisas ao repositório. Quando usada por um agente somente leitura, entregue a análise sem editar arquivos.
