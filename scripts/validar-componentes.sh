#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
component_model="$repo_root/docs/arquitetura/componentes.md"
stories="$repo_root/docs/requisitos/historias.md"

if [[ ! -e "$component_model" ]]; then
    echo "Erro: modelo corrente de componentes inexistente." >&2
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
    "## Agrupamentos candidatos de quanta"
)

previous_line=0
for heading in "${required_headings[@]}"; do
    heading_count=$(grep -Fxc "$heading" "$component_model" || true)
    if [[ $heading_count -eq 0 ]]; then
        echo "Erro: etapa ausente no ciclo de componentes: $heading" >&2
        exit 1
    fi
    if [[ $heading_count -ne 1 ]]; then
        echo "Erro: etapa duplicada no ciclo de componentes: $heading" >&2
        exit 1
    fi
    line=$(grep -Fnx "$heading" "$component_model" | cut -d: -f1)
    if [[ $line -le $previous_line ]]; then
        echo "Erro: etapas do ciclo de componentes estão fora de ordem em $heading." >&2
        exit 1
    fi
    previous_line=$line
done

if grep -Eiq 'quantum[[:space:]]+único' "$component_model"; then
    echo "Erro: o modelo corrente não deve registrar quantum único como hipótese." >&2
    exit 1
fi

expected_stories=$(sed -n '/^entities:/,/^relations:/ s/^  - \(US-[0-9][0-9]*\)$/\1/p' "$stories" | sort)

validate_assignment_section() {
    local heading=$1
    local next_heading=$2
    local section
    local assigned_stories

    section=$(awk -v start="$heading" -v finish="$next_heading" '
        $0 == start { inside = 1; next }
        $0 == finish { exit }
        inside { print }
    ' "$component_model")

    # shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
    assigned_stories=$(sed -n 's/^| `\(US-[0-9][0-9]*\)` | [^|][^|]* |.*/\1/p' <<<"$section" | sort)
    if [[ "$assigned_stories" != "$expected_stories" ]]; then
        echo "Erro: histórias sem responsável único em $heading." >&2
        exit 1
    fi
}

validate_assignment_section \
    "## Iteração 1 — Histórias atribuídas" \
    "## Iteração 1 — Papéis e responsabilidades analisados"
validate_assignment_section \
    "## Iteração 2 — Histórias atribuídas" \
    "## Iteração 2 — Papéis e responsabilidades analisados"

refactoring_section=$(awk '
    /^## Iteração 1 — Refatoração motivada$/ { inside = 1; next }
    /^## Iteração 2 — Componentes identificados$/ { exit }
    inside { print }
' "$component_model")

for component_number in $(seq -w 5 17); do
    component_id="CMP-$component_number"
    if ! grep -Fq "$component_id" <<<"$refactoring_section"; then
        echo "Erro: $component_id não possui motivação na refatoração." >&2
        exit 1
    fi
done

quantum_section=$(awk '
    /^## Agrupamentos candidatos de quanta$/ { inside = 1; next }
    inside && /^## / { exit }
    inside { print }
' "$component_model")

quantum_count=$(sed -n 's/^| \*\*[^*][^*]*\*\* |.*/x/p' <<<"$quantum_section" | wc -l)
if [[ $quantum_count -ne 4 ]]; then
    echo "Erro: esperados quatro agrupamentos candidatos de quanta; encontrados $quantum_count." >&2
    exit 1
fi

echo "Refinamento de componentes válido: ciclo ordenado, histórias atribuídas e quatro agrupamentos candidatos."
