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
requirement_changes_file="$context_tmp/requirement-changes"
: >"$ids_file"
: >"$targets_file"
: >"$requirement_changes_file"

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

    context_id=$(yq eval -r '.context_id' "$metadata_file")
    context_type=$(yq eval -r '.context_type' "$metadata_file")

    if [[ "$context_type" == "requirement_change" ]]; then
        if [[ $(basename "$document" .md) != "$context_id" ]]; then
            echo "Erro: arquivo de mudança $relative_path diverge do context_id $context_id." >&2
            exit 1
        fi

        if [[ $(yq eval -r '.status' "$metadata_file") != "registrado" ]]; then
            echo "Erro: mudança de requisito $context_id deve possuir status registrado." >&2
            exit 1
        fi

        for actor_field in refined_by recorded_by; do
            actor=$(yq eval -r ".${actor_field} // \"\"" "$metadata_file")
            case "$actor" in
                analista_negocio|agente_principal|responsavel_produto)
                    ;;
                nao_registrado)
                    if [[ $(yq eval -r '.recorded_at' "$metadata_file") > "2026-08-01" ]]; then
                        echo "Erro: $context_id usa nao_registrado fora da reconstrução histórica." >&2
                        exit 1
                    fi
                    ;;
                *)
                    echo "Erro: $context_id possui ator inválido ou ausente em $actor_field: $actor" >&2
                    exit 1
                    ;;
            esac
        done

        confirmed_by=$(yq eval -r '.confirmed_by // ""' "$metadata_file")
        confirmed_at=$(yq eval -r '.confirmed_at // ""' "$metadata_file")
        if [[ -n "$confirmed_by" && -z "$confirmed_at" ]]; then
            echo "Erro: $context_id possui confirmed_by sem confirmed_at." >&2
            exit 1
        fi
        if [[ -z "$confirmed_by" && -n "$confirmed_at" ]]; then
            echo "Erro: $context_id possui confirmed_at sem confirmed_by." >&2
            exit 1
        fi
        if [[ -n "$confirmed_by" && "$confirmed_by" != "responsavel_produto" ]]; then
            echo "Erro: $context_id possui confirmador sem autoridade de produto: $confirmed_by" >&2
            exit 1
        fi

        if ! grep -Fq '| História | Alteração semântica | Classificação anterior | Classificação resultante | Evidência | Confirmação |' "$document"; then
            echo "Erro: $context_id não possui a tabela obrigatória de alterações." >&2
            exit 1
        fi

        affects_count=0
        while IFS= read -r story_id; do
            [[ -z "$story_id" ]] && continue
            if [[ ! "$story_id" =~ ^US-[0-9]{2,}$ ]]; then
                echo "Erro: $context_id afeta alvo que não é história: $story_id" >&2
                exit 1
            fi

            story_anchor=$(printf '%s' "$story_id" | tr '[:upper:]' '[:lower:]')
            if ! grep -Fq "../historias.md#$story_anchor" "$document"; then
                echo "Erro: $context_id não possui link de retorno para $story_id." >&2
                exit 1
            fi

            printf '%s\t%s\t%s\n' "$story_id" "$(basename "$document")" "$context_id" >>"$requirement_changes_file"
            affects_count=$((affects_count + 1))
        done < <(yq eval -r '.relations[]? | select(.type == "affects") | .target' "$metadata_file")

        if [[ $affects_count -eq 0 ]]; then
            echo "Erro: $context_id não possui relação affects para uma história." >&2
            exit 1
        fi
    fi

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

validate_story_backlinks() {
    local stories="$repo_root/docs/requisitos/historias.md"
    local story_id
    local change_file
    local change_id
    local story_anchor
    local story_section

    [[ -s "$requirement_changes_file" ]] || return

    if [[ ! -e "$stories" ]]; then
        echo "Erro: registros de mudança existem sem o conjunto de histórias." >&2
        exit 1
    fi

    while IFS=$'\t' read -r story_id change_file change_id; do
        story_anchor=$(printf '%s' "$story_id" | tr '[:upper:]' '[:lower:]')
        if ! grep -Fxq "<a id=\"$story_anchor\"></a>" "$stories"; then
            echo "Erro: $story_id não possui âncora estável em docs/requisitos/historias.md." >&2
            exit 1
        fi

        story_section=$(awk -v anchor="<a id=\"$story_anchor\"></a>" '
            $0 == anchor { inside = 1 }
            inside && $0 != anchor && /^<a id="us-[0-9]+"><\/a>$/ { exit }
            inside { print }
        ' "$stories")

        if ! grep -Fq "refinamentos/$change_file" <<<"$story_section"; then
            echo "Erro: $story_id não possui backlink para $change_id." >&2
            exit 1
        fi
    done <"$requirement_changes_file"
}

validate_story_backlinks

validate_accepted_decision_summary() {
    local decisions_dir="$repo_root/docs/arquitetura/decisoes"
    local project_context="$repo_root/docs/contexto-projeto.md"
    local decision
    local decision_metadata
    local decision_id
    local decisions_section
    local accepted_count=0

    [[ -d "$decisions_dir" && -e "$project_context" ]] || return

    decisions_section=$(awk '
        /^## Decisões vigentes$/ { inside = 1; next }
        inside && /^## / { exit }
        inside { print }
    ' "$project_context")

    while IFS= read -r -d '' decision; do
        decision_metadata="$context_tmp/decision-$(basename "$decision").yaml"
        awk 'NR == 1 { next } /^---$/ { exit } { print }' "$decision" >"$decision_metadata"

        if [[ $(yq eval -r '.template // false' "$decision_metadata") == "true" ]]; then
            continue
        fi
        if [[ $(yq eval -r '.status // ""' "$decision_metadata") != "aceita" ]]; then
            continue
        fi

        accepted_count=$((accepted_count + 1))
        decision_id=$(yq eval -r '.context_id // ""' "$decision_metadata")
        if [[ -z "$decision_id" || ! "$decisions_section" =~ $decision_id ]]; then
            echo "Erro: decisão aceita sem referência em docs/contexto-projeto.md: $decision_id." >&2
            exit 1
        fi
    done < <(find "$decisions_dir" -maxdepth 1 -type f -name '[0-9]*.md' -print0)

    if [[ $accepted_count -gt 0 ]] && grep -Fq 'Ainda não há decisões arquiteturais registradas' <<<"$decisions_section"; then
        echo "Erro: o contexto do projeto afirma não haver decisões, mas existem ADRs aceitos." >&2
        exit 1
    fi
}

validate_accepted_decision_summary

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

bash "$repo_root/scripts/validar-componentes.sh"
bash "$repo_root/scripts/validar-arquitetura-recomendada.sh"
bash "$repo_root/docs/propostas/base-simplificada-seis-componentes/validacao/validar-pacote.sh"

echo "Contexto válido: $(wc -l <"$ids_file") IDs únicos verificados."
