#!/usr/bin/env bash

set -euo pipefail

default_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
validation_root=${1:-$default_root}
architecture="$validation_root/ARCHITECTURE.md"
agents="$validation_root/AGENTS.md"
readme="$validation_root/README.md"
architecture_prompt="$validation_root/docs/avaliacoes/harness/prompts/architecture-map.md"

fail() {
    echo "Erro: $1" >&2
    exit 1
}

[[ -f "$architecture" ]] || fail "ARCHITECTURE.md deve existir na raiz como mapa arquitetural."
[[ -f "$agents" ]] || fail "AGENTS.md ausente na raiz."
[[ -f "$readme" ]] || fail "README.md ausente na raiz."

# shellcheck disable=SC2016 # Backticks são literais Markdown, não expansão do shell.
grep -Fq '[`ARCHITECTURE.md`](ARCHITECTURE.md)' "$agents" \
    || fail "AGENTS.md deve apontar para ARCHITECTURE.md."
grep -Fq 'não é leitura obrigatória para tarefas sem impacto arquitetural' "$agents" \
    || fail "AGENTS.md deve preservar divulgação progressiva para o mapa arquitetural."
grep -Fq '[mapa arquitetural da raiz](ARCHITECTURE.md)' "$readme" \
    || fail "README.md deve tornar ARCHITECTURE.md descobrível."

# shellcheck disable=SC2016 # Backticks são literais Markdown, não expansão do shell.
required_map_statements=(
    '**Observado:** a aplicação-alvo ainda não existe'
    '**Decidido:** o núcleo possui oito componentes lógicos'
    '**Decidido:** a validação usa três quanta Kubernetes'
    '**Em análise:** aceite durável'
    '**Preferência:** Java com Quarkus continua sendo preferência declarada'
    '[`CTX-CMP-003`](docs/arquitetura/componentes-coesos.md)'
    '[`DEC-0002`](docs/arquitetura/decisoes/0002-topologia-kubernetes.md)'
    '[`DEC-0003`](docs/arquitetura/decisoes/0003-entrega-duravel-e-persistencia.md)'
    '[`DEC-0004`](docs/arquitetura/decisoes/0004-componentes-coesos-do-nucleo.md)'
    '[`DEC-0005`](docs/arquitetura/decisoes/0005-keycloak-no-ambiente-de-validacao.md)'
)

for statement in "${required_map_statements[@]}"; do
    grep -Fq "$statement" "$architecture" \
        || fail "ARCHITECTURE.md perdeu estado ou autoridade obrigatória: $statement"
done

for component_number in {18..25}; do
    grep -Fq "CMP-$component_number" "$architecture" \
        || fail "ARCHITECTURE.md não lista CMP-$component_number."
done

for quantum in gestao-trabalhos producao-resultados notificador; do
    grep -Fq "$quantum" "$architecture" \
        || fail "ARCHITECTURE.md não lista o quantum $quantum."
done

grep -Fq 'Keycloak, banco, broker, object storage e observabilidade não são componentes nem quanta do FIAP X.' "$architecture" \
    || fail "ARCHITECTURE.md deve separar plataforma de componentes e quanta."

if [[ -f "$architecture_prompt" ]]; then
    # shellcheck disable=SC2016 # Backticks são literais Markdown, não expansão do shell.
    grep -Fq '[`ARCHITECTURE.md`](../../../../ARCHITECTURE.md)' "$architecture_prompt" \
        || fail "o cenário arquitetural deve apontar corretamente da pasta prompts para ARCHITECTURE.md."
fi

echo "Mapa arquitetural válido: estado, autoridades, 8 componentes e 3 quanta verificados."
