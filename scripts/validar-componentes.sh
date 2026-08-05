#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
component_model="$repo_root/docs/arquitetura/componentes-coesos.md"
component_evidence="$repo_root/docs/arquitetura/historico/componentes/ctx-cmp-003-refinamento.md"
historical_component_model="$repo_root/docs/arquitetura/historico/componentes/ctx-cmp-002-componentes-modulares.md"
macro_component_model="$repo_root/docs/arquitetura/historico/componentes/ctx-cmp-001-componentes-macro.md"
stories="$repo_root/docs/requisitos/historias.md"
characteristics="$repo_root/docs/arquitetura/caracteristicas.md"
component_decision="$repo_root/docs/arquitetura/decisoes/0001-refinamento-de-componentes.md"
topology_decision="$repo_root/docs/arquitetura/decisoes/0002-topologia-kubernetes.md"
glossary="$repo_root/docs/requisitos/glossario.md"
outcome_log="$repo_root/docs/acompanhamento/realizacoes.md"
roadmap="$repo_root/docs/acompanhamento/roadmap.md"

for document in "$component_model" "$component_evidence" "$historical_component_model" "$macro_component_model" "$stories" "$characteristics" "$component_decision" "$topology_decision" "$glossary" "$outcome_log" "$roadmap"; do
    if [[ ! -e "$document" ]]; then
        echo "Erro: artefato necessário à validação de componentes inexistente: ${document#"$repo_root/"}." >&2
        exit 1
    fi
done

# shellcheck disable=SC2016 # Backticks são literais Markdown.
historical_model_guardrails=(
    'status: substituido'
    'valid_until: 2026-08-03'
    '## Riscos, fitness functions e próximo incremento então proposto'
    'Na verificação de 2026-08-02, o inventário modular convergia'
    'Em 2026-08-03, ele foi substituído pelo [`CTX-CMP-003`](../../componentes-coesos.md)'
    'Em 2026-08-02, o incremento seguinte proposto era o Threat Modeling de [`WORK-011`](../../../acompanhamento/roadmap.md#work-011--executar-threat-modeling-inicial).'
    'O [roadmap ativo](../../../acompanhamento/roadmap.md) e o [`CTX-CMP-003`](../../componentes-coesos.md) contêm a orientação vigente.'
)
for guardrail in "${historical_model_guardrails[@]}"; do
    if ! grep -Fq "$guardrail" "$historical_component_model"; then
        echo "Erro: CTX-CMP-002 perdeu a qualificação temporal: $guardrail" >&2
        exit 1
    fi
done

# shellcheck disable=SC2016 # Backticks são literais Markdown.
macro_model_guardrails=(
    'status: substituido'
    'valid_until: 2026-08-02'
    'o modelo ativo é [`CTX-CMP-003`](../../componentes-coesos.md)'
    '“corrente” significa vigente na iteração registrada em 2026-08-01'
    '## Diagrama lógico do modelo então corrente (`CTX-CMP-001`)'
    'Como este nó hoje está `substituido`, evidência nova deve alimentar um novo refinamento ou nó sucessor ligado ao [`CTX-CMP-003`](../../componentes-coesos.md)'
    '## Menor próximo incremento proposto naquele estágio'
    'A sequência vigente pertence ao [roadmap ativo](../../../acompanhamento/roadmap.md).'
)
for guardrail in "${macro_model_guardrails[@]}"; do
    if ! grep -Fq "$guardrail" "$macro_component_model"; then
        echo "Erro: CTX-CMP-001 perdeu a qualificação temporal: $guardrail" >&2
        exit 1
    fi
done

# shellcheck disable=SC2016 # Backticks são literais Markdown.
if grep -Fq 'Seu estado permanece `em_analise`' "$macro_component_model" \
    || grep -Fq 'Reabra este refinamento' "$macro_component_model" \
    || grep -Fq 'Ele permanece `em_analise`' "$historical_component_model" \
    || grep -Fq 'O próximo incremento é o Threat Modeling' "$historical_component_model"; then
    echo "Erro: um modelo substituído voltou a se apresentar como orientação vigente." >&2
    exit 1
fi

# shellcheck disable=SC2016 # Backticks são literais Markdown.
if ! grep -Fq 'o modelo então vigente [`CTX-CMP-001`](../arquitetura/historico/componentes/ctx-cmp-001-componentes-macro.md) ganhou' "$outcome_log" \
    || grep -Fq 'o modelo corrente ganhou uma representação Mermaid' "$outcome_log"; then
    echo "Erro: WORK-004 perdeu a qualificação temporal de sua realização." >&2
    exit 1
fi

# shellcheck disable=SC2016 # Backticks são literais Markdown.
temporal_guardrails=(
    '## Registro histórico do agrupamento preliminar por escopo'
    'modelo então corrente (`CTX-CMP-002`)'
    'o [modelo ativo `CTX-CMP-003`](componentes-coesos.md) consolida oito componentes'
)
for guardrail in "${temporal_guardrails[@]}"; do
    if ! grep -Fq "$guardrail" "$characteristics"; then
        echo "Erro: características perderam a qualificação temporal do modelo substituído: $guardrail" >&2
        exit 1
    fi
done

state_definition=$(grep -F '| Estado do trabalho |' "$glossary" || true)
if [[ "$state_definition" != *'componentes-coesos.md#cmp-20'* \
    || "$state_definition" != *'é a única autoridade e o único escritor do estado'* \
    || "$state_definition" == *'É autoridade de Trabalhos de Vídeo'* ]]; then
    echo "Erro: glossário diverge da autoridade vigente de CMP-20 sobre o estado do trabalho." >&2
    exit 1
fi

credential_definition=$(grep -F '| Credencial |' "$glossary" || true)
# shellcheck disable=SC2016 # Backticks são literais Markdown.
if [[ "$credential_definition" != *'0005-keycloak-no-ambiente-de-validacao.md'* \
    || "$credential_definition" != *'refinamentos/REQ-CHG-0002.md'* \
    || "$credential_definition" != *'atribui contas e autenticação por senha ao Keycloak'* \
    || "$credential_definition" != *'a aplicação não recebe a senha, valida o token OIDC e obtém `(issuer, subject)`'* \
    || "$credential_definition" != *'a direção de autogestão está validada'* \
    || "$credential_definition" == *'armazenamento e recuperação ainda não foram definidos'* ]]; then
    echo "Erro: glossário diverge da realização técnica de credenciais aceita em DEC-0005." >&2
    exit 1
fi

# O modelo ativo aponta para a autoridade sem copiar um WORK-* ou uma próxima ação móvel.
if ! grep -Fq '[roadmap ativo](../acompanhamento/roadmap.md)' "$component_model"; then
    echo "Erro: modelo de componentes não aponta para o roadmap que governa o próximo trabalho." >&2
    exit 1
fi
if grep -Eq '^## .*([Pp]róximo trabalho|[Pp]róximo incremento)|O (menor )?próximo (trabalho|incremento) (é|será)' "$component_model"; then
    echo "Erro: modelo de componentes voltou a copiar uma orientação dinâmica do roadmap." >&2
    exit 1
fi

if ! grep -Fq 'evoluiu com o modelo ativo e hoje aplica as mesmas salvaguardas' "$component_decision" \
    || grep -Fq 'presença de quatro agrupamentos apenas candidatos' "$component_decision"; then
    echo "Erro: DEC-0001 descreve uma versão histórica do validador como se ainda fosse corrente." >&2
    exit 1
fi

required_headings=(
    "## Iteração 1 — Componentes identificados"
    "## Iteração 1 — Histórias atribuídas"
    "## Iteração 1 — Papéis e responsabilidades analisados"
    "## Iteração 1 — Características do sistema analisadas"
    "## Iteração 1 — Refatoração motivada"
    "## Iteração 2 — Componentes identificados"
    "## Iteração 2 — Histórias atribuídas"
    "## Iteração 2 — Papéis e responsabilidades analisados"
    "## Iteração 2 — Características do sistema analisadas"
    "## Iteração 2 — Verificação de convergência"
)

previous_line=0
for heading in "${required_headings[@]}"; do
    heading_count=$(grep -Fxc "$heading" "$component_evidence" || true)
    if [[ $heading_count -eq 0 ]]; then
        echo "Erro: etapa ausente no ciclo de componentes: $heading" >&2
        exit 1
    fi
    if [[ $heading_count -ne 1 ]]; then
        echo "Erro: etapa duplicada no ciclo de componentes: $heading" >&2
        exit 1
    fi
    line=$(grep -Fnx "$heading" "$component_evidence" | cut -d: -f1)
    if [[ $line -le $previous_line ]]; then
        echo "Erro: etapas do ciclo de componentes estão fora de ordem em $heading." >&2
        exit 1
    fi
    previous_line=$line
done

expected_stories=$(sed -n '/^entities:/,/^relations:/ s/^  - \(US-[0-9][0-9]*\)$/\1/p' "$stories" | sort)

validate_assignment_section() {
    local document=$1
    local heading=$2
    local next_heading=$3
    local section
    local assigned_stories

    section=$(awk -v start="$heading" -v finish="$next_heading" '
        $0 == start { inside = 1; next }
        $0 == finish { exit }
        inside { print }
    ' "$document")

    # shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
    assigned_stories=$(sed -n 's/^| `\(US-[0-9][0-9]*\)` | [^|][^|]* |.*/\1/p' <<<"$section" | sort)
    if [[ "$assigned_stories" != "$expected_stories" ]]; then
        echo "Erro: histórias sem responsável principal único em $heading." >&2
        diff -u <(printf '%s\n' "$expected_stories") <(printf '%s\n' "$assigned_stories") >&2 || true
        exit 1
    fi
}

validate_assignment_section \
    "$component_evidence" \
    "## Iteração 1 — Histórias atribuídas" \
    "## Iteração 1 — Papéis e responsabilidades analisados"
validate_assignment_section \
    "$component_evidence" \
    "## Iteração 2 — Histórias atribuídas" \
    "## Iteração 2 — Papéis e responsabilidades analisados"
validate_assignment_section \
    "$component_model" \
    "## Histórias atribuídas" \
    "## Autoridades e verificação lógica"

expected_components=$(printf 'CMP-%s\n' {18..25})
metadata_components=$(sed -n '/^entities:/,/^relations:/ s/^  - \(CMP-[0-9][0-9]*\)$/\1/p' "$component_model" | sort)
documented_components=$(sed -n 's/^### \(CMP-[0-9][0-9]*\) —.*/\1/p' "$component_model" | sort)
evidence_entity_components=$(sed -n '/^entities:/,/^relations:/ s/^  - \(CMP-[0-9][0-9]*\)$/\1/p' "$component_evidence" | sort)

if [[ "$metadata_components" != "$expected_components" || "$documented_components" != "$expected_components" ]]; then
    echo "Erro: metadados e inventário do modelo ativo devem conter exatamente CMP-18..25." >&2
    diff -u <(printf '%s\n' "$expected_components") <(printf '%s\n' "$metadata_components") >&2 || true
    diff -u <(printf '%s\n' "$expected_components") <(printf '%s\n' "$documented_components") >&2 || true
    exit 1
fi

if [[ -n "$evidence_entity_components" ]]; then
    echo "Erro: a evidência histórica não pode declarar entidades CMP-*; essa autoridade pertence ao modelo ativo." >&2
    exit 1
fi

if grep -Eq '^## Iteração [12] —' "$component_model"; then
    echo "Erro: o modelo ativo voltou a incorporar etapas cuja autoridade é a evidência histórica." >&2
    exit 1
fi

refactoring_section=$(awk '
    /^## Iteração 1 — Refatoração motivada$/ { inside = 1; next }
    /^## Iteração 2 — Componentes identificados$/ { exit }
    inside { print }
' "$component_evidence")

while IFS= read -r component_id; do
    [[ -z "$component_id" ]] && continue
    if ! grep -Fq "$component_id" <<<"$refactoring_section"; then
        echo "Erro: $component_id não possui motivação na refatoração." >&2
        exit 1
    fi
done <<<"$expected_components"

assignment_section=$(awk '
    /^## Histórias atribuídas$/ { inside = 1; next }
    inside && /^## / { exit }
    inside { print }
' "$component_model")

expected_assignments=(
    'US-01 CMP-18'
    'US-02 CMP-19'
    'US-03 CMP-21'
    'US-04 CMP-20'
    'US-05 CMP-23'
    'US-06 CMP-24'
    'US-07 CMP-25'
)

for assignment in "${expected_assignments[@]}"; do
    read -r story_id component_id <<<"$assignment"
    row_count=$(grep -Fc "| \`$story_id\` |" <<<"$assignment_section" || true)
    row=$(grep -F "| \`$story_id\` |" <<<"$assignment_section" || true)
    principal=$(awk -F '|' '{ print $3 }' <<<"$row")
    principal_components=$(grep -oE 'CMP-[0-9][0-9]*' <<<"$principal" | sort -u || true)
    if [[ $row_count -ne 1 || "$principal_components" != "$component_id" ]]; then
        echo "Erro: atribuição final de $story_id deve ter somente $component_id como responsável principal." >&2
        exit 1
    fi
done

contract_section=$(awk '
    /^## Dependências e contratos conceituais$/ { inside = 1; next }
    inside && /^## / { exit }
    inside { print }
' "$component_model")

# shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
required_contracts=(
    '`IdentidadeAutenticada(issuer, subject)`'
    '`AceitarTrabalho`'
    '`ProcessarTentativa`'
    'a identidade permite execução idempotente'
    'imagens completas e referências opacas'
    'a mesma tentativa não cria dois resultados visíveis'
    'fatos ou falhas técnicas correlacionadas'
    'fatos autossuficientes'
    'falha persistida e sanitizada'
)
for contract in "${required_contracts[@]}"; do
    if ! grep -Fq "$contract" <<<"$contract_section"; then
        echo "Erro: contrato ou restrição ausente do modelo ativo: $contract" >&2
        exit 1
    fi
done

while IFS= read -r component_id; do
    component_section=$(awk -v start="### $component_id —" '
        index($0, start) == 1 { inside = 1; next }
        inside && (/^### CMP-/ || /^## /) { exit }
        inside { print }
    ' "$component_model")
    if ! grep -Fq -- '- **Fornece:**' <<<"$component_section"; then
        echo "Erro: $component_id não explicita o contrato que fornece no modelo ativo." >&2
        exit 1
    fi
done <<<"$expected_components"

topology_section=$(awk '
    /^## Decisão$/ { inside = 1; next }
    inside && /^## / { exit }
    inside { print }
' "$topology_decision")

quantum_count=$(grep -Ec '^\| (Gestão de Trabalhos de Vídeo|Produção de Resultados|Comunicação de Falhas) \|' <<<"$topology_section" || true)
topology_row_count=$(awk '
    /^\| Quantum \| Deployment \|/ { in_table = 1; next }
    in_table && /^\|---/ { next }
    in_table && /^\|/ { count++; next }
    in_table { exit }
    END { print count + 0 }
' <<<"$topology_section")
if [[ $quantum_count -ne 3 || $topology_row_count -ne 3 ]]; then
    echo "Erro: DEC-0002 deve decidir exatamente os três quanta esperados; encontrados $topology_row_count registros." >&2
    exit 1
fi

# shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
required_topology_rows=(
    '| Gestão de Trabalhos de Vídeo | `gestao-trabalhos` |'
    '| Produção de Resultados | `producao-resultados` |'
    '| Comunicação de Falhas | `notificador` |'
)

for topology_row in "${required_topology_rows[@]}"; do
    if ! grep -Fq "$topology_row" <<<"$topology_section"; then
        echo "Erro: quantum e Deployment decididos ausentes de DEC-0002: $topology_row" >&2
        exit 1
    fi
done

if grep -Eq '^\|.*Keycloak.*\|$' <<<"$topology_section"; then
    echo "Erro: DEC-0002 contou Keycloak como quantum da aplicação." >&2
    exit 1
fi

# shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
required_authorities=(
    'Keycloak autentica credenciais e emite tokens.'
    'este componente não fornece um `ExigirProprietario` genérico.'
    'Submissão nunca aciona Processamento nem Comunicação de Falhas'
    'É a única autoridade e o único escritor do estado do trabalho.'
    'não a classifica como transitória/permanente para o negócio'
    '`CMP-21` trata a mesma identidade de forma idempotente'
    '`CMP-22` não publica um segundo resultado visível para ela'
    '`CMP-21/22` relatam falha técnica; somente `CMP-20` decide política e estado'
    '`CMP-22` escreve a manifestação durável; `CMP-24` autoriza e entrega'
    'registra o resultado da entrega sem alterar o trabalho.'
    'não é componente, quantum nem serviço de negócio do FIAP X.'
)

for authority in "${required_authorities[@]}"; do
    if ! grep -Fq "$authority" "$component_model"; then
        echo "Erro: autoridade ou salvaguarda arquitetural ausente: $authority" >&2
        exit 1
    fi
done

echo "Componentes válidos: ciclo preservado na evidência, 7 histórias atribuídas, CMP-18..25 e contratos no modelo ativo, 3 quanta em DEC-0002."
