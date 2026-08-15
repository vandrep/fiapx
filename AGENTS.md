# Instruções compartilhadas para agentes

Estas regras se aplicam a qualquer agente que trabalhe neste repositório. Instruções mais específicas podem complementar este arquivo, mas não devem duplicar nem contradizer suas regras.

## Princípios de trabalho

- Comece pelo objetivo do usuário, pelas evidências disponíveis e pelas restrições reais.
- Diferencie explicitamente fatos observados, requisitos declarados, decisões registradas, hipóteses e recomendações.
- Faça mudanças pequenas, verificáveis e reversíveis. Não transforme possibilidades futuras em requisitos atuais.
- Trate toda decisão relevante como um trade-off. Registre benefícios, custos, riscos e condições que justificariam revisá-la.
- Preserve alterações existentes que não pertençam à tarefa atual.
- Não exponha segredos, credenciais, dados pessoais ou arquivos de usuários em código, logs, testes ou documentação.

## Curadoria de contexto

Leia somente o contexto necessário para a tarefa, nesta ordem:

1. a solicitação atual do usuário;
2. este `AGENTS.md`;
3. o `docs/contexto/roteador.md`, para selecionar o menor pacote de contexto aplicável;
4. os arquivos indicados pela rota escolhida e diretamente relacionados ao escopo;
5. relações adicionais somente quando uma lacuna concreta exigir segui-las.

Use [`ARCHITECTURE.md`](ARCHITECTURE.md) como mapa para visão sistêmica, limites ou topologia; não é leitura obrigatória para tarefas sem impacto arquitetural. Aprofunde somente nas fontes que ele e o roteador indicarem.

Não copie o enunciado, o contexto do projeto ou detalhes da stack para instruções de agentes reutilizáveis. Prefira referências precisas a uma segunda fonte de verdade. Ao encontrar divergências entre documentação e implementação, registre ambas e trate o comportamento verificado como evidência, não como decisão automática.

Não carregue por padrão o enunciado, todo o código-base, toda a arquitetura, todas as decisões ou o histórico. Pare quando houver contexto suficiente para formular o objetivo, separar fatos de hipóteses e validar a entrega.

Artefatos contextuais e decisões seguem `docs/contexto/README.md`. Preserve IDs, procedência e validade: encerre o que deixou de valer ou conecte um sucessor; não apague nem reescreva o raciocínio anterior.

Em Markdown, ligue a primeira referência útil a outro trabalho, nó, decisão, evidência ou seção, preservando o ID ou nome visível. Em YAML, mantenha o alvo como ID, caminho ou URI exigido pelo Context Graph; links no corpo não substituem relações estruturadas.

## Melhoria contínua

Todo fluxo de trabalho deve conter um ciclo de feedback proporcional ao risco:

1. **Preparar:** defina resultado esperado, evidências, premissas, riscos e uma forma de validação.
2. **Executar:** entregue o menor incremento que produza aprendizado ou valor verificável.
3. **Verificar:** execute testes, inspeções ou medições adequadas e compare o resultado com o objetivo.
4. **Adaptar:** corrija o que falhou, registre o aprendizado durável no artefato apropriado e indique o próximo incremento.

Sempre que a verificação revelar um erro, execute também o [Meta-PDCA](docs/contexto/meta-pdca.md): identifique por que o processo não preveniu ou não detectou a falha antes, corrija a diretiva, rota, skill, template, contrato ou mecanismo de validação causalmente relacionado e verifique essa correção. Não encerre o trabalho apenas com a correção do artefato defeituoso.

Não crie uma regra global para cada erro isolado. Corrija a fonte de orientação mais próxima e reutilizável; prefira uma verificação automatizada quando ela puder detectar objetivamente a recorrência.

Não crie documentação de retrospectiva para mudanças triviais. Atualize o contexto compartilhado apenas quando o aprendizado for factual, relevante para trabalhos futuros e ainda não estiver registrado.

## Colaboração entre agentes

- Delegue apenas tarefas com objetivo, escopo, entradas e formato de saída claros.
- Um agente especializado deve receber o menor contexto suficiente e devolver: conclusão, evidências, premissas, riscos, pendências, erros encontrados, resultado da revisão Meta-PDCA e próximo passo recomendado.
- O agente principal integra os resultados, resolve conflitos e é responsável pela resposta final.
- Agentes consultivos não editam arquivos. Agentes executores só alteram o escopo explicitamente delegado.
- Não aceite recomendações de outro agente sem confrontá-las com as evidências do repositório.
- Consulte o agente `analista-negocio` antes de alterar semanticamente histórias de usuário ou o vocabulário do domínio. Ele prepara propostas e perguntas; somente o responsável pelo produto confirma necessidade, prioridade ou aceite.

## Arquitetura e decisões

- Consulte o agente `arquiteto` para decisões estruturais, fronteiras de componentes, características arquiteturais ou trade-offs com efeitos amplos.
- Use a skill `refinar-componentes-arquiteturais` quando a tarefa envolver identificação, divisão, união, responsabilidade ou fronteira de componentes.
- Não confunda componente lógico com microsserviço, processo, repositório, banco de dados ou unidade de implantação.
- Decisões arquiteturais com consequência durável ou difíceis de reverter devem ser registradas como nós independentes em `docs/arquitetura/decisoes/`, inclusive enquanto estiverem `em_analise` quando isso preservar opções e evidências relevantes.

## Validação e entrega

- Valide o comportamento com comandos reais sempre que possível.
- Para documentação, verifique links locais, caminhos citados, estrutura e ausência de contradições evidentes.
- Para artefatos com metadados de contexto, execute `scripts/validar-contexto.sh`.
- Para código, execute os testes e verificações relevantes ao escopo. Se ainda não existirem, declare a lacuna e proponha o menor mecanismo de verificação adequado.
- Se uma validação falhar, preserve a evidência, corrija a causa no produto e no processo e execute novamente tanto a validação original quanto a prevenção ou detecção acrescentada.
- Na entrega, informe o que mudou, como foi validado, limitações conhecidas e o próximo passo somente quando ele for útil.

## Métricas da execução

- O recibo pós-execução do runtime é a autoridade sobre tempo e tokens do agente principal; o modelo não deve estimar, repetir nem somar esses valores por conta própria.
- Na entrega, relate somente tempos observados de etapas, validações, tentativas, retrabalho e processos Codex filhos que não pertençam ao recibo do agente principal, sempre com a origem da medição.
- Separe métricas do agente principal das pertencentes a processos Codex filhos; nunca as some nem atribua implicitamente umas às outras.
- Se o runtime não anexar o recibo, registre o estado `não instrumentado` ou a telemetria `não disponível`; nunca estime tokens pela duração nem substitua o recibo pelo uso de um único turno.
