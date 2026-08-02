# Instruções operacionais do Codex

Use `AGENTS.md` como fonte principal de regras compartilhadas e `docs/contexto-projeto.md` apenas quando a tarefa exigir contexto específico deste projeto.

## Agentes especializados

- `arquiteto`: consultor somente leitura para análise estrutural e decisões arquiteturais.
- Consulte `docs/agentes.md` para o registro de agentes ativos, candidatos e seus gatilhos de criação.
- Novos agentes devem ter responsabilidade estreita, permissões mínimas e contrato de entrega explícito.
- Mantenha instruções reutilizáveis em `.codex/agents/` e conhecimento específico do projeto em `docs/`.

## Operação

- Antes de editar, inspecione `git status --short` e preserve mudanças fora do escopo.
- Não faça commit, push, publicação ou alteração em serviços externos sem solicitação explícita.
- Use comandos de validação proporcionais à mudança e relate qualquer verificação que não tenha sido possível executar.
