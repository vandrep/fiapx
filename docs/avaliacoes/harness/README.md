---
context_id: CTX-EVD-HARNESS-001
context_type: evidence
status: registrado
recorded_at: 2026-08-13
valid_from: 2026-08-13
entities:
  - EVAL-HARNESS-TM-001
  - EVAL-HARNESS-ADR-001
  - EVAL-HARNESS-GRAPH-001
  - EVAL-HARNESS-ARCH-001
relations:
  - type: governed_by
    target: CTX-GOV-001
  - type: governed_by
    target: CTX-GOV-002
  - type: derived_from
    target: CTX-THREAT-001
  - type: informed_by
    target: DEC-0003
  - type: informs
    target: WORK-018
---

# Baseline e contrato de avaliação do harness

> Navegação: [documentação](../../README.md) · [roadmap](../../acompanhamento/roadmap.md) · [Context Graph](../../contexto/README.md)

## Objetivo e limites

Medir o harness vigente antes de reorganizar instruções, agentes, skills, templates ou ferramentas. Os cenários exercitam trabalho real ainda pendente, mas produzem somente respostas estruturadas em sandbox `read-only`: não alteram o modelo de ameaças, não aceitam decisões e não modificam o Context Graph.

A baseline usa uma execução inicial por cenário e até dois turnos de correção na mesma thread. Retrabalho é a quantidade de turnos posteriores à execução inicial necessários para satisfazer o oráculo. A aprovação exige schema válido, todas as asserções determinísticas e revisão semântica do agente principal.

## Configuração congelada

| Parâmetro | Valor |
|---|---|
| Modelo | `gpt-5.6-sol` |
| Esforço de raciocínio | `low` |
| Sandbox | `read-only` |
| Execuções iniciais | uma por cenário |
| Retrabalho máximo | dois turnos |
| Saída | JSON validado por schema e eventos JSONL |
| Contexto auxiliar | itens e caracteres de `codex debug prompt-input`; não substituem tokens reais |

O contrato congelado da baseline está em [`scenarios.json`](scenarios.json); os prompts cobrem [gates P0](prompts/threat-p0-gates.md), [DEC-0003](prompts/adr-0003.md) e [Context Graph](prompts/context-graph-work-017.md); os schemas ficam em [`schemas/`](schemas/). O runner [`scripts/avaliar-harness.sh`](../../../scripts/avaliar-harness.sh) registra tokens de `turn.completed`, fontes declaradas, comandos observados, hashes e resultado das rubricas. Logs completos ficam em diretório externo ao repositório e não integram esta evidência.

As evoluções [v2](v2.md) e [v3](v3.md) ficam separadas desta evidência congelada; v3 experimenta eficiência e isolamento do oráculo sem alterar os contratos históricos. O primeiro resultado de eficiência está em [`CTX-EVD-HARNESS-003`](resultados/eficiencia-v3-2026-08-15.json) e preserva v1/v2 como padrão.

A [telemetria opt-in do agente principal](../../../tools/codex-telemetry/README.md), definida pela [`DEC-0007`](../../arquitetura/decisoes/0007-recibo-pos-execucao-do-agente-principal.md), mede a execução interativa na fronteira do App Server. Seus recibos não substituem as métricas congeladas de uma avaliação nem misturam threads filhas ao agente principal.

## Oráculos congelados

### EVAL-HARNESS-TM-001 — Gates das ameaças P0

- Deve cobrir exatamente `THR-001/002/003/008/009/010/013/014/015`.
- Cada gate preserva `C1`, explicita comportamento verificável, evidência esperada e lacuna ainda aberta.
- Não pode afirmar que controles candidatos foram implementados, que o risco foi reduzido ou que valores operacionais foram confirmados.
- Fontes mínimas: roteador e `CTX-THREAT-001`; enunciado e protótipo Go são contexto vedado.

### EVAL-HARNESS-ADR-001 — Confronto da DEC-0003

- Deve manter `DEC-0003` como `em_analise` e Java/Quarkus como preferência.
- Deve confrontar ao menos `THR-013/014/015`, registrar evidências ausentes e deixar a lista de tecnologias aceitas vazia.
- RabbitMQ, outbox/inbox, PostgreSQL e object storage permanecem recomendação ou realização candidata até as verificações e o aceite.
- Fontes mínimas: roteador, `DEC-0003` e `CTX-THREAT-001`; enunciado e protótipo Go são contexto vedado.
- Pacote suficiente: `AGENTS.md`, roteador, este contrato, `DEC-0003` e `CTX-THREAT-001`; schema, fixture, arquivo de cenários e roadmap não respondem à decisão e só devem ser consultados diante de lacuna concreta.

### EVAL-HARNESS-GRAPH-001 — Registro da evidência e transição do trabalho

- Deve propor `CTX-EVD-HARNESS-001` como nó `evidence` com status `registrado` depois da coleta.
- Deve migrar `WORK-017` do roadmap para realizações sem duplicação e atualizar referências remanescentes.
- Deve exigir `scripts/validar-documentacao.sh` e `scripts/validar-contexto.sh`.
- No campo `validations`, esses dois identificadores são caminhos literais, sem prefixo `bash`, argumentos ou descrição; o comando agregado não os substitui no contrato v1.
- Fontes mínimas: roteador, política do Context Graph, roadmap e realizações; enunciado e protótipo Go são contexto vedado.

## Baseline registrada

A coleta de 2026-08-13 está preservada em [`resultados/baseline-2026-08-13.json`](resultados/baseline-2026-08-13.json). Os três cenários passaram na primeira tentativa tanto na rubrica automática quanto na revisão semântica; não houve retrabalho nem alteração dos hashes do harness.

| Cenário | Fontes declaradas | Caracteres auxiliares | Entrada | Cache de entrada | Saída | Raciocínio | Retrabalho |
|---|---:|---:|---:|---:|---:|---:|---:|
| `EVAL-HARNESS-TM-001` | 14 | 20.515 | 108.484 | 68.864 | 3.299 | 505 | 0 |
| `EVAL-HARNESS-ADR-001` | 5 | 20.653 | 188.412 | 152.064 | 1.617 | 387 | 0 |
| `EVAL-HARNESS-GRAPH-001` | 13 | 20.466 | 110.533 | 71.936 | 2.344 | 800 | 0 |
| **Total** | — | — | **407.429** | **292.864** | **7.260** | **1.692** | **0** |

A revisão observou contexto além do pacote mínimo nos cenários de Threat Modeling e Context Graph. Isso não invalidou as respostas, mas fornece uma hipótese mensurável para [`WORK-018`](../../acompanhamento/roadmap.md#work-018--adotar-harness-spec-driven-enxuto): reduzir fontes carregadas e tokens sem perder aprovação ou rastreabilidade. A comparação deve usar o arquivo normalizado para confrontar métricas e hashes, não os logs brutos.

## Meta-PDCA da avaliação

- **Sintomas preservados:** `codex` não estava resolvível no `PATH`; o primeiro `trap` do self-test referenciava variável local fora de escopo; os schemas iniciais foram rejeitados por `type` ausente e palavras-chave não suportadas; o limite de retrabalho contabilizaria uma tentativa extra se todas as correções falhassem.
- **Causas:** o link pessoal do CLI estava quebrado; o lifecycle do temporário não considerava `set -u`; o self-test validava JSON e rubricas, mas não o subconjunto de JSON Schema aceito por Structured Outputs; o contador avançava mesmo depois da última tentativa permitida.
- **Correções:** o runner aceita `HARNESS_CODEX_BIN`, falha imediatamente sem resposta, captura erro de runtime, fixa o caminho do temporário no `trap`, valida tipos, `items`, `additionalProperties` e palavras-chave vedadas antes da execução e interrompe o laço exatamente no limite contratado.
- **Contrafactuais:** o self-test rejeita binário e resposta ausentes, ameaça P0 omitida, schema fora do subconjunto, correção além do máximo e evidência normalizada inconsistente; fixtures válidas, última correção permitida, soma de tokens e status semântico registrado continuam aprovados.

## Critério para comparações futuras

Uma execução candidata só pode ser comparada com esta baseline quando reutilizar os mesmos prompts, schemas, oráculos, modelo, esforço e sandbox. O manifesto candidato inclui a base Markdown consultável, além de instruções, contratos e fixtures, para tornar mudanças semânticas visíveis. Mudança de versão do CLI, falha de preflight ou alteração das fontes invalida comparação direta e deve ser registrada, não ocultada.
