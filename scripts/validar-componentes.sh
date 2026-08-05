#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
component_model="$repo_root/docs/arquitetura/componentes-coesos.md"
historical_component_model="$repo_root/docs/arquitetura/componentes.md"
macro_component_model="$repo_root/docs/arquitetura/componentes-macro.md"
stories="$repo_root/docs/requisitos/historias.md"
characteristics="$repo_root/docs/arquitetura/caracteristicas.md"
component_decision="$repo_root/docs/arquitetura/decisoes/0001-refinamento-de-componentes.md"
glossary="$repo_root/docs/requisitos/glossario.md"
outcome_log="$repo_root/docs/acompanhamento/realizacoes.md"

for document in "$component_model" "$historical_component_model" "$macro_component_model" "$stories" "$characteristics" "$component_decision" "$glossary" "$outcome_log"; do
    if [[ ! -e "$document" ]]; then
        echo "Erro: artefato necessário à validação de componentes inexistente: ${document#"$repo_root/"}." >&2
        exit 1
    fi
done

# shellcheck disable=SC2016 # Backticks são literais Markdown.
historical_model_guardrails=(
    '## Riscos, fitness functions e próximo incremento então proposto'
    'Na verificação de 2026-08-02, o inventário modular convergia'
    'Em 2026-08-03, ele foi substituído pelo [`CTX-CMP-003`](componentes-coesos.md)'
    'Em 2026-08-02, o incremento seguinte proposto era o Threat Modeling'
    'O [roadmap ativo](../acompanhamento/roadmap.md) e o [`CTX-CMP-003`](componentes-coesos.md) contêm a orientação vigente.'
)
for guardrail in "${historical_model_guardrails[@]}"; do
    if ! grep -Fq "$guardrail" "$historical_component_model"; then
        echo "Erro: CTX-CMP-002 perdeu a qualificação temporal: $guardrail" >&2
        exit 1
    fi
done

# shellcheck disable=SC2016 # Backticks são literais Markdown.
macro_model_guardrails=(
    'o modelo ativo é [`CTX-CMP-003`](componentes-coesos.md)'
    '“corrente” significa vigente na iteração registrada em 2026-08-01'
    '## Diagrama lógico do modelo então corrente (`CTX-CMP-001`)'
    'Como este nó hoje está `substituido`, evidência nova deve alimentar um novo refinamento ou nó sucessor'
    '## Menor próximo incremento proposto naquele estágio'
    'A sequência vigente pertence ao [roadmap ativo](../acompanhamento/roadmap.md).'
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
if ! grep -Fq 'o modelo então vigente [`CTX-CMP-001`](../arquitetura/componentes-macro.md) ganhou' "$outcome_log" \
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

# shellcheck disable=SC2016 # Backticks são literais Markdown.
if ! grep -Fq 'O [roadmap ativo](../acompanhamento/roadmap.md) é a única fonte do próximo trabalho.' "$component_model" \
    || ! grep -Fq '[threat modeling de `WORK-011`](../acompanhamento/roadmap.md#work-011--executar-threat-modeling-inicial)' "$component_model" \
    || grep -Fq 'O menor próximo incremento é implementar' "$component_model"; then
    echo "Erro: modelo de componentes diverge da sequência de trabalho vigente no roadmap." >&2
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
    "## Agrupamentos de quanta para validação"
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
        echo "Erro: histórias sem responsável principal único em $heading." >&2
        diff -u <(printf '%s\n' "$expected_stories") <(printf '%s\n' "$assigned_stories") >&2 || true
        exit 1
    fi
}

validate_assignment_section \
    "## Iteração 1 — Histórias atribuídas" \
    "## Iteração 1 — Papéis e responsabilidades analisados"
validate_assignment_section \
    "## Iteração 2 — Histórias atribuídas" \
    "## Iteração 2 — Papéis e responsabilidades analisados"

expected_components=$(sed -n '/^entities:/,/^relations:/ s/^  - \(CMP-[0-9][0-9]*\)$/\1/p' "$component_model" | sort)
documented_components=$(sed -n 's/^### \(CMP-[0-9][0-9]*\) —.*/\1/p' "$component_model" | sort)
component_count=$(grep -c '^CMP-' <<<"$expected_components" || true)

if [[ $component_count -ne 8 || "$documented_components" != "$expected_components" ]]; then
    echo "Erro: metadados e inventário do modelo ativo devem conter os mesmos oito componentes." >&2
    diff -u <(printf '%s\n' "$expected_components") <(printf '%s\n' "$documented_components") >&2 || true
    exit 1
fi

refactoring_section=$(awk '
    /^## Iteração 1 — Refatoração motivada$/ { inside = 1; next }
    /^## Iteração 2 — Componentes identificados$/ { exit }
    inside { print }
' "$component_model")

while IFS= read -r component_id; do
    [[ -z "$component_id" ]] && continue
    if ! grep -Fq "$component_id" <<<"$refactoring_section"; then
        echo "Erro: $component_id não possui motivação na refatoração." >&2
        exit 1
    fi
done <<<"$expected_components"

quantum_section=$(awk '
    /^## Agrupamentos de quanta para validação$/ { inside = 1; next }
    inside && /^## / { exit }
    inside { print }
' "$component_model")

# shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
quantum_count=$(grep -Fc '| `selecionado_para_validacao` |' <<<"$quantum_section" || true)
if [[ $quantum_count -ne 3 ]]; then
    echo "Erro: esperados três quanta selecionados para validação; encontrados $quantum_count." >&2
    exit 1
fi

required_quanta=(
    '**Gestão de Trabalhos de Vídeo**'
    '**Produção de Resultados**'
    '**Comunicação de Falhas**'
)
# shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
required_deployments=(
    '`gestao-trabalhos`'
    '`producao-resultados`'
    '`notificador`'
)

for quantum in "${required_quanta[@]}"; do
    if ! grep -Fq "$quantum" <<<"$quantum_section"; then
        echo "Erro: quantum decidido ausente do modelo ativo: $quantum." >&2
        exit 1
    fi
done

for deployment in "${required_deployments[@]}"; do
    if ! grep -Fq "$deployment" <<<"$quantum_section"; then
        echo "Erro: deployment decidido ausente do modelo ativo: $deployment." >&2
        exit 1
    fi
done

if grep -Eq '^\|.*Keycloak.*\|$' <<<"$quantum_section"; then
    echo "Erro: Keycloak foi contado como quantum da aplicação." >&2
    exit 1
fi

# shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
required_authorities=(
    'Keycloak autentica credenciais e emite tokens.'
    'este componente não fornece um `ExigirProprietario` genérico.'
    'É a única autoridade e o único escritor do estado do trabalho.'
    'não a classifica como transitória/permanente para o negócio'
    '`CMP-21/22` relatam falha técnica; somente `CMP-20` decide política e estado'
    'registra o resultado da entrega sem alterar o trabalho.'
    'não é componente, quantum nem serviço de negócio do FIAP X.'
)

for authority in "${required_authorities[@]}"; do
    if ! grep -Fq "$authority" "$component_model"; then
        echo "Erro: autoridade ou salvaguarda arquitetural ausente: $authority" >&2
        exit 1
    fi
done

echo "Refinamento de componentes válido: ciclo ordenado, 7 histórias, 8 componentes, 3 quanta e autoridades verificadas."
