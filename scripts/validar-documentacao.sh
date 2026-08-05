#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
validation_tmp=$(mktemp -d)
trap 'rm -rf -- "$validation_tmp"' EXIT

documents_file="$validation_tmp/documents"
edges_file="$validation_tmp/edges"
outgoing_file="$validation_tmp/outgoing"
: >"$documents_file"
: >"$edges_file"
: >"$outgoing_file"

if ! command -v git >/dev/null 2>&1; then
    echo "Erro: git é necessário para enumerar os documentos Markdown mantidos." >&2
    exit 1
fi

while IFS= read -r -d '' document; do
    [[ -e "$repo_root/$document" ]] || continue
    printf '%s\n' "$document" >>"$documents_file"
done < <(git -C "$repo_root" ls-files -z --cached --others --exclude-standard -- '*.md')

sort -u -o "$documents_file" "$documents_file"

declare -A maintained_documents=()
while IFS= read -r document; do
    maintained_documents["$document"]=1
done <"$documents_file"

if ! grep -Fxq 'README.md' "$documents_file"; then
    echo "Erro: README.md principal inexistente." >&2
    exit 1
fi

if ! command -v perl >/dev/null 2>&1; then
    echo "Erro: perl é necessário para validar links e âncoras Markdown." >&2
    exit 1
fi

markdown_without_fenced_blocks() {
    local document=$1

    perl -ne '
        if ($inside_fence) {
            if (/^[ \t]{0,3}((?:`+)|(?:~+))[ \t]*$/
                && substr($1, 0, 1) eq $fence_character
                && length($1) >= $fence_length) {
                $inside_fence = 0;
            }
            next;
        }

        if (/^[ \t]{0,3}((?:`{3,})|(?:~{3,}))/) {
            $inside_fence = 1;
            $fence_character = substr($1, 0, 1);
            $fence_length = length($1);
            next;
        }

        print;
    ' "$document"
}

extract_link_targets() {
    local document=$1

    markdown_without_fenced_blocks "$document" \
        | perl -ne 'while (/(?<!!)\[[^]\r\n]+\]\(([^)\r\n]+)\)/g) { print "$1\n" }'
}

decode_fragment() {
    local fragment=$1

    printf '%s' "$fragment" | perl -pe 's/%([0-9A-Fa-f]{2})/chr(hex($1))/eg'
}

heading_slug() {
    local heading=$1

    printf '%s\n' "$heading" | perl -CS -Mutf8 -ne '
        chomp;
        s/^#{1,6}[ \t]+//;
        s/[ \t]+#+[ \t]*$//;
        s/\[([^]]+)\]\([^)]+\)/$1/g;
        s/<[^>]*>//g;
        s/[`*_~]//g;
        $_ = lc $_;
        s/[^\p{L}\p{N}\p{M}\s_-]//g;
        s/[ \t\r\n]/-/g;
        print;
    '
}

anchor_exists() {
    local document=$1
    local expected=$2
    local heading
    local base_slug
    local candidate_slug
    local duplicate_index
    local document_without_fences
    declare -A slug_occurrences=()

    document_without_fences=$(markdown_without_fenced_blocks "$document")

    if grep -Fq "id=\"$expected\"" <<<"$document_without_fences" \
        || grep -Fq "id='$expected'" <<<"$document_without_fences" \
        || grep -Fq "name=\"$expected\"" <<<"$document_without_fences" \
        || grep -Fq "name='$expected'" <<<"$document_without_fences"; then
        return 0
    fi

    while IFS= read -r heading; do
        base_slug=$(heading_slug "$heading")
        [[ -n "$base_slug" ]] || continue

        duplicate_index=${slug_occurrences["$base_slug"]:-0}
        candidate_slug=$base_slug
        if [[ $duplicate_index -gt 0 ]]; then
            candidate_slug="$base_slug-$duplicate_index"
        fi
        slug_occurrences["$base_slug"]=$((duplicate_index + 1))

        if [[ "$candidate_slug" == "$expected" ]]; then
            return 0
        fi
    done < <(grep -E '^#{1,6}[[:space:]]+' <<<"$document_without_fences" || true)

    return 1
}

failures=0

report_error() {
    echo "Erro: $1" >&2
    failures=$((failures + 1))
}

while IFS= read -r source; do
    source_path="$repo_root/$source"
    source_dir=$(dirname "$source_path")

    while IFS= read -r raw_target; do
        target=$raw_target
        if [[ "$target" == '<'*'>' ]]; then
            target=${target#<}
            target=${target%>}
        fi

        case "$target" in
            http://*|https://*|mailto:*|data:*)
                continue
                ;;
            file://*)
                report_error "$source usa URI local não portável: $target"
                continue
                ;;
        esac

        fragment=''
        if [[ "$target" == *'#'* ]]; then
            fragment=${target#*#}
            target_path=${target%%#*}
        else
            target_path=$target
        fi

        if [[ -z "$target_path" ]]; then
            resolved_path=$source_path
        elif [[ "$target_path" == /* ]]; then
            resolved_path=$(realpath -m -- "$repo_root/${target_path#/}")
        else
            resolved_path=$(realpath -m -- "$source_dir/$target_path")
        fi

        case "$resolved_path" in
            "$repo_root"|"$repo_root"/*)
                ;;
            *)
                report_error "$source aponta para fora do repositório: $raw_target"
                continue
                ;;
        esac

        if [[ ! -e "$resolved_path" ]]; then
            report_error "$source aponta para destino local inexistente: $raw_target"
            continue
        fi

        if [[ -n "$fragment" && -f "$resolved_path" && "$resolved_path" == *.md ]]; then
            decoded_fragment=$(decode_fragment "$fragment")
            if ! anchor_exists "$resolved_path" "$decoded_fragment"; then
                report_error "$source aponta para âncora inexistente: $raw_target"
            fi
        fi

        destination_document=''
        if [[ -d "$resolved_path" && -f "$resolved_path/README.md" ]]; then
            destination_document="$resolved_path/README.md"
        elif [[ -f "$resolved_path" && "$resolved_path" == *.md ]]; then
            destination_document=$resolved_path
        fi

        if [[ -n "$destination_document" ]]; then
            destination=$(realpath --relative-to="$repo_root" "$destination_document")
            if [[ -n "${maintained_documents[$destination]:-}" ]]; then
                printf '%s\t%s\n' "$source" "$destination" >>"$edges_file"
                if [[ "$source" != "$destination" ]]; then
                    printf '%s\n' "$source" >>"$outgoing_file"
                fi
            fi
        fi
    done < <(extract_link_targets "$source_path")
done <"$documents_file"

sort -u -o "$edges_file" "$edges_file"
sort -u -o "$outgoing_file" "$outgoing_file"

while IFS= read -r document; do
    [[ "$document" == 'README.md' ]] && continue
    if ! grep -Fxq "$document" "$outgoing_file"; then
        report_error "$document não possui link para outro documento Markdown mantido"
    fi
done <"$documents_file"

declare -A reachable=(['README.md']=1)
changed=1
while [[ $changed -eq 1 ]]; do
    changed=0
    while IFS=$'\t' read -r source destination; do
        [[ -n "$source" && -n "$destination" ]] || continue
        if [[ -n "${reachable[$source]:-}" && -z "${reachable[$destination]:-}" ]]; then
            reachable["$destination"]=1
            changed=1
        fi
    done <"$edges_file"
done

while IFS= read -r document; do
    if [[ -z "${reachable[$document]:-}" ]]; then
        report_error "$document não é alcançável a partir de README.md"
    fi
done <"$documents_file"

if [[ $failures -gt 0 ]]; then
    echo "Documentação inválida: $failures falha(s) encontrada(s)." >&2
    exit 1
fi

echo "Documentação navegável: $(wc -l <"$documents_file") documentos, destinos locais, âncoras, links de saída e alcance verificados."
