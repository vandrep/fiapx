#!/usr/bin/env bash

set -euo pipefail

validation_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
package_root=$(cd "$validation_dir/.." && pwd)

expected_files=(
    README.md
    historias.md
    componentes.md
    diagramas.md
    comparacao-com-modelo-atual.md
    historico-decisoes-e-sugestoes.md
    caracteristicas-e-quanta.md
    acompanhamento/roadmap.md
    acompanhamento/historico.md
    validacao/matriz-de-preservacao.md
    validacao/validar-pacote.sh
)

for relative_path in "${expected_files[@]}"; do
    if [[ ! -e "$package_root/$relative_path" ]]; then
        echo "Erro: artefato esperado inexistente: $relative_path" >&2
        exit 1
    fi
done

stories="$package_root/historias.md"
components="$package_root/componentes.md"
roadmap="$package_root/acompanhamento/roadmap.md"

story_ids=$(sed -n 's/^### \(R6-US-[0-9][0-9]\) —.*/\1/p' "$stories" | sort)
story_count=$(wc -l <<<"$story_ids")
if [[ $story_count -ne 10 ]]; then
    echo "Erro: esperadas 10 histórias; encontradas $story_count." >&2
    exit 1
fi

component_ids=$(sed -n 's/^### \(R6-CMP-[0-9][0-9]\) —.*/\1/p' "$components" | sort)
component_count=$(wc -l <<<"$component_ids")
if [[ $component_count -ne 6 ]]; then
    echo "Erro: esperados 6 componentes; encontrados $component_count." >&2
    exit 1
fi

assignment_section=$(awk '
    /^## Atribuição final das histórias$/ { inside = 1; next }
    inside && /^## / { exit }
    inside { print }
' "$components")

# shellcheck disable=SC2016 # Backticks are Markdown literals, not shell expansions.
assigned_stories=$(sed -n 's/^| \[`\(R6-US-[0-9][0-9]\)`\].*/\1/p' <<<"$assignment_section" | sort)
if [[ "$story_ids" != "$assigned_stories" ]]; then
    echo "Erro: histórias e responsáveis principais divergem." >&2
    diff -u <(printf '%s\n' "$story_ids") <(printf '%s\n' "$assigned_stories") >&2 || true
    exit 1
fi

for component_id in $component_ids; do
    if ! grep -Fq "[\`$component_id\`](#" <<<"$assignment_section"; then
        echo "Erro: componente sem história principal: $component_id" >&2
        exit 1
    fi
done

if ! grep -Fqx -- '- ZIP pertence à entrega, não ao processamento;' "$components"; then
    echo "Erro: a fronteira do ZIP não está preservada na convergência." >&2
    exit 1
fi

if ! grep -Fqx -- '- não há conceito de tentativa ou retentativa automática no modelo atual da proposta;' "$components"; then
    echo "Erro: a retirada de tentativas não está preservada na convergência." >&2
    exit 1
fi

declared_work=$(sed -n '/^entities:$/,/^relations:$/ s/^  - \(R6-WORK-[0-9][0-9]\)$/\1/p' "$roadmap" | sort)
documented_work=$(sed -n 's/^### \(R6-WORK-[0-9][0-9]\) —.*/\1/p' "$roadmap" | sort)
if [[ "$declared_work" != "$documented_work" ]]; then
    echo "Erro: entities e seções R6-WORK divergem no roadmap local." >&2
    exit 1
fi

# shellcheck disable=SC2016 # Backticks are Markdown literals, not shell expansions.
if grep -Fq '**Estado:** `concluido`' "$roadmap"; then
    echo "Erro: o roadmap local ativo contém item concluído." >&2
    exit 1
fi

while IFS= read -r -d '' document; do
    mermaid_open=0
    while IFS= read -r line; do
        if [[ "$line" == '```mermaid' ]]; then
            if [[ $mermaid_open -eq 1 ]]; then
                echo "Erro: bloco Mermaid aninhado em ${document#"$package_root/"}." >&2
                exit 1
            fi
            mermaid_open=1
        elif [[ "$line" == '```' && $mermaid_open -eq 1 ]]; then
            mermaid_open=0
        fi
    done <"$document"
    if [[ $mermaid_open -ne 0 ]]; then
        echo "Erro: bloco Mermaid não encerrado em ${document#"$package_root/"}." >&2
        exit 1
    fi
done < <(find "$package_root" -type f -name '*.md' -print0)

while IFS= read -r -d '' document; do
    while IFS= read -r raw_target; do
        target=${raw_target#*](}
        target=${target%)}
        target=${target%%#*}
        [[ -z "$target" ]] && continue
        [[ "$target" == http://* || "$target" == https://* ]] && continue
        if [[ ! -e "$(dirname "$document")/$target" ]]; then
            echo "Erro: link local inexistente em ${document#"$package_root/"}: $target" >&2
            exit 1
        fi
    done < <(grep -oE '\]\([^)]*\)' "$document" || true)
done < <(find "$package_root" -type f -name '*.md' -print0)

echo "Pacote válido: 10 histórias, 6 componentes, roadmap consistente, diagramas fechados e links locais resolvidos."
