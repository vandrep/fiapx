---
context_id: CTX-ROUTE-001
context_type: context_router
status: ativo
recorded_at: 2026-08-01
valid_from: 2026-08-01
relations:
  - type: motivated_by
    target: https://www.thoughtworks.com/pt/radar/techniques/progressive-context-disclosure
  - type: governed_by
    target: CTX-GOV-001
---

# Roteador de contexto

## Objetivo

Selecionar o menor conjunto de fontes capaz de sustentar uma tarefa. Este documento é um índice de descoberta, não um pacote para carregar todo o repositório nem uma segunda fonte de verdade.

## Procedimento de seleção

1. Leia a solicitação atual e o `AGENTS.md` aplicável.
2. Classifique a tarefa por uma rota principal da tabela abaixo.
3. Carregue apenas o contexto inicial da rota.
4. Siga no máximo uma relação por vez e somente quando houver uma pergunta ainda sem evidência.
5. Acrescente uma segunda rota apenas se a tarefa realmente atravessar os dois escopos.
6. Pare quando for possível declarar objetivo, evidências, premissas, restrições e validação.
7. Sempre que criar ou alterar metadados YAML de um nó, acrescente obrigatoriamente a rota “Manter Context Graph” antes de editar.
8. Se qualquer verificação encontrar um erro, ative também a rota “Investigar e corrigir falha”.

Se nenhuma rota servir, use os caminhos e relações deste documento para descobrir uma fonte, registre a lacuna e proponha a nova rota somente se o tipo de trabalho for recorrente.

## Rotas

| Rota e gatilho | Contexto inicial mínimo | Carregar adicionalmente somente quando |
|---|---|---|
| **Orientar o projeto** — entender objetivo, restrições ou estado corrente | [`../contexto-projeto.md`](../contexto-projeto.md) e [`../acompanhamento/roadmap.md`](../acompanhamento/roadmap.md) | O enunciado for necessário para conferir uma afirmação declarada; uma realização anterior explicar o estado atual |
| **Evoluir requisitos ou vocabulário** — histórias, critérios, termos e regras de negócio | [`../requisitos/historias.md`](../requisitos/historias.md) e [`../requisitos/glossario.md`](../requisitos/glossario.md) | O contexto do projeto for necessário para classificar a fonte; componentes forem afetados por uma mudança de autoridade; antes de uma alteração semântica, carregue [`rastreabilidade-refinamentos.md`](rastreabilidade-refinamentos.md) e somente os eventos ligados aos itens afetados |
| **Conduzir Event Storming** — eventos, comandos, políticas, atores e dúvidas do fluxo | [`../requisitos/event-storming.md`](../requisitos/event-storming.md), [`../requisitos/historias.md`](../requisitos/historias.md) e [`../requisitos/glossario.md`](../requisitos/glossario.md) | [`../arquitetura/componentes.md`](../arquitetura/componentes.md) for necessário para confrontar as fronteiras com o fluxo descoberto; não o use para limitar a descoberta inicial |
| **Refinar componentes ou delimitar quanta** — coesão, acoplamento, responsabilidades e implantação | skill `refinar-componentes-arquiteturais`, [`../requisitos/historias.md`](../requisitos/historias.md), [`../requisitos/glossario.md`](../requisitos/glossario.md), [`../arquitetura/caracteristicas.md`](../arquitetura/caracteristicas.md) e [`../arquitetura/componentes.md`](../arquitetura/componentes.md) | Uma decisão já registrada restringir uma opção; código ou medição forem necessários como evidência, e apenas nos trechos relacionados |
| **Modelar ameaças** — ativos, fronteiras de confiança, abuso e mitigação | [`../requisitos/historias.md`](../requisitos/historias.md), [`../requisitos/glossario.md`](../requisitos/glossario.md), [`../arquitetura/caracteristicas.md`](../arquitetura/caracteristicas.md) e [`../arquitetura/componentes.md`](../arquitetura/componentes.md) | Um contrato, quantum ou tecnologia aceita introduzir uma superfície concreta; carregue somente a decisão ou o código correspondente |
| **Analisar ou registrar decisão arquitetural** — escolha durável e seus trade-offs | A decisão relacionada em [`../arquitetura/decisoes/`](../arquitetura/decisoes/) ou o [_template](../arquitetura/decisoes/_template.md), mais os nós citados diretamente pela pergunta | Uma alternativa depender de evidência adicional; não leia todas as decisões por padrão |
| **Avaliar o código-base** — comportamento observado, risco de migração ou comparação | Seção “Estado observado” de [`../contexto-projeto.md`](../contexto-projeto.md) e somente os arquivos necessários em `../referencia/projeto-original/` | O ZIP for necessário para verificar integridade ou divergência; o enunciado for necessário para comparar expectativa e comportamento |
| **Implementar ou testar** — alterar uma fatia já decidida | História e critérios do incremento, ADRs vigentes, contratos do quantum e arquivos de código diretamente afetados | Uma falha apontar para dependência adjacente; o código-base Go não é contexto padrão para uma implementação Java nova |
| **Criar ou revisar agente/skill** — responsabilidade, contrato e permissão | [`../agentes.md`](../agentes.md), configuração ou skill específica e as regras compartilhadas | Contexto do projeto for indispensável para testar o agente; mantenha-o fora das instruções reutilizáveis |
| **Manter Context Graph** — IDs, relações, validade ou procedência | [`README.md`](README.md), arquivos com metadados alterados e [`../../scripts/validar-contexto.sh`](../../scripts/validar-contexto.sh) | Uma relação precisar ser resolvida; não percorra o grafo inteiro sem uma pergunta concreta |
| **Acompanhar trabalho** — incluir, atualizar ou concluir uma iniciativa | [`../acompanhamento/roadmap.md`](../acompanhamento/roadmap.md) | [`../acompanhamento/realizacoes.md`](../acompanhamento/realizacoes.md) apenas para migrar uma conclusão, evitar repetição ou recuperar aprendizado anterior |
| **Investigar e corrigir falha** — qualquer teste, inspeção ou revisão encontrou um erro | Evidência da falha, artefato diretamente afetado e [`meta-pdca.md`](meta-pdca.md) | A revisão identificar uma diretiva, rota, skill, template, contrato ou verificação causalmente relacionada; carregue somente essa fonte de processo |

## Limites de carregamento

Não são contexto padrão de nenhuma tarefa:

- o enunciado completo, quando uma fonte derivada já basta;
- o projeto-base inteiro ou seu arquivo ZIP;
- todas as decisões arquiteturais;
- todos os artefatos referenciados transitivamente;
- o histórico completo de realizações;
- documentos de uma tecnologia ainda não escolhida.

Uma relação no Context Graph indica que a fonte pode ser relevante; não determina que ela deva ser carregada. A pergunta da tarefa e a lacuna de evidência determinam a travessia.

## Manutenção

- Adicione uma rota somente para um padrão recorrente de trabalho com pacote inicial distinto.
- Mantenha cada rota orientada a uma pergunta, não a um agente ou ferramenta específica.
- Substitua caminhos quando a fonte de verdade mudar; não copie seu conteúdo para cá.
- Revise rotas que carreguem muitos documentos ou que frequentemente tragam contexto sem uso.
- Quando uma tarefa produzir aprendizado durável, atualize a fonte apropriada, não este índice.
