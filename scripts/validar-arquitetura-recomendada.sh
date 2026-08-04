#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
architecture="$repo_root/docs/arquitetura/comparacao-e-arquitetura-recomendada.md"
component_model="$repo_root/docs/arquitetura/componentes-coesos.md"
canonical_stories="$repo_root/docs/requisitos/historias.md"
proposal_stories="$repo_root/docs/propostas/base-simplificada-seis-componentes/historias.md"
delivery_decision="$repo_root/docs/arquitetura/decisoes/0003-entrega-duravel-e-persistencia.md"
topology_decision="$repo_root/docs/arquitetura/decisoes/0002-topologia-kubernetes.md"

for document in "$architecture" "$component_model" "$canonical_stories" "$proposal_stories" "$delivery_decision" "$topology_decision"; do
    if [[ ! -e "$document" ]]; then
        echo "Erro: artefato necessário à validação da arquitetura inexistente: ${document#"$repo_root/"}." >&2
        exit 1
    fi
done

# shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
required_delivery_authorities=(
    'status: em_analise'
    'emitem apenas `FalhaTecnicaDaTentativa` ou `FalhaTecnicaDaPublicacao`'
    'sem classificar a falha nem criar outra tentativa.'
    'Como único escritor, conclui o trabalho ou classifica a falha segundo sua política'
    'somente depois do estado terminal publica `TrabalhoFalhou` mínimo e sanitizado'
)
for authority in "${required_delivery_authorities[@]}"; do
    if ! grep -Fq "$authority" "$delivery_decision"; then
        echo "Erro: DEC-0003 perdeu uma autoridade do fluxo de falha e retry: $authority" >&2
        exit 1
    fi
done

# shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
if grep -Fq 'Falha permanente ou esgotamento do ciclo produz fato `ProcessingFailed`' "$delivery_decision"; then
    echo "Erro: DEC-0003 atribui classificação de falha permanente fora do Ciclo do Trabalho." >&2
    exit 1
fi

# shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
if ! grep -Fq 'a escolha e a semântica ainda dependem da prova de `DEC-0003`' "$topology_decision"; then
    echo "Erro: DEC-0002 antecipou a decisão física ainda aberta em DEC-0003." >&2
    exit 1
fi

premature_choices=(
    'RabbitMQ escolhido'
    'PostgreSQL escolhido'
    'GitHub Actions escolhido'
)
for choice in "${premature_choices[@]}"; do
    if grep -Fq "$choice" "$architecture"; then
        echo "Erro: tecnologia ainda em análise foi registrada como escolhida: $choice" >&2
        exit 1
    fi
done

expected_components=$(sed -n '/^entities:$/,/^relations:$/ s/^  - \(CMP-[0-9][0-9]*\)$/\1/p' "$component_model" | sort)
documented_components=$(sed -n 's/^### \(CMP-[0-9][0-9]*\) —.*/\1/p' "$architecture" | sort)
component_count=$(grep -c '^CMP-' <<<"$expected_components" || true)

if [[ $component_count -ne 8 || "$documented_components" != "$expected_components" ]]; then
    echo "Erro: a definição recomendada diverge do inventário de oito componentes de CTX-CMP-003." >&2
    diff -u <(printf '%s\n' "$expected_components") <(printf '%s\n' "$documented_components") >&2 || true
    exit 1
fi

assignment_section=$(awk '
    /^## Atribuição final das histórias canônicas$/ { inside = 1; next }
    inside && /^## / { exit }
    inside { print }
' "$architecture")

expected_stories=$(sed -n '/^entities:$/,/^relations:$/ s/^  - \(US-[0-9][0-9]*\)$/\1/p' "$canonical_stories" | sort)
# shellcheck disable=SC2016 # Backticks are literais Markdown, não substituição de comando.
assigned_stories=$(sed -n 's/^| `\(US-[0-9][0-9]*\)` |.*/\1/p' <<<"$assignment_section" | sort)

if [[ "$assigned_stories" != "$expected_stories" ]]; then
    echo "Erro: as histórias canônicas não possuem exatamente um responsável final." >&2
    diff -u <(printf '%s\n' "$expected_stories") <(printf '%s\n' "$assigned_stories") >&2 || true
    exit 1
fi

if grep -Fq 'R6-US-' <<<"$assignment_section"; then
    echo "Erro: uma formulação R6 foi promovida à atribuição canônica." >&2
    exit 1
fi

while IFS= read -r component_id; do
    [[ -z "$component_id" ]] && continue
    if ! grep -Fq "\`$component_id\`" <<<"$assignment_section"; then
        echo "Erro: componente ativo sem rastreabilidade na atribuição final: $component_id." >&2
        exit 1
    fi
done <<<"$expected_components"

r6_section=$(awk '
    /^## Rastreabilidade das formulações R6$/ { inside = 1; next }
    inside && /^## / { exit }
    inside { print }
' "$architecture")
expected_r6_stories=$(sed -n '/^entities:$/,/^relations:$/ s/^  - \(R6-US-[0-9][0-9]*\)$/\1/p' "$proposal_stories" | sort)
# shellcheck disable=SC2016 # Backticks are literais Markdown, não substituição de comando.
mapped_r6_stories=$(sed -n 's/^| `\(R6-US-[0-9][0-9]*\)` |.*/\1/p' <<<"$r6_section" | sort)

if [[ "$mapped_r6_stories" != "$expected_r6_stories" ]]; then
    echo "Erro: nem todas as formulações R6 possuem destino explícito." >&2
    diff -u <(printf '%s\n' "$expected_r6_stories") <(printf '%s\n' "$mapped_r6_stories") >&2 || true
    exit 1
fi

for future_id in R6-US-04 R6-US-08 R6-US-09 R6-US-10; do
    future_row=$(grep -F "| \`$future_id\` |" <<<"$r6_section" || true)
    if [[ -z "$future_row" || ! "$future_row" =~ futur ]]; then
        echo "Erro: extensão $future_id não está preservada explicitamente como futura." >&2
        exit 1
    fi
done

# shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
r6_detail_row=$(grep -F '| `R6-US-06` |' <<<"$r6_section" || true)
if [[ -z "$r6_detail_row" || "$r6_detail_row" != *'A confirmar'* ]]; then
    echo "Erro: R6-US-06 deve permanecer A confirmar." >&2
    exit 1
fi

expected_requirements=$(for number in $(seq 1 24); do printf 'EN-%02d\n' "$number"; done)
documented_requirements=$(sed -n 's/^| \(EN-[0-9][0-9]\) |.*/\1/p' "$architecture" | sort)
if [[ "$documented_requirements" != "$expected_requirements" ]]; then
    echo "Erro: a matriz não cobre exatamente EN-01..EN-24." >&2
    exit 1
fi

quanta_section=$(awk '
    /^## Quanta, processos e serviços$/ { inside = 1; next }
    inside && /^## / { exit }
    inside { print }
' "$architecture")

required_quanta=(
    'Gestão de Trabalhos de Vídeo'
    'Produção de Resultados'
    'Comunicação de Falhas'
)
# shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
required_deployments=(
    '`gestao-trabalhos`'
    '`producao-resultados`'
    '`notificador`'
)

for quantum in "${required_quanta[@]}"; do
    if ! grep -Fq "| $quantum |" <<<"$quanta_section"; then
        echo "Erro: quantum decidido ausente da arquitetura: $quantum." >&2
        exit 1
    fi
done

for deployment in "${required_deployments[@]}"; do
    if ! grep -Fq "$deployment" <<<"$quanta_section"; then
        echo "Erro: deployment decidido ausente da arquitetura: $deployment." >&2
        exit 1
    fi
done

quantum_count=$(grep -Ec '^\| (Gestão de Trabalhos de Vídeo|Produção de Resultados|Comunicação de Falhas) \|' <<<"$quanta_section" || true)
if [[ $quantum_count -ne 3 ]]; then
    echo "Erro: esperados três quanta decididos; encontrados $quantum_count." >&2
    exit 1
fi

if grep -Eq '^\|.*Keycloak.*\|$' <<<"$quanta_section"; then
    echo "Erro: Keycloak foi contado como quantum da aplicação." >&2
    exit 1
fi

required_guardrails=(
    'Kubernetes decidido'
    'Submissão nunca aciona Processamento nem Comunicação de Falhas'
    'é a única autoridade e o único escritor do estado do trabalho'
    '(issuer, subject)'
    'somente Ciclo decide retry e estado'
    'at-least-once'
    'Redis não é incluído sem necessidade medida'
    'não transforma os oito componentes em oito microsserviços'
    'não são quanta da aplicação'
    'Deployment Keycloak'
)
for guardrail in "${required_guardrails[@]}"; do
    if ! grep -Fq "$guardrail" "$architecture"; then
        echo "Erro: salvaguarda arquitetural ausente: $guardrail." >&2
        exit 1
    fi
done

mermaid_open=0
while IFS= read -r line; do
    if [[ "$line" == '```mermaid' ]]; then
        if [[ $mermaid_open -eq 1 ]]; then
            echo "Erro: bloco Mermaid aninhado na arquitetura recomendada." >&2
            exit 1
        fi
        mermaid_open=1
    elif [[ "$line" == '```' && $mermaid_open -eq 1 ]]; then
        mermaid_open=0
    fi
done <"$architecture"
if [[ $mermaid_open -ne 0 ]]; then
    echo "Erro: bloco Mermaid não encerrado na arquitetura recomendada." >&2
    exit 1
fi

while IFS= read -r raw_target; do
    target=${raw_target#*](}
    target=${target%)}
    target=${target%%#*}
    [[ -z "$target" ]] && continue
    [[ "$target" == http://* || "$target" == https://* ]] && continue
    if [[ ! -e "$(dirname "$architecture")/$target" ]]; then
        echo "Erro: link local inexistente na arquitetura recomendada: $target" >&2
        exit 1
    fi
done < <(grep -oE '\]\([^)]*\)' "$architecture" || true)

echo "Arquitetura recomendada válida: 7 histórias, 10 formulações R6, 8 componentes, 24 requisitos, 3 quanta e Keycloak de plataforma verificados."
