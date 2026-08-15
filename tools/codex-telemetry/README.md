# Telemetria do agente Codex

Este pacote mantém o agente ACP opt-in definido por [`DEC-0007`](../../docs/arquitetura/decisoes/0007-recibo-pos-execucao-do-agente-principal.md). O proxy observa eventos do [Codex App Server](https://learn.chatgpt.com/docs/app-server), agrega apenas turnos raiz e acrescenta o rodapé depois da resposta do modelo.

## Instalação local

```bash
cd tools/codex-telemetry
npm ci
./telemetry_proxy.py self-check
./configure_jetbrains.py
./smoke_test.py
```

Selecione `Codex FIAPX (métricas)` em uma nova conversa do IntelliJ. O agente padrão não é modificado.

## Dados persistidos

O arquivo padrão é `~/.local/state/fiapx/codex-agent-metrics.jsonl`, com diretório `0700` e arquivo `0600`. Cada registro contém somente versão, origem, hashes de sessão/turno, timestamps, duração, estado terminal e contadores de tokens. Prompt, resposta, mensagens e saídas de ferramentas são proibidos pelo contrato de persistência.

Se um evento terminal não contiver a decomposição completa, o rodapé informa `tokens indisponíveis`; nenhum valor é inferido a partir da duração ou do campo reduzido da resposta ACP.

O smoke padrão valida somente o handshake. `./smoke_test.py --live` executa um turno real, exige exatamente um rodapé e deve ser reservado para validação local, pois consome tokens.
