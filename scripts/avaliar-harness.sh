#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
contract_file="$repo_root/docs/avaliacoes/harness/scenarios.json"
fixtures_dir="$repo_root/docs/avaliacoes/harness/fixtures"
recorded_evidence="$repo_root/docs/avaliacoes/harness/resultados/baseline-2026-08-13.json"

usage() {
    cat <<'EOF'
Uso:
  scripts/avaliar-harness.sh self-test
  scripts/avaliar-harness.sh run --label NOME --output-dir DIRETORIO [--scenario ID]

Variável opcional:
  HARNESS_CODEX_BIN  Caminho explícito para o executável codex quando ele não está no PATH.

O diretório de saída deve ficar fora do repositório porque contém eventos e respostas brutas.
EOF
}

fail() {
    echo "Erro: $1" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || fail "$1 é necessário para avaliar o harness."
}

resolve_codex() {
    local candidate=${HARNESS_CODEX_BIN:-}

    if [[ -z "$candidate" ]]; then
        candidate=$(command -v codex 2>/dev/null || true)
    fi
    if [[ -z "$candidate" || ! -x "$candidate" ]]; then
        echo "Erro: executável codex ausente ou não executável; defina HARNESS_CODEX_BIN com um caminho válido." >&2
        return 1
    fi

    printf '%s\n' "$candidate"
}

harness_manifest() {
    {
        printf '%s\0' \
            AGENTS.md \
            .codex/instructions.md \
            scripts/avaliar-harness.sh \
            docs/avaliacoes/harness/scenarios.json
        git -C "$repo_root" ls-files -z -- .codex/agents .agents/skills
        find \
            "$repo_root/docs/avaliacoes/harness/prompts" \
            "$repo_root/docs/avaliacoes/harness/schemas" \
            "$repo_root/docs/avaliacoes/harness/fixtures" \
            -type f -print0 \
            | sed -z "s#$repo_root/##"
    } | LC_ALL=C sort -zu \
        | while IFS= read -r -d '' harness_file; do
            sha256sum "$repo_root/$harness_file" | sed "s#  $repo_root/#  #"
        done
}

can_retry() {
    local current_attempt=$1
    local max_rework=$2

    ((current_attempt < max_rework))
}

usage_from_events() {
    jq -s '
        [.[] | select(.type == "turn.completed") | .usage]
        | reduce .[] as $usage (
            {
                input_tokens: 0,
                cached_input_tokens: 0,
                cache_write_input_tokens: 0,
                output_tokens: 0,
                reasoning_output_tokens: 0
            };
            .input_tokens += ($usage.input_tokens // 0)
            | .cached_input_tokens += ($usage.cached_input_tokens // 0)
            | .cache_write_input_tokens += ($usage.cache_write_input_tokens // 0)
            | .output_tokens += ($usage.output_tokens // 0)
            | .reasoning_output_tokens += ($usage.reasoning_output_tokens // 0)
        )
    ' "$@"
}

commands_from_events() {
    jq -s '[
        .[]
        | select(.type == "item.completed" and .item.type == "command_execution")
        | .item.command
    ]' "$@"
}

response_ready() {
    local response_file=$1

    [[ -s "$response_file" ]] && jq -e '.' "$response_file" >/dev/null 2>&1
}

annotate_contract_hashes() {
    local result_file=$1
    local prompt_file=$2
    local schema_file=$3
    local prompt_hash
    local schema_hash
    local contract_hash

    prompt_hash=$(sha256sum "$prompt_file" | cut -d ' ' -f 1)
    schema_hash=$(sha256sum "$schema_file" | cut -d ' ' -f 1)
    contract_hash=$(sha256sum "$contract_file" | cut -d ' ' -f 1)
    jq \
        --arg prompt_sha256 "$prompt_hash" \
        --arg schema_sha256 "$schema_hash" \
        --arg contract_sha256 "$contract_hash" \
        '. + {
            prompt_sha256: $prompt_sha256,
            schema_sha256: $schema_sha256,
            contract_sha256: $contract_sha256
        }' "$result_file" >"$result_file.hashed"
    mv "$result_file.hashed" "$result_file"
}

record_runtime_failure() {
    local scenario_id=$1
    local scenario_dir=$2
    local started_at=$3
    local failure_code=$4
    shift 4
    local event_files=("$@")
    local completed_at

    completed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    usage_from_events "${event_files[@]}" >"$scenario_dir/usage.json"
    commands_from_events "${event_files[@]}" >"$scenario_dir/commands.json"
    jq -n \
        --arg scenario_id "$scenario_id" \
        --arg started_at "$started_at" \
        --arg completed_at "$completed_at" \
        --arg failure_code "$failure_code" \
        --slurpfile usage "$scenario_dir/usage.json" \
        --slurpfile prompt_metrics "$scenario_dir/prompt-metrics.json" \
        --slurpfile commands "$scenario_dir/commands.json" \
        '{
            scenario_id: $scenario_id,
            started_at: $started_at,
            completed_at: $completed_at,
            automatic_status: "infrastructure_failed",
            attempts: 1,
            rework_turns: 0,
            usage: $usage[0],
            prompt_metrics: $prompt_metrics[0],
            sources_consulted: [],
            commands_observed: $commands[0],
            remaining_failures: [$failure_code],
            response_sha256: null
        }' >"$scenario_dir/result.json"
}

grade_output() {
    local scenario_json=$1
    local output_file=$2
    local failures_file=$3
    shift 3
    local event_files=("$@")
    local code
    local expression
    local forbidden

    : >"$failures_file"

    if ! jq -e '.' "$output_file" >/dev/null 2>&1; then
        printf '%s\n' 'OUTPUT-INVALID-JSON' >>"$failures_file"
        return 1
    fi

    while IFS=$'\t' read -r code expression; do
        if ! jq -e "$expression" "$output_file" >/dev/null; then
            printf '%s\n' "$code" >>"$failures_file"
        fi
    done < <(jq -r '.assertions[] | [.code, .expression] | @tsv' <<<"$scenario_json")

    while IFS= read -r forbidden; do
        [[ -n "$forbidden" ]] || continue
        if jq -e --arg forbidden "$forbidden" \
            'any(.sources_consulted[]?; contains($forbidden))' \
            "$output_file" >/dev/null; then
            printf 'SOURCE-FORBIDDEN:%s\n' "$forbidden" >>"$failures_file"
        fi
        if [[ ${#event_files[@]} -gt 0 ]] \
            && jq -s -e --arg forbidden "$forbidden" '
                any(.[].item.command? // ""; contains($forbidden))
            ' "${event_files[@]}" >/dev/null; then
            printf 'COMMAND-FORBIDDEN:%s\n' "$forbidden" >>"$failures_file"
        fi
    done < <(jq -r '.forbidden_source_fragments[]' "$contract_file")

    [[ ! -s "$failures_file" ]]
}

prompt_metrics() {
    local codex_bin=$1
    local model=$2
    local reasoning=$3
    local prompt_file=$4
    local prompt_text

    prompt_text=$(<"$prompt_file")
    "$codex_bin" debug prompt-input \
        -c "model=\"$model\"" \
        -c "model_reasoning_effort=\"$reasoning\"" \
        "$prompt_text" \
        | jq '{
            items: length,
            total_string_chars: ([.. | strings | length] | add),
            roles: ([.[]?.role // empty] | group_by(.) | map({role: .[0], count: length}))
        }'
}

run_scenario() {
    local codex_bin=$1
    local output_root=$2
    local scenario_json=$3
    local model=$4
    local reasoning=$5
    local sandbox=$6
    local max_rework=$7
    local scenario_id
    local prompt_relative
    local schema_relative
    local prompt_file
    local schema_file
    local scenario_dir
    local attempt=0
    local events_file
    local response_file
    local failures_file
    local feedback_file
    local thread_id=''
    local automatic_status='failed'
    local started_at
    local completed_at
    local event_files=()
    local final_response=''
    local final_failures=''

    scenario_id=$(jq -r '.id' <<<"$scenario_json")
    prompt_relative=$(jq -r '.prompt' <<<"$scenario_json")
    schema_relative=$(jq -r '.schema' <<<"$scenario_json")
    prompt_file="$repo_root/docs/avaliacoes/harness/$prompt_relative"
    schema_file="$repo_root/docs/avaliacoes/harness/$schema_relative"
    scenario_dir="$output_root/scenarios/$scenario_id"
    mkdir -p "$scenario_dir"

    started_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    if ! prompt_metrics "$codex_bin" "$model" "$reasoning" "$prompt_file" \
        >"$scenario_dir/prompt-metrics.json"; then
        echo '{"items":0,"total_string_chars":0,"roles":[]}' >"$scenario_dir/prompt-metrics.json"
        : >"$scenario_dir/attempt-0.events.jsonl"
        record_runtime_failure "$scenario_id" "$scenario_dir" "$started_at" \
            'RUNTIME-PROMPT-METRICS' "$scenario_dir/attempt-0.events.jsonl"
        annotate_contract_hashes "$scenario_dir/result.json" "$prompt_file" "$schema_file"
        return 2
    fi

    while [[ $attempt -le $max_rework ]]; do
        events_file="$scenario_dir/attempt-$attempt.events.jsonl"
        response_file="$scenario_dir/attempt-$attempt.response.json"
        failures_file="$scenario_dir/attempt-$attempt.failures"
        event_files+=("$events_file")

        if [[ $attempt -eq 0 ]]; then
            if ! "$codex_bin" exec \
                --model "$model" \
                -c "model_reasoning_effort=\"$reasoning\"" \
                --sandbox "$sandbox" \
                --json \
                --output-schema "$schema_file" \
                --output-last-message "$response_file" \
                --cd "$repo_root" \
                - <"$prompt_file" >"$events_file" 2>"$scenario_dir/attempt-$attempt.stderr"; then
                record_runtime_failure "$scenario_id" "$scenario_dir" "$started_at" \
                    'RUNTIME-CODEX-EXIT' "${event_files[@]}"
                annotate_contract_hashes "$scenario_dir/result.json" "$prompt_file" "$schema_file"
                return 2
            fi
            if ! response_ready "$response_file"; then
                record_runtime_failure "$scenario_id" "$scenario_dir" "$started_at" \
                    'RUNTIME-RESPONSE-MISSING' "${event_files[@]}"
                annotate_contract_hashes "$scenario_dir/result.json" "$prompt_file" "$schema_file"
                return 2
            fi
            thread_id=$(jq -r 'select(.type == "thread.started") | .thread_id' "$events_file" | head -n 1)
            if [[ -z "$thread_id" ]]; then
                record_runtime_failure "$scenario_id" "$scenario_dir" "$started_at" \
                    'RUNTIME-THREAD-ID-MISSING' "${event_files[@]}"
                annotate_contract_hashes "$scenario_dir/result.json" "$prompt_file" "$schema_file"
                return 2
            fi
        else
            feedback_file="$scenario_dir/attempt-$attempt.feedback.txt"
            {
                echo "A resposta anterior foi reprovada pelos seguintes códigos determinísticos:"
                sed 's/^/- /' "$final_failures"
                echo
                echo "Corrija somente essas violações, preserve as restrições do cenário e devolva novamente apenas JSON compatível com o mesmo schema."
            } >"$feedback_file"
            if ! "$codex_bin" exec resume \
                --model "$model" \
                -c "model_reasoning_effort=\"$reasoning\"" \
                -c "sandbox_mode=\"$sandbox\"" \
                --json \
                --output-schema "$schema_file" \
                --output-last-message "$response_file" \
                "$thread_id" \
                - <"$feedback_file" >"$events_file" 2>"$scenario_dir/attempt-$attempt.stderr"; then
                record_runtime_failure "$scenario_id" "$scenario_dir" "$started_at" \
                    'RUNTIME-CODEX-RESUME-EXIT' "${event_files[@]}"
                annotate_contract_hashes "$scenario_dir/result.json" "$prompt_file" "$schema_file"
                return 2
            fi
            if ! response_ready "$response_file"; then
                record_runtime_failure "$scenario_id" "$scenario_dir" "$started_at" \
                    'RUNTIME-RESUME-RESPONSE-MISSING' "${event_files[@]}"
                annotate_contract_hashes "$scenario_dir/result.json" "$prompt_file" "$schema_file"
                return 2
            fi
        fi

        final_response=$response_file
        final_failures=$failures_file
        if grade_output "$scenario_json" "$response_file" "$failures_file" "${event_files[@]}"; then
            automatic_status='passed'
            break
        fi

        if ! can_retry "$attempt" "$max_rework"; then
            break
        fi
        attempt=$((attempt + 1))
    done

    completed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    cp "$final_response" "$scenario_dir/final.response.json"
    usage_from_events "${event_files[@]}" >"$scenario_dir/usage.json"
    commands_from_events "${event_files[@]}" >"$scenario_dir/commands.json"

    jq -n \
        --arg scenario_id "$scenario_id" \
        --arg started_at "$started_at" \
        --arg completed_at "$completed_at" \
        --arg automatic_status "$automatic_status" \
        --argjson attempts "$((attempt + 1))" \
        --argjson rework "$attempt" \
        --slurpfile usage "$scenario_dir/usage.json" \
        --slurpfile prompt_metrics "$scenario_dir/prompt-metrics.json" \
        --slurpfile response "$scenario_dir/final.response.json" \
        --slurpfile commands "$scenario_dir/commands.json" \
        --rawfile failures "$final_failures" \
        '{
            scenario_id: $scenario_id,
            started_at: $started_at,
            completed_at: $completed_at,
            automatic_status: $automatic_status,
            attempts: $attempts,
            rework_turns: $rework,
            usage: $usage[0],
            prompt_metrics: $prompt_metrics[0],
            sources_consulted: ($response[0].sources_consulted // []),
            commands_observed: $commands[0],
            remaining_failures: ($failures | split("\n") | map(select(length > 0))),
            response_sha256: "pending"
        }' >"$scenario_dir/result.pending.json"

    local response_hash
    response_hash=$(sha256sum "$scenario_dir/final.response.json" | cut -d ' ' -f 1)
    jq --arg response_hash "$response_hash" '.response_sha256 = $response_hash' \
        "$scenario_dir/result.pending.json" >"$scenario_dir/result.json"
    annotate_contract_hashes "$scenario_dir/result.json" "$prompt_file" "$schema_file"

    [[ "$automatic_status" == 'passed' ]]
}

self_test() {
    local test_tmp
    local scenario_json
    local fixture_relative
    local fixture_file
    local failures_file
    local totals
    local scenario_count=0

    require_command jq
    require_command git
    require_command sha256sum
    test_tmp=$(mktemp -d)
    # shellcheck disable=SC2064  # Expande agora: a variável é local e não existe no trap EXIT.
    trap "rm -rf -- '$test_tmp'" EXIT

    jq -e '.contract_version == 1 and (.scenarios | length) == 3' "$contract_file" >/dev/null
    while IFS= read -r scenario_json; do
        fixture_relative=$(jq -r '.valid_fixture' <<<"$scenario_json")
        fixture_file="$repo_root/docs/avaliacoes/harness/$fixture_relative"
        local schema_relative
        local schema_file
        schema_relative=$(jq -r '.schema' <<<"$scenario_json")
        schema_file="$repo_root/docs/avaliacoes/harness/$schema_relative"
        jq -e '
            ([.. | objects | select((has("const") or has("enum")) and (has("type") | not))] | length) == 0
            and ([.. | objects | select(.type? == "array" and (has("items") | not))] | length) == 0
            and ([.. | objects | select(.type? == "object" and (.additionalProperties? != false))] | length) == 0
            and ([.. | objects | to_entries[] | select(.key == "uniqueItems" or .key == "minLength" or .key == "maxLength" or .key == "allOf" or .key == "not" or .key == "if" or .key == "then" or .key == "else")] | length) == 0
        ' "$schema_file" >/dev/null \
            || fail "schema incompatível com structured output: $schema_relative."
        failures_file="$test_tmp/fixture-$scenario_count.failures"
        grade_output "$scenario_json" "$fixture_file" "$failures_file" "$fixtures_dir/turn-completed.jsonl" \
            || fail "fixture válida foi reprovada: $(jq -r '.id' <<<"$scenario_json")."
        scenario_count=$((scenario_count + 1))
    done < <(jq -c '.scenarios[]' "$contract_file")

    totals=$(usage_from_events "$fixtures_dir/turn-completed.jsonl")
    jq -e '
        .input_tokens == 150
        and .cached_input_tokens == 50
        and .output_tokens == 27
        and .reasoning_output_tokens == 7
    ' <<<"$totals" >/dev/null || fail "parser de tokens não somou a fixture corretamente."

    scenario_json=$(jq -c '.scenarios[] | select(.id == "EVAL-HARNESS-TM-001")' "$contract_file")
    jq 'del(.gates[-1])' "$fixtures_dir/threat-p0-gates.valid.json" >"$test_tmp/threat-invalid.json"
    if grade_output "$scenario_json" "$test_tmp/threat-invalid.json" "$test_tmp/threat-invalid.failures" "$fixtures_dir/turn-completed.jsonl"; then
        fail "rubrica aceitou uma ameaça P0 ausente."
    fi

    if HARNESS_CODEX_BIN="$test_tmp/codex-ausente" resolve_codex >/dev/null 2>&1; then
        fail "preflight aceitou executável codex inexistente."
    fi
    if response_ready "$test_tmp/resposta-ausente.json"; then
        fail "preflight aceitou resposta inexistente."
    fi
    response_ready "$fixtures_dir/adr-0003.valid.json" \
        || fail "preflight rejeitou resposta JSON válida."
    can_retry 1 2 || fail "limite rejeitou a última correção permitida."
    if can_retry 2 2; then
        fail "limite aceitou uma correção além do máximo."
    fi
    cp "$fixtures_dir/adr-0003.valid.json" "$test_tmp/result.json"
    annotate_contract_hashes \
        "$test_tmp/result.json" \
        "$repo_root/docs/avaliacoes/harness/prompts/adr-0003.md" \
        "$repo_root/docs/avaliacoes/harness/schemas/adr-0003.schema.json"
    jq -e '
        (.prompt_sha256 | length) == 64
        and (.schema_sha256 | length) == 64
        and (.contract_sha256 | length) == 64
    ' "$test_tmp/result.json" >/dev/null || fail "hashes do contrato não foram registrados."

    jq -e '
        .automatic_status == "passed"
        and .semantic_status == "passed"
        and ([.scenarios[].automatic_status] | all(. == "passed"))
        and ([.scenarios[].semantic_status] | all(. == "passed"))
        and .totals.attempts == ([.scenarios[].attempts] | add)
        and .totals.rework_turns == ([.scenarios[].rework_turns] | add)
        and .totals.input_tokens == ([.scenarios[].usage.input_tokens] | add)
        and .totals.cached_input_tokens == ([.scenarios[].usage.cached_input_tokens] | add)
        and .totals.output_tokens == ([.scenarios[].usage.output_tokens] | add)
        and .totals.reasoning_output_tokens == ([.scenarios[].usage.reasoning_output_tokens] | add)
        and (.contract_sha256 | length) == 64
        and ([.scenarios[] | select((.prompt_sha256 | length) != 64 or (.schema_sha256 | length) != 64 or (.response_sha256 | length) != 64)] | length) == 0
    ' "$recorded_evidence" >/dev/null || fail "evidência normalizada da baseline está inconsistente."

    echo "Harness self-test válido: 3 fixtures e a evidência normalizada aprovadas; parser de tokens e casos contrafactuais verificados."
}

run_baseline() {
    local label=''
    local output_dir=''
    local selected_scenario=''
    local codex_bin
    local actual_version
    local expected_version
    local model
    local reasoning
    local sandbox
    local max_rework
    local scenario_json
    local scenario_id
    local output_real
    local before_manifest
    local after_manifest
    local overall_status='passed'
    local started_at
    local completed_at
    local scenario_exit
    local result_files=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --label)
                [[ $# -ge 2 ]] || fail "--label exige valor."
                label=$2
                shift 2
                ;;
            --output-dir)
                [[ $# -ge 2 ]] || fail "--output-dir exige valor."
                output_dir=$2
                shift 2
                ;;
            --scenario)
                [[ $# -ge 2 ]] || fail "--scenario exige valor."
                selected_scenario=$2
                shift 2
                ;;
            *)
                fail "opção desconhecida: $1"
                ;;
        esac
    done

    [[ -n "$label" ]] || fail "--label é obrigatório."
    [[ "$label" =~ ^[A-Za-z0-9._-]+$ ]] || fail "--label contém caracteres inválidos."
    [[ -n "$output_dir" ]] || fail "--output-dir é obrigatório."

    require_command jq
    require_command git
    require_command sha256sum
    require_command realpath
    codex_bin=$(resolve_codex)
    expected_version=$(jq -r '.expected_codex_version' "$contract_file")
    actual_version=$("$codex_bin" --version)
    [[ "$actual_version" == "$expected_version" ]] \
        || fail "versão do Codex diverge do contrato: esperado '$expected_version', obtido '$actual_version'."

    model=$(jq -r '.model' "$contract_file")
    reasoning=$(jq -r '.reasoning_effort' "$contract_file")
    sandbox=$(jq -r '.sandbox' "$contract_file")
    max_rework=$(jq -r '.max_rework' "$contract_file")

    mkdir -p "$output_dir"
    output_real=$(realpath -m -- "$output_dir")
    case "$output_real" in
        "$repo_root"|"$repo_root"/*)
            fail "o diretório de saída deve ficar fora do repositório."
            ;;
    esac

    self_test >/dev/null
    "$repo_root/scripts/validar-documentacao.sh" >/dev/null
    "$repo_root/scripts/validar-contexto.sh" >/dev/null

    before_manifest="$output_real/harness-before.sha256"
    after_manifest="$output_real/harness-after.sha256"
    harness_manifest >"$before_manifest"
    git -C "$repo_root" status --short >"$output_real/git-status-before.txt"
    started_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    while IFS= read -r scenario_json; do
        scenario_id=$(jq -r '.id' <<<"$scenario_json")
        if [[ -n "$selected_scenario" && "$scenario_id" != "$selected_scenario" ]]; then
            continue
        fi
        echo "Executando $scenario_id..."
        if run_scenario "$codex_bin" "$output_real" "$scenario_json" \
            "$model" "$reasoning" "$sandbox" "$max_rework"; then
            scenario_exit=0
        else
            scenario_exit=$?
            overall_status='failed'
            if [[ $scenario_exit -eq 2 ]]; then
                echo "Erro: infraestrutura interrompeu $scenario_id; os cenários seguintes não serão executados." >&2
                break
            fi
        fi
    done < <(jq -c '.scenarios[]' "$contract_file")

    if [[ -n "$selected_scenario" \
        && ! -e "$output_real/scenarios/$selected_scenario/result.json" ]]; then
        fail "cenário desconhecido: $selected_scenario"
    fi

    harness_manifest >"$after_manifest"
    if ! cmp -s "$before_manifest" "$after_manifest"; then
        overall_status='failed'
        echo "Erro: arquivos do harness mudaram durante a avaliação." >&2
    fi
    completed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    shopt -s nullglob
    result_files=("$output_real"/scenarios/*/result.json)
    shopt -u nullglob
    [[ ${#result_files[@]} -gt 0 ]] || fail "nenhum resultado de cenário foi produzido."

    jq -s \
        --arg label "$label" \
        --arg started_at "$started_at" \
        --arg completed_at "$completed_at" \
        --arg git_head "$(git -C "$repo_root" rev-parse HEAD)" \
        --arg codex_version "$actual_version" \
        --arg model "$model" \
        --arg reasoning_effort "$reasoning" \
        --arg sandbox "$sandbox" \
        --arg automatic_status "$overall_status" \
        --rawfile git_status "$output_real/git-status-before.txt" \
        --rawfile harness_manifest "$before_manifest" \
        '{
            label: $label,
            started_at: $started_at,
            completed_at: $completed_at,
            git_head: $git_head,
            git_status_before: ($git_status | split("\n") | map(select(length > 0))),
            codex_version: $codex_version,
            model: $model,
            reasoning_effort: $reasoning_effort,
            sandbox: $sandbox,
            automatic_status: $automatic_status,
            harness_manifest: ($harness_manifest | split("\n") | map(select(length > 0))),
            scenarios: .
        }' "${result_files[@]}" >"$output_real/summary.json"

    echo "Resumo: $output_real/summary.json"
    [[ "$overall_status" == 'passed' ]]
}

main() {
    [[ $# -gt 0 ]] || { usage; exit 1; }

    case "$1" in
        self-test)
            shift
            [[ $# -eq 0 ]] || fail "self-test não aceita argumentos."
            self_test
            ;;
        run)
            shift
            run_baseline "$@"
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            usage >&2
            fail "comando desconhecido: $1"
            ;;
    esac
}

main "$@"
