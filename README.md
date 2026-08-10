# FIAP X — processamento de vídeos

Este repositório documenta a evolução de um protótipo que extrai imagens de um vídeo e gera um arquivo ZIP para uma solução em que usuários autenticados enviam vídeos, acompanham o processamento e baixam o resultado. O objetivo e as restrições estão consolidados no [contexto do projeto](docs/contexto-projeto.md); o texto original do desafio permanece no [enunciado](docs/enunciado.md).

## Estado atual

O repositório ainda não contém a aplicação-alvo. O único código de aplicação disponível é o [protótipo Go de referência](docs/referencia/README.md), usado como evidência do ponto de partida; os scripts Bash apenas validam a documentação e seus contratos. A arquitetura e a primeira fatia executável continuam sendo preparadas.

| Situação | Estado verificável | Fonte |
|---|---|---|
| Requisitos | sete histórias canônicas para autenticação, envio, processamento, recuperação, consulta, download e comunicação de falha | [histórias de usuário](docs/requisitos/historias.md) |
| Arquitetura lógica | oito componentes coesos aceitos | [modelo ativo](docs/arquitetura/componentes-coesos.md) e [DEC-0004](docs/arquitetura/decisoes/0004-componentes-coesos-do-nucleo.md) |
| Topologia de validação | três quanta Kubernetes e Keycloak autocontido aceitos, ainda não implementados | [DEC-0002](docs/arquitetura/decisoes/0002-topologia-kubernetes.md) e [DEC-0005](docs/arquitetura/decisoes/0005-keycloak-no-ambiente-de-validacao.md) |
| Em análise | aceite durável, persistência, mensageria e armazenamento | [DEC-0003](docs/arquitetura/decisoes/0003-entrega-duravel-e-persistencia.md) |
| Preferência a decidir | Java com Quarkus, ainda sem ADR nem build da aplicação | [contexto do projeto](docs/contexto-projeto.md#preferências-declaradas) e [roadmap](docs/acompanhamento/roadmap.md) |
| Trabalho em andamento | `WORK-011` possui fluxo, ativos, dez fronteiras e a primeira onda de vinte ameaças priorizadas; os testes `P0` e as fronteiras restantes são o próximo incremento | [modelo `CTX-THREAT-001`](docs/arquitetura/modelo-ameacas.md) e [roadmap ativo](docs/acompanhamento/roadmap.md) |

Uma recomendação ou um documento `em_analise` não descreve implementação existente. Modelos marcados como históricos continuam disponíveis para explicar a evolução, mas não substituem as fontes ativas.

## Como navegar

O [índice completo da documentação](docs/README.md) conecta todos os documentos mantidos no repositório. Para uma primeira leitura:

1. entenda o objetivo e o estado observado no [contexto do projeto](docs/contexto-projeto.md);
2. consulte as [histórias, o glossário e a descoberta do domínio](docs/requisitos/README.md);
3. leia o [índice de arquitetura](docs/arquitetura/README.md), começando pelo modelo ativo e pelas decisões;
4. acompanhe o que está em andamento no [roadmap](docs/acompanhamento/README.md);
5. use o [roteador de contexto](docs/contexto/roteador.md) ao executar uma tarefa específica.

| Área | Ponto de entrada |
|---|---|
| Documentação completa | [`docs/README.md`](docs/README.md) |
| Requisitos e domínio | [`docs/requisitos/README.md`](docs/requisitos/README.md) |
| Arquitetura e decisões | [`docs/arquitetura/README.md`](docs/arquitetura/README.md) |
| Trabalho atual e resultados | [`docs/acompanhamento/README.md`](docs/acompanhamento/README.md) |
| Context Graph e governança | [`docs/contexto/README.md`](docs/contexto/README.md) |
| Propostas preservadas | [`docs/propostas/README.md`](docs/propostas/README.md) |
| Protótipo de referência | [`docs/referencia/README.md`](docs/referencia/README.md) |
| Regras para agentes | [`AGENTS.md`](AGENTS.md) e [`docs/agentes.md`](docs/agentes.md) |

## Validar a documentação

Na raiz do repositório, execute:

```bash
bash scripts/validar-documentacao.sh
bash scripts/validar-contexto.sh
```

O primeiro comando verifica destinos locais, links de saída e alcançabilidade de todos os documentos a partir deste README. O segundo valida metadados, relações e fitness functions arquiteturais.
