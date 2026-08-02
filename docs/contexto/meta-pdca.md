---
context_id: CTX-GOV-002
context_type: policy
status: ativo
recorded_at: 2026-08-01
valid_from: 2026-08-01
relations:
  - type: refines
    target: CTX-GOV-001
  - type: informs
    target: CTX-ROADMAP-001
---

# Meta-PDCA para erros e falhas de processo

## Objetivo

Impedir que a correção de um erro trate somente seu efeito imediato. Toda falha encontrada ativa dois ciclos conectados:

1. o ciclo do produto ou artefato identifica a origem, corrige o problema e comprova o comportamento esperado;
2. o ciclo do processo identifica por que a falha não foi prevenida ou detectada antes, corrige o controle causalmente relacionado e comprova que ele passa a atuar.

“Erro” inclui defeito de código, documentação inconsistente, metadado inválido, requisito interpretado incorretamente, decisão sem evidência, contexto indevido, violação de contrato, teste falho ou resultado de agente que não cumpra sua entrega. Uma incerteza explicitamente marcada ou uma hipótese ainda não validada não é, por si só, um erro.

## Ciclo obrigatório

### 1. Preparar

- Declare o comportamento esperado e a evidência que demonstrará a correção.
- Preserve mensagem, entrada, comando, trecho ou condição suficiente para reproduzir a falha sem expor dados sensíveis.
- Avalie impacto e contenha efeitos adicionais quando necessário.

### 2. Corrigir o produto ou artefato

- Reproduza ou demonstre a inconsistência.
- Localize a causa, diferenciando-a do sintoma observado.
- Faça a menor correção coerente com o objetivo e com as decisões vigentes.
- Execute novamente a verificação original e uma regressão proporcional ao risco.

### 3. Revisar o processo

Encontre o primeiro ponto em que a falha poderia ter sido evitada ou descoberta com custo razoável. Examine, nesta ordem:

1. diretiva ausente, ambígua, contraditória ou difícil de descobrir;
2. contexto necessário ausente ou contexto irrelevante carregado pela rota;
3. passo ausente em skill, template, checklist ou contrato de agente;
4. responsabilidade ou condição de entrega mal delimitada;
5. verificação inexistente, tardia ou incapaz de detectar a classe de erro;
6. aprendizado anterior que não chegou à fonte apropriada.

Não presuma que toda falha exige mais texto em `AGENTS.md`. Altere o controle mais próximo e reutilizável:

| Causa processual | Correção preferida |
|---|---|
| Regra transversal ausente | `AGENTS.md` ou política compartilhada |
| Contexto não descoberto ou carregado em excesso | Roteador de contexto |
| Erro recorrente de uma atividade especializada | Skill correspondente |
| Campo ou raciocínio frequentemente omitido | Template do artefato |
| Saída incompleta ou responsabilidade ambígua | Contrato/configuração do agente |
| Condição objetivamente verificável | Teste, linter, script ou fitness function |
| Caso local sem padrão reutilizável | Correção local e teste de regressão; não ampliar instruções globais |

### 4. Verificar o processo

- Reaplique o controle à entrada ou cenário que originou a falha.
- Faça o teste contrafactual: se a correção processual existisse antes, ela teria prevenido ou sinalizado o erro em tempo útil?
- Confirme que a nova orientação não contradiz regras existentes nem exige contexto desnecessário.
- Quando automatizável, provoque uma versão segura da falha e confirme que o controle a rejeita.

### 5. Adaptar e registrar

- Atualize a fonte de verdade mais próxima; evite duplicar a mesma regra.
- Registre o aprendizado no item concluído quando ele for relevante para trabalhos futuros.
- Use ADR próprio se a correção envolver escolha arquitetural durável.
- Crie evidência ou resultado independente no Context Graph somente quando procedência, validade ou relações precisarem sobreviver ao item de trabalho.

## Evidência mínima de encerramento

Quando um erro tiver sido encontrado, a entrega deve permitir responder:

| Pergunta | Evidência esperada |
|---|---|
| O que falhou e qual foi o impacto? | Sintoma e escopo delimitados |
| Qual era a causa do erro? | Explicação sustentada por reprodução, inspeção ou medição |
| O que corrigiu o artefato? | Mudança e validação original executada novamente |
| Por que o processo permitiu a falha? | Diretiva, contexto, atividade, responsabilidade ou controle causal identificado |
| O que foi corrigido no processo? | Fonte de orientação ou verificação alterada |
| Como sabemos que a recorrência será prevenida ou detectada? | Teste contrafactual, regressão ou controle automatizado executado |

Se nenhum erro for encontrado, registre apenas que a revisão foi realizada; não invente uma lacuna processual nem produza retrospectiva sem aprendizado.

## Limites

- Não substitua análise de causa por atribuição de culpa a uma pessoa ou agente.
- Não transforme correlação em causa processual sem evidência.
- Não amplie instruções para cobrir possibilidades abstratas que ainda não ocorreram nem representam risco concreto.
- Não permita que a revisão processual bloqueie contenção ou correção urgente; complete-a logo após estabilizar o artefato.
- Não marque um item como concluído enquanto uma correção processual causal conhecida permanecer pendente.
