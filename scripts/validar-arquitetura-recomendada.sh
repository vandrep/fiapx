#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
architecture="$repo_root/docs/arquitetura/comparacao-e-arquitetura-recomendada.md"
component_model="$repo_root/docs/arquitetura/componentes-coesos.md"
proposal_stories="$repo_root/docs/propostas/base-simplificada-seis-componentes/historias.md"
delivery_decision="$repo_root/docs/arquitetura/decisoes/0003-entrega-duravel-e-persistencia.md"
topology_decision="$repo_root/docs/arquitetura/decisoes/0002-topologia-kubernetes.md"

for document in "$architecture" "$component_model" "$proposal_stories" "$delivery_decision" "$topology_decision"; do
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

# shellcheck disable=SC2016 # Backticks são literais Markdown.
temporal_guardrails=(
    '## Snapshot Git da comparação histórica'
    'Commit da proposta comparada'
    'o commit `8969141` não alterou a arquitetura então vigente'
    'O [roadmap ativo](../acompanhamento/roadmap.md) é a única fonte da sequência e do próximo trabalho'
    'Toda esta seção elabora a candidata física de [`DEC-0003`]'
)
for guardrail in "${temporal_guardrails[@]}"; do
    if ! grep -Fq "$guardrail" "$architecture"; then
        echo "Erro: arquitetura perdeu uma salvaguarda temporal ou de autoridade: $guardrail" >&2
        exit 1
    fi
done

obsolete_claims=(
    'git rev-parse HEAD'
    'o último commit não alterou'
    'criar módulos Java/Quarkus mínimos'
    'Entre processos, ordens e fatos passam por RabbitMQ'
)
for claim in "${obsolete_claims[@]}"; do
    if grep -Fq "$claim" "$architecture"; then
        echo "Erro: arquitetura contém afirmação móvel, superada ou prematura: $claim" >&2
        exit 1
    fi
done

expected_components=$(printf 'CMP-%s\n' {18..25})
canonical_metadata_components=$(sed -n '/^entities:$/,/^relations:$/ s/^  - \(CMP-[0-9][0-9]*\)$/\1/p' "$component_model" | sort)
canonical_documented_components=$(sed -n 's/^### \(CMP-[0-9][0-9]*\) —.*/\1/p' "$component_model" | sort)
if [[ "$canonical_metadata_components" != "$expected_components" || "$canonical_documented_components" != "$expected_components" ]]; then
    echo "Erro: a fonte canônica deve definir exatamente CMP-18..25." >&2
    exit 1
fi

expected_historical_labels=$(for number in $(seq 1 8); do printf 'AR-CMP-%02d\n' "$number"; done)
metadata_historical_labels=$(sed -n '/^entities:$/,/^relations:$/ s/^  - \(AR-CMP-[0-9][0-9]*\)$/\1/p' "$architecture" | sort)
if [[ "$metadata_historical_labels" != "$expected_historical_labels" ]]; then
    echo "Erro: os metadados da comparação devem preservar exatamente AR-CMP-01..08." >&2
    exit 1
fi

mapping_section=$(awk '
    /^## Mapeamento histórico do inventário comparativo$/ { inside = 1; next }
    inside && /^## / { exit }
    inside { print }
' "$architecture")

# shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
mapped_historical_labels=$(sed -n 's/^| <a id="ar-cmp-[^"]*"><\/a>`\(AR-CMP-[0-9][0-9]*\)` |.*/\1/p' <<<"$mapping_section" | sort)
if [[ "$mapped_historical_labels" != "$expected_historical_labels" ]]; then
    echo "Erro: o mapeamento deve conter exatamente AR-CMP-01..08." >&2
    exit 1
fi

for number in $(seq 1 8); do
    printf -v suffix '%02d' "$number"
    historical_id="AR-CMP-$suffix"
    component_id="CMP-$((number + 17))"
    mapping_prefix="<a id=\"ar-cmp-$suffix\"></a>\`$historical_id\`"
    mapping_count=$(grep -Fc "$mapping_prefix" <<<"$mapping_section" || true)
    mapping_row=$(grep -F "$mapping_prefix" <<<"$mapping_section" || true)
    if [[ $mapping_count -ne 1 || "$mapping_row" != *"componentes-coesos.md#cmp-$((number + 17))"* ]]; then
        echo "Erro: $historical_id deve mapear, na mesma linha, para o link canônico de $component_id." >&2
        exit 1
    fi
done

if grep -Eq '^### CMP-[0-9]+' "$architecture"; then
    echo "Erro: a comparação voltou a definir blocos CMP-* e criou uma segunda fonte de verdade." >&2
    exit 1
fi

if grep -Fqx '## Atribuição final das histórias canônicas' "$architecture" \
    || ! grep -Fq 'componentes-coesos.md#hist%C3%B3rias-atribu%C3%ADdas' <<<"$mapping_section"; then
    echo "Erro: a atribuição final deve permanecer somente no modelo canônico, referenciado pela comparação." >&2
    exit 1
fi

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

topology_section=$(awk '
    /^## Decisão$/ { inside = 1; next }
    inside && /^## / { exit }
    inside { print }
' "$topology_decision")

# shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
required_topology_rows=(
    '| Gestão de Trabalhos de Vídeo | `gestao-trabalhos` |'
    '| Produção de Resultados | `producao-resultados` |'
    '| Comunicação de Falhas | `notificador` |'
)

for topology_row in "${required_topology_rows[@]}"; do
    if ! grep -Fq "$topology_row" <<<"$topology_section"; then
        echo "Erro: quantum e Deployment decididos ausentes de DEC-0002: $topology_row" >&2
        exit 1
    fi
done

quantum_count=$(grep -Ec '^\| (Gestão de Trabalhos de Vídeo|Produção de Resultados|Comunicação de Falhas) \|' <<<"$topology_section" || true)
topology_row_count=$(awk '
    /^\| Quantum \| Deployment \|/ { in_table = 1; next }
    in_table && /^\|---/ { next }
    in_table && /^\|/ { count++; next }
    in_table { exit }
    END { print count + 0 }
' <<<"$topology_section")
if [[ $quantum_count -ne 3 || $topology_row_count -ne 3 ]]; then
    echo "Erro: DEC-0002 deve decidir exatamente os três quanta esperados; encontrados $topology_row_count registros." >&2
    exit 1
fi

if grep -Eq '^\|.*Keycloak.*\|$' <<<"$topology_section"; then
    echo "Erro: DEC-0002 contou Keycloak como quantum da aplicação." >&2
    exit 1
fi

required_architecture_guardrails=(
    'Kubernetes decidido'
    '(issuer, subject)'
    'at-least-once'
    'Redis não é incluído sem necessidade medida'
    'não transforma os oito componentes em oito microsserviços'
    'não são quanta da aplicação'
    'Deployment Keycloak'
)
for guardrail in "${required_architecture_guardrails[@]}"; do
    if ! grep -Fq "$guardrail" "$architecture"; then
        echo "Erro: salvaguarda arquitetural ausente: $guardrail." >&2
        exit 1
    fi
done

# Autoridades lógicas são verificadas na fonte canônica, não na comparação.
# shellcheck disable=SC2016 # Backticks are Markdown literals, not expansion.
required_component_guardrails=(
    'Submissão nunca aciona Processamento nem Comunicação de Falhas'
    'É a única autoridade e o único escritor do estado do trabalho'
    '`CMP-21/22` relatam falha técnica; somente `CMP-20` decide política e estado'
)
for guardrail in "${required_component_guardrails[@]}"; do
    if ! grep -Fq "$guardrail" "$component_model"; then
        echo "Erro: salvaguarda do componente ausente da fonte canônica: $guardrail." >&2
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

echo "Arquitetura recomendada válida: 10 formulações R6, 8 mapeamentos AR-CMP canônicos, 24 requisitos e 3 quanta em DEC-0002 verificados."
