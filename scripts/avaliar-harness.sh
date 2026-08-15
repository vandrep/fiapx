#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
harness_dir="$repo_root/docs/avaliacoes/harness"
default_contract_file="$harness_dir/scenarios.json"
contract_file="$default_contract_file"
fixtures_dir="$harness_dir/fixtures"
recorded_evidence="$harness_dir/resultados/baseline-2026-08-13.json"

usage() {
    cat <<'EOF'
Uso:
  scripts/avaliar-harness.sh self-test [--contract ARQUIVO]
  scripts/avaliar-harness.sh run --label NOME --output-dir DIRETORIO [--contract ARQUIVO] [--scenario ID] [--repeat N] [--fail-fast]

Variável opcional:
  HARNESS_CODEX_BIN  Caminho explícito para o executável codex quando ele não está no PATH.

O diretório de saída deve ficar fora do repositório porque contém eventos e respostas brutas.
O contrato padrão é docs/avaliacoes/harness/scenarios.json; caminhos relativos são resolvidos nesse diretório.
Uma repetição preserva o layout histórico; --repeat N cria run-001..N e batch-summary.json.
EOF
}

fail() {
    echo "Erro: $1" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || fail "$1 é necessário para avaliar o harness."
}

select_contract() {
    local requested=$1
    local resolved

    command -v realpath >/dev/null 2>&1 || fail "realpath é necessário para selecionar o contrato."
    if [[ "$requested" == /* ]]; then
        resolved=$(realpath -e -- "$requested") || fail "contrato inexistente: $requested."
    else
        resolved=$(realpath -e -- "$harness_dir/$requested") || fail "contrato inexistente: $requested."
    fi

    case "$resolved" in
        "$harness_dir"/*)
            ;;
        *)
            fail "o contrato deve ficar em docs/avaliacoes/harness/."
            ;;
    esac
    [[ -f "$resolved" ]] || fail "contrato não é arquivo regular: $requested."
    contract_file=$resolved
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
    local contract_relative
    contract_relative=$(realpath --relative-to="$repo_root" "$contract_file")
    {
        printf '%s\0' \
            AGENTS.md \
            ARCHITECTURE.md \
            .codex/instructions.md \
            scripts/avaliar-harness.sh \
            "$contract_relative"
        git -C "$repo_root" ls-files -z --cached --others --exclude-standard -- \
            '*.md' .codex/agents .agents/skills
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
        | .uncached_input_tokens = ([
            .input_tokens - .cached_input_tokens - .cache_write_input_tokens,
            0
        ] | max)
    ' "$@"
}

commands_from_events() {
    jq -s '[
        .[]
        | select(.type == "item.completed" and .item.type == "command_execution")
        | .item.command
    ]' "$@"
}

command_metrics_from_events() {
    jq -s '
        [
            .[]
            | select(.type == "item.completed" and .item.type == "command_execution")
            | {
                output_chars: ((.item.aggregated_output // "") | length),
                output_sha256_unavailable: true
            }
        ] as $commands
        | {
            count: ($commands | length),
            output_chars: ([$commands[].output_chars] | add // 0),
            raw_output_persisted_externally: true
        }
    ' "$@"
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
    local started_epoch=$4
    local failure_code=$5
    shift 5
    local event_files=("$@")
    local completed_at
    local completed_epoch
    local attempts=${#event_files[@]}

    completed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    completed_epoch=$(date +%s)
    usage_from_events "${event_files[@]}" >"$scenario_dir/usage.json"
    commands_from_events "${event_files[@]}" >"$scenario_dir/commands.json"
    command_metrics_from_events "${event_files[@]}" >"$scenario_dir/command-metrics.json"
    jq -n \
        --arg scenario_id "$scenario_id" \
        --arg started_at "$started_at" \
        --arg completed_at "$completed_at" \
        --arg failure_code "$failure_code" \
        --argjson duration_seconds "$((completed_epoch - started_epoch))" \
        --argjson attempts "$attempts" \
        --slurpfile usage "$scenario_dir/usage.json" \
        --slurpfile prompt_metrics "$scenario_dir/prompt-metrics.json" \
        --slurpfile commands "$scenario_dir/commands.json" \
        --slurpfile command_metrics "$scenario_dir/command-metrics.json" \
        '{
            scenario_id: $scenario_id,
            started_at: $started_at,
            completed_at: $completed_at,
            duration_seconds: $duration_seconds,
            automatic_status: "infrastructure_failed",
            attempts: $attempts,
            rework_turns: ([$attempts - 1, 0] | max),
            usage: $usage[0],
            prompt_metrics: $prompt_metrics[0],
            sources_consulted: [],
            commands_observed: $commands[0],
            command_metrics: $command_metrics[0],
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
    done < <(
        {
            jq -r '.forbidden_source_fragments[]?' "$contract_file"
            jq -r '.forbidden_source_fragments[]?' <<<"$scenario_json"
        } | LC_ALL=C sort -u
    )

    while IFS= read -r forbidden; do
        [[ -n "$forbidden" ]] || continue
        if [[ ${#event_files[@]} -gt 0 ]] \
            && jq -s -e --arg forbidden "$forbidden" '
                any(.[].item.aggregated_output? // ""; contains($forbidden))
            ' "${event_files[@]}" >/dev/null; then
            printf 'COMMAND-OUTPUT-FORBIDDEN:%s\n' "$forbidden" >>"$failures_file"
        fi
    done < <(
        {
            jq -r '.forbidden_command_output_fragments[]?' "$contract_file"
            jq -r '.forbidden_command_output_fragments[]?' <<<"$scenario_json"
        } | LC_ALL=C sort -u
    )

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
    local started_epoch
    local completed_at
    local completed_epoch
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
    started_epoch=$(date +%s)
    if ! prompt_metrics "$codex_bin" "$model" "$reasoning" "$prompt_file" \
        >"$scenario_dir/prompt-metrics.json"; then
        echo '{"items":0,"total_string_chars":0,"roles":[]}' >"$scenario_dir/prompt-metrics.json"
        : >"$scenario_dir/attempt-0.events.jsonl"
        record_runtime_failure "$scenario_id" "$scenario_dir" "$started_at" "$started_epoch" \
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
                record_runtime_failure "$scenario_id" "$scenario_dir" "$started_at" "$started_epoch" \
                    'RUNTIME-CODEX-EXIT' "${event_files[@]}"
                annotate_contract_hashes "$scenario_dir/result.json" "$prompt_file" "$schema_file"
                return 2
            fi
            if ! response_ready "$response_file"; then
                record_runtime_failure "$scenario_id" "$scenario_dir" "$started_at" "$started_epoch" \
                    'RUNTIME-RESPONSE-MISSING' "${event_files[@]}"
                annotate_contract_hashes "$scenario_dir/result.json" "$prompt_file" "$schema_file"
                return 2
            fi
            thread_id=$(jq -r 'select(.type == "thread.started") | .thread_id' "$events_file" | head -n 1)
            if [[ -z "$thread_id" ]]; then
                record_runtime_failure "$scenario_id" "$scenario_dir" "$started_at" "$started_epoch" \
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
                record_runtime_failure "$scenario_id" "$scenario_dir" "$started_at" "$started_epoch" \
                    'RUNTIME-CODEX-RESUME-EXIT' "${event_files[@]}"
                annotate_contract_hashes "$scenario_dir/result.json" "$prompt_file" "$schema_file"
                return 2
            fi
            if ! response_ready "$response_file"; then
                record_runtime_failure "$scenario_id" "$scenario_dir" "$started_at" "$started_epoch" \
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
    completed_epoch=$(date +%s)
    cp "$final_response" "$scenario_dir/final.response.json"
    usage_from_events "${event_files[@]}" >"$scenario_dir/usage.json"
    commands_from_events "${event_files[@]}" >"$scenario_dir/commands.json"
    command_metrics_from_events "${event_files[@]}" >"$scenario_dir/command-metrics.json"

    jq -n \
        --arg scenario_id "$scenario_id" \
        --arg started_at "$started_at" \
        --arg completed_at "$completed_at" \
        --arg automatic_status "$automatic_status" \
        --argjson duration_seconds "$((completed_epoch - started_epoch))" \
        --argjson attempts "$((attempt + 1))" \
        --argjson rework "$attempt" \
        --slurpfile usage "$scenario_dir/usage.json" \
        --slurpfile prompt_metrics "$scenario_dir/prompt-metrics.json" \
        --slurpfile response "$scenario_dir/final.response.json" \
        --slurpfile commands "$scenario_dir/commands.json" \
        --slurpfile command_metrics "$scenario_dir/command-metrics.json" \
        --rawfile failures "$final_failures" \
        '{
            scenario_id: $scenario_id,
            started_at: $started_at,
            completed_at: $completed_at,
            duration_seconds: $duration_seconds,
            automatic_status: $automatic_status,
            attempts: $attempts,
            rework_turns: $rework,
            usage: $usage[0],
            prompt_metrics: $prompt_metrics[0],
            sources_consulted: ($response[0].sources_consulted // []),
            commands_observed: $commands[0],
            command_metrics: $command_metrics[0],
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

    jq -e '
        (.contract_version == 1 or .contract_version == 2 or .contract_version == 3)
        and (.scenarios | length) >= 3
        and ([.scenarios[].id] | length) == ([.scenarios[].id] | unique | length)
    ' "$contract_file" >/dev/null || fail "contrato possui versão, quantidade ou IDs inválidos."
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
        if [[ $(jq -r '.contract_version' "$contract_file") == '3' ]]; then
            jq -e '
                ([.. | objects | select(has("const") or has("enum") or has("minItems") or has("maxItems"))] | length) == 0
            ' "$schema_file" >/dev/null \
                || fail "schema v3 expõe parte do oráculo: $schema_relative."
        fi
        failures_file="$test_tmp/fixture-$scenario_count.failures"
        grade_output "$scenario_json" "$fixture_file" "$failures_file" "$fixtures_dir/turn-completed.jsonl" \
            || fail "fixture válida foi reprovada: $(jq -r '.id' <<<"$scenario_json")."
        scenario_count=$((scenario_count + 1))
    done < <(jq -c '.scenarios[]' "$contract_file")

    totals=$(usage_from_events "$fixtures_dir/turn-completed.jsonl")
    jq -e '
        .input_tokens == 150
        and .cached_input_tokens == 50
        and .uncached_input_tokens == 100
        and .output_tokens == 27
        and .reasoning_output_tokens == 7
    ' <<<"$totals" >/dev/null || fail "parser de tokens não somou a fixture corretamente."

    printf '%s\n' \
        '{"type":"item.completed","item":{"type":"command_execution","command":"true","aggregated_output":"abc"}}' \
        >"$test_tmp/command-event.jsonl"
    command_metrics_from_events "$test_tmp/command-event.jsonl" >"$test_tmp/command-metrics.json"
    jq -e '.count == 1 and .output_chars == 3 and .raw_output_persisted_externally == true' \
        "$test_tmp/command-metrics.json" >/dev/null \
        || fail "métricas de comandos não preservaram contagem e tamanho."

    mkdir -p "$test_tmp/runtime-failure"
    echo '{"items":0,"total_string_chars":0,"roles":[]}' \
        >"$test_tmp/runtime-failure/prompt-metrics.json"
    record_runtime_failure TEST-RUNTIME "$test_tmp/runtime-failure" \
        '2026-08-15T00:00:00Z' "$(date +%s)" TEST-FAILURE \
        "$fixtures_dir/turn-completed.jsonl" "$fixtures_dir/turn-completed.jsonl"
    jq -e '
        .attempts == 2
        and .rework_turns == 1
        and .usage.input_tokens == 300
    ' "$test_tmp/runtime-failure/result.json" >/dev/null \
        || fail "falha durante retrabalho perdeu tentativas ou tokens."

    scenario_json=$(jq -c '.scenarios[] | select(.id == "EVAL-HARNESS-TM-001")' "$contract_file")
    jq 'del(.gates[-1])' "$fixtures_dir/threat-p0-gates.valid.json" >"$test_tmp/threat-invalid.json"
    if grade_output "$scenario_json" "$test_tmp/threat-invalid.json" "$test_tmp/threat-invalid.failures" "$fixtures_dir/turn-completed.jsonl"; then
        fail "rubrica aceitou uma ameaça P0 ausente."
    fi

    scenario_json=$(jq -c '.scenarios[] | select(.id == "EVAL-HARNESS-ARCH-001")' "$contract_file")
    if [[ -n "$scenario_json" ]]; then
        jq '.application_state = "implemented"' \
            "$fixtures_dir/architecture-map.valid.json" >"$test_tmp/architecture-invalid.json"
        if grade_output "$scenario_json" "$test_tmp/architecture-invalid.json" \
            "$test_tmp/architecture-invalid.failures" "$fixtures_dir/turn-completed.jsonl"; then
            fail "rubrica arquitetural aceitou uma aplicação inexistente como implementada."
        fi
    fi

    if [[ $(jq -r '.contract_version' "$contract_file") == '3' ]]; then
        grep -Fq 'use no máximo sete fontes' \
            "$repo_root/docs/avaliacoes/harness/prompts/v3/architecture-map.md" \
            || fail "prompt arquitetural v3 perdeu o orçamento de fontes."
        grep -Fq "liste também \`AGENTS.md\`" \
            "$repo_root/docs/avaliacoes/harness/prompts/v3/architecture-map.md" \
            || fail "prompt arquitetural v3 perdeu a regra de contabilização do contexto automático."
        scenario_json=$(jq -c '.scenarios[] | select(.id == "EVAL-HARNESS-TM-001")' "$contract_file")
        printf '%s\n' \
            '{"type":"item.completed","item":{"type":"command_execution","command":"rg harness docs","aggregated_output":"docs/avaliacoes/harness/scenarios-v3.json"}}' \
            >"$test_tmp/oracle-leak.events.jsonl"
        if grade_output "$scenario_json" "$fixtures_dir/threat-p0-gates.valid.json" \
            "$test_tmp/oracle-leak.failures" "$test_tmp/oracle-leak.events.jsonl"; then
            fail "contrato v3 aceitou vazamento do oráculo pela saída de comando."
        fi
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

    local manifest_snapshot
    manifest_snapshot=$(harness_manifest)
    grep -Fq '  ARCHITECTURE.md' <<<"$manifest_snapshot" \
        || fail "manifesto não inclui o mapa arquitetural."
    grep -Fq '  docs/arquitetura/decisoes/0003-entrega-duravel-e-persistencia.md' <<<"$manifest_snapshot" \
        || fail "manifesto não inclui uma fonte semântica consultada pelos cenários."

    echo '{"status":"passed","duration_seconds":1}' >"$test_tmp/preflight.json"
    jq -n '{label:"test-001",automatic_status:"passed",censored_by_fail_fast:false,duration_seconds:10,totals:{input_tokens:100,cached_input_tokens:40,uncached_input_tokens:60,output_tokens:5,reasoning_output_tokens:1,command_output_chars:200,attempts:1}}' \
        >"$test_tmp/summary-1.json"
    jq -n '{label:"test-002",automatic_status:"passed",censored_by_fail_fast:false,duration_seconds:20,totals:{input_tokens:200,cached_input_tokens:80,uncached_input_tokens:120,output_tokens:7,reasoning_output_tokens:3,command_output_chars:400,attempts:1}}' \
        >"$test_tmp/summary-2.json"
    write_batch_summary "$test_tmp/batch-summary.json" test 2 "$test_tmp/preflight.json" \
        "$test_tmp/summary-1.json" "$test_tmp/summary-2.json"
    jq -e '
        .automatic_status == "passed"
        and .censored == false
        and .executed_repetitions == 2
        and .statistics.input_tokens.median == 150
        and .statistics.uncached_input_tokens.max == 120
    ' "$test_tmp/batch-summary.json" >/dev/null \
        || fail "resumo multiexecução perdeu status ou estatísticas."

    echo "Harness self-test válido: $scenario_count fixtures e a evidência normalizada aprovadas; parser de tokens e casos contrafactuais verificados."
}

write_preflight_result() {
    local output_file=$1
    local started_at=$2
    local completed_at=$3
    local duration_seconds=$4
    local status=$5
    local failure_code=$6
    local codex_version=$7

    jq -n \
        --arg started_at "$started_at" \
        --arg completed_at "$completed_at" \
        --argjson duration_seconds "$duration_seconds" \
        --arg status "$status" \
        --arg failure_code "$failure_code" \
        --arg codex_version "$codex_version" \
        --arg contract "$(realpath --relative-to="$repo_root" "$contract_file")" \
        --arg contract_sha256 "$(sha256sum "$contract_file" | cut -d ' ' -f 1)" \
        '{
            started_at: $started_at,
            completed_at: $completed_at,
            duration_seconds: $duration_seconds,
            status: $status,
            failure_code: (if $failure_code == "" then null else $failure_code end),
            codex_version: (if $codex_version == "" then null else $codex_version end),
            contract: $contract,
            contract_sha256: $contract_sha256,
            deterministic_gate: "scripts/validar-harness.sh check"
        }' >"$output_file"
}

run_iteration() {
    local codex_bin=$1
    local output_root=$2
    local iteration_label=$3
    local selected_scenario=$4
    local model=$5
    local reasoning=$6
    local sandbox=$7
    local max_rework=$8
    local fail_fast=$9
    local actual_version=${10}
    local preflight_file=${11}
    local before_manifest=${12}
    local git_status_file=${13}
    local scenario_json
    local scenario_id
    local scenario_exit
    local overall_status='passed'
    local stop_reason=''
    local started_at
    local started_epoch
    local completed_at
    local completed_epoch
    local after_manifest="$output_root/harness-after.sha256"
    local result_files=()

    mkdir -p "$output_root"
    started_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    started_epoch=$(date +%s)

    while IFS= read -r scenario_json; do
        scenario_id=$(jq -r '.id' <<<"$scenario_json")
        if [[ -n "$selected_scenario" && "$scenario_id" != "$selected_scenario" ]]; then
            continue
        fi
        echo "Executando $scenario_id em $iteration_label..."
        if run_scenario "$codex_bin" "$output_root" "$scenario_json" \
            "$model" "$reasoning" "$sandbox" "$max_rework"; then
            scenario_exit=0
        else
            scenario_exit=$?
            overall_status='failed'
            if [[ $scenario_exit -eq 2 ]]; then
                stop_reason='infrastructure_failed'
                echo "Erro: infraestrutura interrompeu $scenario_id; os cenários seguintes não serão executados." >&2
                break
            fi
            if [[ "$fail_fast" == 'true' ]]; then
                stop_reason='fail_fast'
                echo "Erro: --fail-fast interrompeu a execução após $scenario_id." >&2
                break
            fi
        fi
    done < <(jq -c '.scenarios[]' "$contract_file")

    harness_manifest >"$after_manifest"
    if ! cmp -s "$before_manifest" "$after_manifest"; then
        overall_status='failed'
        stop_reason='harness_changed'
        echo "Erro: arquivos do harness mudaram durante a avaliação." >&2
    fi
    completed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    completed_epoch=$(date +%s)

    shopt -s nullglob
    result_files=("$output_root"/scenarios/*/result.json)
    shopt -u nullglob
    [[ ${#result_files[@]} -gt 0 ]] || fail "nenhum resultado de cenário foi produzido."

    jq -s \
        --arg label "$iteration_label" \
        --arg started_at "$started_at" \
        --arg completed_at "$completed_at" \
        --argjson duration_seconds "$((completed_epoch - started_epoch))" \
        --arg git_head "$(git -C "$repo_root" rev-parse HEAD)" \
        --arg codex_version "$actual_version" \
        --arg model "$model" \
        --arg reasoning_effort "$reasoning" \
        --arg sandbox "$sandbox" \
        --arg automatic_status "$overall_status" \
        --arg selected_scenario "$selected_scenario" \
        --arg stop_reason "$stop_reason" \
        --slurpfile contract "$contract_file" \
        --slurpfile preflight "$preflight_file" \
        --rawfile git_status "$git_status_file" \
        --rawfile harness_manifest "$before_manifest" \
        '
        . as $results
        | ($contract[0].scenarios
            | map(select($selected_scenario == "" or .id == $selected_scenario))
            | map(.id)) as $planned
        | {
            label: $label,
            started_at: $started_at,
            completed_at: $completed_at,
            duration_seconds: $duration_seconds,
            git_head: $git_head,
            git_status_before: ($git_status | split("\n") | map(select(length > 0))),
            codex_version: $codex_version,
            model: $model,
            reasoning_effort: $reasoning_effort,
            sandbox: $sandbox,
            automatic_status: $automatic_status,
            censored_by_fail_fast: ($stop_reason == "fail_fast"),
            stop_reason: (if $stop_reason == "" then null else $stop_reason end),
            preflight: $preflight[0],
            harness_manifest: ($harness_manifest | split("\n") | map(select(length > 0))),
            scenario_plan: ($planned | map(. as $id | {
                scenario_id: $id,
                status: (($results | map(select(.scenario_id == $id)) | .[0].automatic_status) // "skipped")
            })),
            scenarios: $results,
            totals: {
                planned_scenarios: ($planned | length),
                executed_scenarios: ($results | length),
                skipped_scenarios: (($planned | length) - ($results | length)),
                attempts: ([$results[].attempts] | add // 0),
                rework_turns: ([$results[].rework_turns] | add // 0),
                input_tokens: ([$results[].usage.input_tokens] | add // 0),
                cached_input_tokens: ([$results[].usage.cached_input_tokens] | add // 0),
                cache_write_input_tokens: ([$results[].usage.cache_write_input_tokens] | add // 0),
                uncached_input_tokens: ([$results[].usage.uncached_input_tokens] | add // 0),
                output_tokens: ([$results[].usage.output_tokens] | add // 0),
                reasoning_output_tokens: ([$results[].usage.reasoning_output_tokens] | add // 0),
                scenario_duration_seconds: ([$results[].duration_seconds] | add // 0),
                command_count: ([$results[].command_metrics.count] | add // 0),
                command_output_chars: ([$results[].command_metrics.output_chars] | add // 0)
            }
        }' "${result_files[@]}" >"$output_root/summary.json"

    echo "Resumo: $output_root/summary.json"
    [[ "$overall_status" == 'passed' ]]
}

write_batch_summary() {
    local output_file=$1
    local label=$2
    local repeat=$3
    local preflight_file=$4
    shift 4
    local summary_files=("$@")

    jq -s \
        --arg label "$label" \
        --argjson planned_repetitions "$repeat" \
        --slurpfile preflight "$preflight_file" '
        def stats($values):
            ($values | sort) as $sorted
            | ($sorted | length) as $count
            | if $count == 0 then null else {
                min: $sorted[0],
                median: (if ($count % 2) == 1
                    then $sorted[($count / 2 | floor)]
                    else (($sorted[$count / 2 - 1] + $sorted[$count / 2]) / 2)
                end),
                max: $sorted[-1]
            } end;
        {
            label: $label,
            planned_repetitions: $planned_repetitions,
            executed_repetitions: length,
            automatic_status: (if length == $planned_repetitions and all(.automatic_status == "passed") then "passed" else "failed" end),
            censored: (length != $planned_repetitions or any(.censored_by_fail_fast)),
            preflight: $preflight[0],
            runs: map({label, automatic_status, censored_by_fail_fast, totals}),
            statistics: {
                duration_seconds: stats(map(.duration_seconds)),
                input_tokens: stats(map(.totals.input_tokens)),
                cached_input_tokens: stats(map(.totals.cached_input_tokens)),
                uncached_input_tokens: stats(map(.totals.uncached_input_tokens)),
                output_tokens: stats(map(.totals.output_tokens)),
                reasoning_output_tokens: stats(map(.totals.reasoning_output_tokens)),
                command_output_chars: stats(map(.totals.command_output_chars)),
                attempts: stats(map(.totals.attempts))
            }
        }' "${summary_files[@]}" >"$output_file"
}

run_baseline() {
    local label=''
    local output_dir=''
    local selected_scenario=''
    local repeat=1
    local fail_fast='false'
    local codex_bin=''
    local actual_version=''
    local expected_version
    local model
    local reasoning
    local sandbox
    local max_rework
    local output_real
    local before_manifest
    local preflight_file
    local preflight_started_at
    local preflight_started_epoch
    local preflight_completed_at
    local preflight_completed_epoch
    local iteration
    local iteration_label
    local iteration_root
    local iteration_exit
    local overall_status='passed'
    local summary_files=()

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
            --repeat)
                [[ $# -ge 2 ]] || fail "--repeat exige valor."
                repeat=$2
                shift 2
                ;;
            --fail-fast)
                fail_fast='true'
                shift
                ;;
            --contract)
                [[ $# -ge 2 ]] || fail "--contract exige valor."
                select_contract "$2"
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
    [[ "$repeat" =~ ^[1-9][0-9]*$ && $repeat -le 20 ]] \
        || fail "--repeat deve ser inteiro entre 1 e 20."

    require_command jq
    require_command git
    require_command sha256sum
    require_command realpath
    mkdir -p "$output_dir"
    output_real=$(realpath -m -- "$output_dir")
    case "$output_real" in
        "$repo_root"|"$repo_root"/*)
            fail "o diretório de saída deve ficar fora do repositório."
            ;;
    esac
    if find "$output_real" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
        fail "o diretório de saída deve estar vazio para evitar resultados herdados."
    fi

    if [[ -n "$selected_scenario" ]] \
        && ! jq -e --arg id "$selected_scenario" 'any(.scenarios[]; .id == $id)' "$contract_file" >/dev/null; then
        fail "cenário desconhecido: $selected_scenario"
    fi

    preflight_file="$output_real/preflight.json"
    preflight_started_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    preflight_started_epoch=$(date +%s)
    if ! codex_bin=$(resolve_codex); then
        preflight_completed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        preflight_completed_epoch=$(date +%s)
        write_preflight_result "$preflight_file" "$preflight_started_at" "$preflight_completed_at" \
            "$((preflight_completed_epoch - preflight_started_epoch))" failed CODEX-MISSING ''
        return 1
    fi
    expected_version=$(jq -r '.expected_codex_version' "$contract_file")
    actual_version=$("$codex_bin" --version)
    if [[ "$actual_version" != "$expected_version" ]]; then
        preflight_completed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        preflight_completed_epoch=$(date +%s)
        write_preflight_result "$preflight_file" "$preflight_started_at" "$preflight_completed_at" \
            "$((preflight_completed_epoch - preflight_started_epoch))" failed CODEX-VERSION "$actual_version"
        echo "Erro: versão do Codex diverge do contrato: esperado '$expected_version', obtido '$actual_version'." >&2
        return 1
    fi
    if ! bash "$repo_root/scripts/validar-harness.sh" check >/dev/null; then
        preflight_completed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        preflight_completed_epoch=$(date +%s)
        write_preflight_result "$preflight_file" "$preflight_started_at" "$preflight_completed_at" \
            "$((preflight_completed_epoch - preflight_started_epoch))" failed DETERMINISTIC-GATE "$actual_version"
        echo "Erro: gate determinístico reprovou o preflight." >&2
        return 1
    fi
    preflight_completed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    preflight_completed_epoch=$(date +%s)
    write_preflight_result "$preflight_file" "$preflight_started_at" "$preflight_completed_at" \
        "$((preflight_completed_epoch - preflight_started_epoch))" passed '' "$actual_version"

    model=$(jq -r '.model' "$contract_file")
    reasoning=$(jq -r '.reasoning_effort' "$contract_file")
    sandbox=$(jq -r '.sandbox' "$contract_file")
    max_rework=$(jq -r '.max_rework' "$contract_file")
    before_manifest="$output_real/harness-before.sha256"
    harness_manifest >"$before_manifest"
    git -C "$repo_root" status --short >"$output_real/git-status-before.txt"

    for ((iteration = 1; iteration <= repeat; iteration++)); do
        if [[ $repeat -eq 1 ]]; then
            iteration_label=$label
            iteration_root=$output_real
        else
            printf -v iteration_label '%s-%03d' "$label" "$iteration"
            printf -v iteration_root '%s/run-%03d' "$output_real" "$iteration"
        fi
        if run_iteration "$codex_bin" "$iteration_root" "$iteration_label" "$selected_scenario" \
            "$model" "$reasoning" "$sandbox" "$max_rework" "$fail_fast" "$actual_version" \
            "$preflight_file" "$before_manifest" "$output_real/git-status-before.txt"; then
            iteration_exit=0
        else
            iteration_exit=$?
            overall_status='failed'
        fi
        summary_files+=("$iteration_root/summary.json")
        if [[ $iteration_exit -ne 0 && "$fail_fast" == 'true' ]]; then
            break
        fi
    done

    if [[ $repeat -gt 1 ]]; then
        write_batch_summary "$output_real/batch-summary.json" "$label" "$repeat" "$preflight_file" \
            "${summary_files[@]}"
        echo "Resumo do lote: $output_real/batch-summary.json"
        if [[ $(jq -r '.automatic_status' "$output_real/batch-summary.json") != 'passed' ]]; then
            overall_status='failed'
        fi
    fi

    [[ "$overall_status" == 'passed' ]]
}

main() {
    [[ $# -gt 0 ]] || { usage; exit 1; }

    case "$1" in
        self-test)
            shift
            if [[ $# -gt 0 ]]; then
                [[ $# -eq 2 && "$1" == "--contract" ]] || fail "self-test aceita somente --contract ARQUIVO."
                select_contract "$2"
            fi
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
