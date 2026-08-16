# Issue tracker: GitHub

Issues e especificações deste repositório vivem no GitHub Issues. Use o CLI `gh` em todas as operações.

## Convenções

- **Criar issue**: `gh issue create --title "..." --body "..."`. Use heredoc para corpos multilinha.
- **Ler issue**: `gh issue view <number> --comments`, filtrando comentários com `jq` e buscando também os rótulos.
- **Listar issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`, com filtros `--label` e `--state` apropriados.
- **Comentar**: `gh issue comment <number> --body "..."`
- **Adicionar/remover rótulos**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Fechar**: `gh issue close <number> --comment "..."`

Infira o repositório por `git remote -v`; o `gh` faz isso automaticamente quando executado dentro do clone.

## Pull requests como superfície de triagem

**PRs como superfície de solicitação: não.** _(Altere para `sim` se este repositório tratar PRs externos como solicitações de funcionalidade; `/triage` lê esta opção.)_

Quando configurado como `sim`, PRs passam pelos mesmos rótulos e estados das issues, usando os equivalentes `gh pr`:

- **Ler PR**: `gh pr view <number> --comments` e `gh pr diff <number>`.
- **Listar PRs externos para triagem**: `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments`; mantenha apenas `authorAssociation` igual a `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR` ou `NONE`.
- **Comentar/rotular/fechar**: `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

GitHub compartilha a numeração entre issues e PRs. Resolva um `#42` ambíguo com `gh pr view 42` e, se não for PR, use `gh issue view 42`.

## Quando uma skill disser “publish to the issue tracker”

Crie uma issue no GitHub.

## Quando uma skill disser “fetch the relevant ticket”

Execute `gh issue view <number> --comments`.

## Operações de wayfinding

Usadas por `/wayfinder`. O **mapa** é uma única issue e seus **filhos** são outras issues.

- **Mapa**: issue com o rótulo `wayfinder:map`, contendo Notes / Decisions-so-far / Fog. Crie com `gh issue create --label wayfinder:map`.
- **Ticket filho**: issue ligada ao mapa como sub-issue pela API do GitHub. Se sub-issues não estiverem habilitadas, adicione o filho à task list do mapa e inclua `Part of #<map>` no início do corpo. Use `wayfinder:<type>` (`research`, `prototype`, `grilling` ou `task`) e atribua o ticket ao desenvolvedor quando for assumido.
- **Bloqueio**: dependências nativas do GitHub. Adicione com `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`, usando o `id` numérico do bloqueador obtido por `gh api repos/<owner>/<repo>/issues/<n> --jq .id`. Se indisponível, use `Blocked by: #<n>, #<n>` no início do corpo.
- **Consulta da fronteira**: liste filhos abertos do mapa, descarte os que têm bloqueador aberto ou responsável e escolha o primeiro na ordem do mapa.
- **Assumir**: `gh issue edit <n> --add-assignee @me`; esta é a primeira escrita da sessão.
- **Resolver**: comente a resposta, feche o ticket e acrescente ao mapa, em Decisions-so-far, um ponteiro de contexto com gist e link.
