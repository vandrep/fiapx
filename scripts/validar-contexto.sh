#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
context_tmp=$(mktemp -d)
trap 'rm -rf -- "$context_tmp"' EXIT

if ! command -v yq >/dev/null 2>&1; then
    echo "Erro: yq v4 é necessário para validar os metadados de contexto." >&2
    exit 1
fi

ids_file="$context_tmp/ids"
targets_file="$context_tmp/targets"
: >"$ids_file"
: >"$targets_file"

while IFS= read -r -d '' document; do
    if [[ $(head -n 1 "$document") != "---" ]]; then
        continue
    fi

    relative_path=${document#"$repo_root/"}
    metadata_file="$context_tmp/$(printf '%s' "$relative_path" | tr '/ ' '__').yaml"
    awk 'NR == 1 { next } /^---$/ { exit } { print }' "$document" >"$metadata_file"

    yq eval '.' "$metadata_file" >/dev/null

    if [[ $(yq eval -r '.template // false' "$metadata_file") == "true" ]]; then
        continue
    fi

    for field in context_id context_type status recorded_at valid_from; do
        value=$(yq eval -r ".${field} // \"\"" "$metadata_file")
        if [[ -z "$value" ]]; then
            echo "Erro: $relative_path não possui o campo obrigatório $field." >&2
            exit 1
        fi
    done

    yq eval -r '.context_id, (.entities[]?)' "$metadata_file" >>"$ids_file"

    while IFS=$'\t' read -r relation_type relation_target; do
        [[ -z "$relation_type" && -z "$relation_target" ]] && continue

        case "$relation_type" in
            derived_from|informed_by|informs|motivated_by|governed_by|refines|affects|depends_on|validated_by|contradicts|supersedes|produces)
                ;;
            *)
                echo "Erro: relação desconhecida em $relative_path: $relation_type" >&2
                exit 1
                ;;
        esac

        if [[ -z "$relation_target" ]]; then
            echo "Erro: relação sem alvo em $relative_path: $relation_type" >&2
            exit 1
        fi

        printf '%s\n' "$relation_target" >>"$targets_file"
    done < <(yq eval -r '.relations[]? | [.type, .target] | @tsv' "$metadata_file")
done < <(find "$repo_root/docs" -type f -name '*.md' -print0)

duplicate_ids=$(sort "$ids_file" | uniq -d)
if [[ -n "$duplicate_ids" ]]; then
    echo "Erro: IDs de contexto duplicados:" >&2
    printf '%s\n' "$duplicate_ids" >&2
    exit 1
fi

while IFS= read -r target; do
    [[ -z "$target" ]] && continue

    if [[ "$target" =~ ^[A-Z][A-Z0-9]*(-[A-Z0-9]+)*-[0-9]{2,}$ ]]; then
        if ! grep -Fxq "$target" "$ids_file"; then
            echo "Erro: alvo contextual sem resolução: $target" >&2
            exit 1
        fi
    elif [[ "$target" == docs/* ]]; then
        if [[ ! -e "$repo_root/$target" ]]; then
            echo "Erro: alvo local inexistente: $target" >&2
            exit 1
        fi
    fi
done <"$targets_file"

validate_work_register() {
    local document=$1
    local relative_path=${document#"$repo_root/"}
    local metadata_file="$context_tmp/work-register.yaml"
    local declared_entities
    local documented_entities

    awk 'NR == 1 { next } /^---$/ { exit } { print }' "$document" >"$metadata_file"
    declared_entities=$(yq eval -r '.entities[]?' "$metadata_file" | sort)
    documented_entities=$(sed -n 's/^### \(WORK-[0-9][0-9]*\) —.*/\1/p' "$document" | sort)

    if [[ "$declared_entities" != "$documented_entities" ]]; then
        echo "Erro: entities e seções WORK divergem em $relative_path." >&2
        exit 1
    fi
}

roadmap="$repo_root/docs/acompanhamento/roadmap.md"
outcome_log="$repo_root/docs/acompanhamento/realizacoes.md"

if [[ -e "$roadmap" ]]; then
    validate_work_register "$roadmap"

    # shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
    if grep -Fq '**Estado:** `concluido`' "$roadmap"; then
        echo "Erro: o roadmap ativo contém um item concluído." >&2
        exit 1
    fi
fi

if [[ -e "$outcome_log" ]]; then
    validate_work_register "$outcome_log"
fi

echo "Contexto válido: $(wc -l <"$ids_file") IDs únicos verificados."
