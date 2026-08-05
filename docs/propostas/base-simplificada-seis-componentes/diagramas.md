---
context_id: R6-VIEW-001
context_type: architecture_view
status: em_analise
recorded_at: 2026-08-03
valid_from: 2026-08-03
relations:
  - type: derived_from
    target: R6-CMP-MODEL-001
  - type: governed_by
    target: CTX-GOV-001
---

# Diagramas da proposta

> Navegação: [índice da proposta histórica](README.md) · [modelo proposto](componentes.md)

Os blocos Mermaid podem ser renderizados pelo visualizador yFiles usado na interface. As setas representam interação ou passagem de fatos, não protocolo, sincronismo, processo ou implantação.

## Evolução resumida

```mermaid
flowchart LR
    A[4 componentes iniciais] --> B[5 componentes após ampliar acompanhamento]
    B --> C[6 componentes após separar gestão e visualização]

    A1[Recebe vídeos] -.-> A
    A2[Baixar imagens] -.-> A
    A3[Processador de vídeo] -.-> A
    A4[Notifica usuário] -.-> A

    C --> C1[Submissão de Vídeos]
    C --> C2[Gerenciar Trabalhos de Vídeo]
    C --> C3[Processamento de Mídia]
    C --> C4[Entrega de Imagens]
    C --> C5[Visualizar Trabalhos de Vídeo]
    C --> C6[Notifica Usuário]
```

## Base final de componentes

```mermaid
flowchart LR
    user([Usuário])
    submit["R6-CMP-01<br/>Submissão de Vídeos"]
    manage["R6-CMP-02<br/>Gerenciar Trabalhos de Vídeo"]
    process["R6-CMP-03<br/>Processamento de Mídia"]
    deliver["R6-CMP-04<br/>Entrega de Imagens"]
    view["R6-CMP-05<br/>Visualizar Trabalhos de Vídeo"]
    notify["R6-CMP-06<br/>Notifica Usuário"]

    user -->|submete vídeo| submit
    submit -->|registra trabalho aceito| manage
    submit -->|aciona processamento inicial| process
    process -->|imagens extraídas| deliver
    process -->|sucesso, falha ou interrupção| manage
    deliver -->|imagens recuperáveis| manage

    user -->|reprocessa ou cancela| manage
    manage -->|processa, reprocessa ou interrompe| process
    manage -->|estado, histórico e falha| view
    user -->|consulta| view
    user -->|baixa imagem ou conjunto| deliver

    submit -->|resultado da submissão| notify
    manage -->|acontecimento do trabalho| notify
    user -->|configura preferências| notify
    notify -->|comunicação| user
```

## Sequência do caminho feliz

```mermaid
sequenceDiagram
    actor U as Usuário
    participant S as Submissão
    participant G as Gerenciar Trabalhos
    participant P as Processamento
    participant E as Entrega
    participant V as Visualização
    participant N as Notificação

    U->>S: submeter vídeo
    S->>G: registrar trabalho aceito
    S->>P: iniciar processamento
    S-->>N: submissão aceita
    P->>E: registrar imagens extraídas
    E-->>G: confirmar imagens recuperáveis
    P-->>G: processamento bem-sucedido
    G-->>V: publicar estado e histórico
    G-->>N: trabalho concluído
    U->>V: consultar trabalho
    U->>E: baixar imagem ou conjunto
```

O trabalho somente pode aparecer como concluído quando o conjunto completo de imagens estiver recuperável. A existência prévia de um ZIP não é condição para conclusão.
