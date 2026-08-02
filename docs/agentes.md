# Agentes especializados

Este documento registra os agentes existentes e candidatos. Uma ideia permanece aqui até possuir responsabilidade distinta, entradas conhecidas, contrato de entrega e um momento claro de uso. Somente agentes ativos recebem configuração em `.codex/agents/`.

## Agentes ativos

### Arquiteto

- **Status:** ativo.
- **Papel:** analisar decisões estruturais, componentes, características arquiteturais e trade-offs.
- **Operação:** consultiva e somente leitura.
- **Configuração:** `.codex/agents/arquiteto.toml`.

## Agentes candidatos

### Especialista Java e Quarkus

- **Status:** candidato; ainda não criar.
- **Motivação:** preferência declarada por Java com Quarkus e necessidade futura de implementar o desenho escolhido com práticas adequadas ao ecossistema.
- **Gatilho de criação:** escolha de Java e Quarkus aceita em ADR e início da primeira fatia de implementação.
- **Entradas:** ADR da stack, fronteiras e contratos dos componentes, histórias e critérios de aceite do incremento.
- **Responsabilidades:** orientar ou executar estruturação do projeto Quarkus, implementação idiomática, configuração, integrações e testes no escopo delegado.
- **Fora do escopo:** escolher componentes, alterar requisitos, decidir topologia de implantação ou substituir decisões do arquiteto e do responsável pelo projeto.
- **Entrega esperada:** mudança implementada, evidências de teste, premissas, riscos e impacto em documentação ou decisões.

## Critérios para adicionar um agente

Antes de promover um candidato a agente ativo, confirme:

1. que a responsabilidade aparece de forma recorrente e não é apenas uma tarefa pontual;
2. que sua fronteira não se sobrepõe à de outro agente;
3. que existem entradas e fontes de contexto identificáveis;
4. que a saída possui critérios objetivos de qualidade;
5. que as permissões podem ser limitadas ao necessário;
6. que existe um ciclo de verificação e adaptação.
