---
context_id: DEC-0007
context_type: decision
status: em_analise
recorded_at: 2026-08-15
valid_from: 2026-08-15
relations:
  - type: refines
    target: DEC-0006
  - type: affects
    target: WORK-027
  - type: affects
    target: WORK-028
  - type: motivated_by
    target: https://learn.chatgpt.com/docs/app-server
  - type: governed_by
    target: CTX-GOV-001
  - type: governed_by
    target: CTX-GOV-002
---

# DEC-0007 — Recibo pós-execução do agente principal

> Navegação: [`DEC-0006`](0006-separacao-do-oraculo-do-harness.md) · [decisões arquiteturais](README.md) · [roadmap](../../acompanhamento/roadmap.md)

## Pergunta

Qual fronteira pode informar tempo e tokens do agente principal com procedência verificável, sem pedir que o próprio modelo estime ou repita métricas que ele não observa?

## Contexto e evidências

O contrato de relato de [`WORK-027`](../../acompanhamento/roadmap.md#work-027--otimizar-custo-e-relato-da-avalia%C3%A7%C3%A3o-do-harness) exige separar agente principal e processos filhos. O adaptador ACP usado pelo IntelliJ expõe no término apenas o uso do último turno, enquanto uma mesma solicitação pode iniciar mais de um turno. Somar esse campo como se representasse toda a execução produziria subcontagem silenciosa.

O [Codex App Server](https://learn.chatgpt.com/docs/app-server) fornece eventos JSONL de início, uso de tokens e término por thread e turno. Essa fronteira observa o dado antes de ele ser reduzido pelo adaptador e permite emitir um recibo depois da resposta do modelo, sem incluir o próprio rodapé no consumo medido.

## Características arquiteturais

- **Exatidão:** tokens são copiados do último evento autoritativo de cada turno raiz; ausência nunca vira estimativa.
- **Rastreabilidade:** cada recibo possui versão, origem, estado terminal, duração monotônica e identificadores irreversíveis.
- **Privacidade:** prompts, respostas e conteúdo de ferramentas não são persistidos.
- **Resiliência:** falha de coleta ou persistência não interrompe o protocolo ACP.
- **Reversibilidade:** o agente instrumentado é opt-in e o agente padrão permanece disponível.

## Opções e trade-offs

| Opção | Benefício | Custo ou risco |
|---|---|---|
| Autorrelato pelo modelo | nenhuma integração adicional | não observa contadores autoritativos e pode estimar ou duplicar dados |
| Campo `usage` da resposta ACP | interface simples | contém somente o último turno no adaptador atual |
| Proxy versionado entre ACP e App Server | preserva todos os turnos e controla o recibo final | acrescenta processo local, correlação e compatibilidade a manter |
| Alterar o pacote no cache do IntelliJ | acesso direto ao adaptador | mudança frágil, sobrescrita por atualização e difícil de auditar |
| OpenTelemetry externo | integração ampla com observabilidade | exige infraestrutura e não resolve sozinho o rodapé inline |

## Decisão em análise

Experimentar um proxy local versionado em duas fronteiras:

1. o proxy do App Server registra recibos terminais por turno, marca como raiz apenas threads abertas ou retomadas pelo cliente ACP e mantém threads filhas fora do agregado;
2. o proxy ACP correlaciona `session/prompt`, agrega os recibos raiz produzidos durante a solicitação, persiste um recibo de execução e envia um bloco sintético de métricas imediatamente antes da resposta terminal.

O agente customizado será configurado separadamente em `~/.jetbrains/acp.json`. A promoção desta decisão depende dos testes determinísticos e de uma execução real em uma nova conversa do IntelliJ.

## Consequências

- O runtime, e não o modelo, passa a ser autoridade sobre tempo e tokens do agente principal.
- O modelo continua responsável apenas por relatar subprocessos e validações que observou.
- Atualizações do ACP ou do App Server exigem executar novamente o contrato de compatibilidade antes de atualizar as versões fixadas.
- Recibos locais introduzem retenção operacional; somente metadados mínimos são gravados com permissão restrita.

## Validação e resultados

O contrato deve cobrir turno simples, vários turnos numa solicitação, ferramentas, thread filha, interrupção, uso ausente, duplicata terminal, falha de persistência e entrada malformada. A decisão só poderá ser aceita se:

- a soma do recibo for idêntica aos eventos raiz simulados;
- nenhuma thread filha for somada;
- o rodapé preceder a resposta ACP terminal;
- nenhuma fixture sensível aparecer nos recibos;
- o agente padrão continuar disponível.

Em 2026-08-15, doze testes determinísticos, o handshake real e um turno real passaram. O turno corrigido emitiu exatamente um rodapé e um recibo exato de `6.434 ms` e `17.165` tokens. A aceitação permanece pendente de observações interativas com ferramenta, subagente e interrupção no IntelliJ.

## Condições de revisão

- O ACP passar a expor um recibo terminal completo para todos os turnos da solicitação.
- O IntelliJ oferecer um hook pós-turno nativo com a decomposição necessária.
- A correlação por thread e janela monotônica se mostrar ambígua em execuções concorrentes.
- O formato dos eventos do App Server ou a variável `CODEX_PATH` deixar de ser compatível com o proxy.

## Histórico temporal

| Data | Estado | Alteração | Evidência ou responsável |
|---|---|---|---|
| 2026-08-15 | `em_analise` | Proxy versionado recomendado para experimento opt-in | `WORK-028` e contratos do App Server/ACP |
