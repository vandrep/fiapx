#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

usage() {
    cat <<'EOF'
Uso:
  scripts/validar-harness.sh check
  scripts/validar-harness.sh self-test

check executa todos os gates determinísticos e seus contrafactuais.
self-test executa somente os contrafactuais do contrato de conhecimento.
EOF
}

fail() {
    echo "Erro: $1" >&2
    exit 1
}

expect_failure() {
    local label=$1
    shift

    if "$@" >/dev/null 2>&1; then
        fail "contrafactual foi aceito: $label."
    fi
}

knowledge_self_test() (
    local test_tmp
    test_tmp=$(mktemp -d)
    trap 'rm -rf -- "$test_tmp"' EXIT

    mkdir -p "$test_tmp/docs/avaliacoes/harness/prompts"
    cp "$repo_root/AGENTS.md" "$test_tmp/AGENTS.md"
    cp "$repo_root/ARCHITECTURE.md" "$test_tmp/ARCHITECTURE.md"
    cp "$repo_root/README.md" "$test_tmp/README.md"
    cp "$repo_root/docs/avaliacoes/harness/prompts/architecture-map.md" \
        "$test_tmp/docs/avaliacoes/harness/prompts/architecture-map.md"

    "$repo_root/scripts/validar-mapa-arquitetural.sh" "$test_tmp" >/dev/null

    rm -- "$test_tmp/ARCHITECTURE.md"
    expect_failure "mapa raiz ausente" "$repo_root/scripts/validar-mapa-arquitetural.sh" "$test_tmp"
    cp "$repo_root/ARCHITECTURE.md" "$test_tmp/ARCHITECTURE.md"

    sed -i 's/(ARCHITECTURE.md)/(ARQUITETURA.md)/' "$test_tmp/README.md"
    expect_failure "link de entrada quebrado" "$repo_root/scripts/validar-mapa-arquitetural.sh" "$test_tmp"
    cp "$repo_root/README.md" "$test_tmp/README.md"

    sed -i 's/\*\*Em análise:\*\* aceite durável/\*\*Decidido:\*\* aceite durável/' "$test_tmp/ARCHITECTURE.md"
    expect_failure "decisão em análise promovida" "$repo_root/scripts/validar-mapa-arquitetural.sh" "$test_tmp"
    cp "$repo_root/ARCHITECTURE.md" "$test_tmp/ARCHITECTURE.md"

    sed -i 's#../../../../ARCHITECTURE.md#../../../ARCHITECTURE.md#' \
        "$test_tmp/docs/avaliacoes/harness/prompts/architecture-map.md"
    expect_failure "link do cenário com profundidade incorreta" \
        "$repo_root/scripts/validar-mapa-arquitetural.sh" "$test_tmp"

    echo "Contrafactuais do conhecimento válidos: ausência, links quebrados e promoção indevida foram rejeitados."
)

run_checks() {
    bash "$repo_root/scripts/validar-mapa-arquitetural.sh"
    bash "$repo_root/scripts/avaliar-harness.sh" self-test
    bash "$repo_root/scripts/avaliar-harness.sh" self-test --contract scenarios-v2.json
    bash "$repo_root/scripts/validar-contexto.sh"
    knowledge_self_test
    echo "Harness válido: mapa, contratos v1/v2, documentação, contexto e contrafactuais aprovados."
}

main() {
    [[ $# -eq 1 ]] || { usage >&2; exit 1; }

    case "$1" in
        check)
            run_checks
            ;;
        self-test)
            knowledge_self_test
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
