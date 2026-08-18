# Arquitetura da aplicação

Estas instruções regem o bootstrap e toda alteração no código da aplicação. Use `docs/agents/domain.md` para vocabulário, contextos e ADRs. Neste documento, **núcleo** significa `domain` e `application` em conjunto.

## Antes de implementar

1. Leia a issue ou especificação, a documentação de domínio e as ADRs aplicáveis. A etapa termina quando o caso de uso e o módulo de domínio responsável estiverem nomeados.
2. Liste as fronteiras atravessadas e os efeitos externos necessários. A etapa termina quando cada integração tiver um proprietário e uma direção definidos.
3. Inspecione o build e os testes estruturais existentes. Preserve as convenções que respeitem estas regras e estenda a verificação automatizada junto com a mudança. A etapa termina quando os comandos de verificação, as regras estruturais afetadas e eventuais lacunas de cobertura estiverem identificados.

Quando uma mudança se basear no protótipo, leia `docs/referencia/README.md`. Trate o protótipo como evidência do ponto de partida: um comportamento observado nele só vira requisito quando confirmado pela issue, especificação ou documentação de domínio.

## Fronteiras de domínio

Um **módulo de domínio** é uma capacidade coesa com interface pública e implementação encapsulada. Ele é uma fronteira lógica; não implica um artefato de build, banco, processo ou microsserviço próprio.

Organize primeiro por módulo de domínio e, dentro dele, por papel arquitetural:

```text
<pacote-base>/
├── <modulo-de-dominio>/
│   ├── domain/
│   ├── application/
│   │   ├── contract/
│   │   ├── port/in/
│   │   ├── port/out/
│   │   └── usecase/
│   └── adapter/
│       ├── in/<protocolo>/
│       └── out/<tecnologia>/
└── bootstrap/
```

Os nomes entre `<...>` são segmentos substituíveis, não nomes literais de pacotes Java.

- Dê a cada regra, dado e caso de uso um único módulo proprietário. Use nomes do domínio; pacotes genéricos como `common`, `shared`, `manager`, `helper` e `utils` não constituem fronteiras.
- Respeite o layout de contextos declarado em `docs/agents/domain.md`. Introduza outro bounded context somente quando uma diferença real de linguagem, modelo ou ciclo de vida for resolvida. A adoção termina quando `CONTEXT-MAP.md`, os glossários dos contextos e o layout descrito em `docs/agents/domain.md` refletirem a nova organização, com uma ADR quando a decisão for difícil de reverter, surpreendente sem contexto e resultar de um trade-off real.
- A superfície importável por outro módulo limita-se a `application.port.in` e `application.contract`. O provedor é proprietário desses contratos; o consumidor os converte para seus próprios tipos.
- `application.contract` contém somente commands, results e fatos publicados, imutáveis e independentes de tecnologia, que aparecem nas interfaces públicas. `domain`, `application.usecase`, `application.port.out`, `adapter` e `bootstrap` permanecem internos ao módulo proprietário.
- Um módulo acessa dados pertencentes a outro por sua interface, inclusive quando ambos usam o mesmo banco. Mudanças que exigem imports internos, tabelas alheias ou ciclos indicam uma fronteira incorreta.
- Separe artefatos de build quando isso reforçar uma fronteira de domínio já reconhecida. Camadas da Clean Architecture, isoladamente, não justificam novas unidades de implantação.

## Regra de dependências

Todas as dependências de código apontam para dentro:

```text
bootstrap → adapters → application → domain
```

As setas podem saltar para qualquer camada à direita. `bootstrap` pode compor todas as partes. Adapters de entrada e saída são pares do mesmo nível e não dependem entre si. Ciclos são inválidos.

- `domain` contém entidades, value objects, invariantes, políticas, eventos e erros de negócio. Use Java puro por padrão e mantenha I/O, tipos e anotações de framework fora dele.
- `application` orquestra casos de uso e declara ports de entrada e saída. Depende apenas do domínio e de bibliotecas independentes de framework; mantenha Quarkus, Jakarta, transportes, persistência e adapters fora dela.
- `adapter.in` traduz HTTP, mensagens, CLI ou jobs para um port de entrada. Autenticação, desserialização e validação de protocolo terminam nesse adapter.
- `adapter.out` implementa ports para persistência, storage, mensageria e serviços externos. Detalhes tecnológicos pertencem ao nome e à implementação do adapter, não ao port.
- `bootstrap` concentra Quarkus, CDI, configuração e wiring. Ele instancia casos de uso por construtor e conecta cada port ao adapter escolhido.

Modele ports no vocabulário da capacidade que oferecem. Ports de entrada expressam intenções do usuário ou do sistema; ports de saída expressam uma necessidade do caso de uso. Crie uma seam quando houver variação real, normalmente um adapter de produção e um substituto de teste. Interfaces que apenas repetem outra interface ou repassam chamadas tornam o módulo raso e devem ser aprofundadas ou removidas.

## Modelos e efeitos externos

- DTOs de transporte, schemas de mensagem, entidades JPA/Panache e modelos de clientes ficam nos respectivos adapters. Converta-os explicitamente para commands, results ou tipos de domínio na fronteira.
- Objetos de domínio permanecem livres de JPA, Panache, Jackson, REST, mensageria e configuração Quarkus. O adapter de persistência mapeia entre o agregado e seu modelo persistente.
- Validação estrutural pertence ao adapter; invariantes, permissões e transições de estado pertencem ao domínio ou ao caso de uso. Converta a identidade autenticada em um tipo da aplicação antes de atravessar o port de entrada.
- Todo efeito externo solicitado pelo núcleo atravessa um port de saída. Passe relógio, gerador de identificadores e outras fontes não determinísticas como dependências quando afetarem regra ou teste.
- Defina a atomicidade por etapa curta do caso de uso e implemente o mecanismo transacional em um wrapper ou decorator composto no bootstrap, envolvendo todos os efeitos que precisam de commit atômico. Aplique `@Transactional` somente nessa camada externa; uploads, processamento de mídia e chamadas remotas ocorrem sem uma transação aberta.
- Quando a especificação definir entrega assíncrona, registre antes de implementar qual garantia de aceite, reentrega e ordenação o fluxo oferece. Modele no núcleo apenas idempotência, elegibilidade para nova tentativa e transições com significado de negócio; mantenha retry técnico, backoff, DLQ, acknowledgements, broker e o mecanismo de entrega durável nos adapters.

## Baseline Java e Quarkus

- Compile, teste e execute com Java 25. Configure o build com `release` 25 e alinhe as imagens de CI, runtime e build nativo quando este existir.
- No bootstrap, fixe sem intervalo a versão patch mais recente disponível da linha Quarkus `3.31.x`. Importe o BOM da plataforma e mantenha plugin, BOM e extensões alinhados; dependências gerenciadas pelo BOM não recebem versões avulsas.
- Preserve a linha `3.31.x` em manutenções comuns. Uma mudança de linha do Quarkus ou de versão do Java exige tarefa explícita e avaliação de migração.
- Use o wrapper do build em desenvolvimento e CI. Se o projeto adotar Maven, use Maven 3.9 ou superior, exigido pelo Quarkus 3.31.
- Mantenha dependências e anotações Quarkus nos adapters e no bootstrap. A adoção de extensões experimentais exige uma decisão explícita.

## Verificação

Quando o primeiro código Java for criado, adicione testes estruturais de arquitetura e execute-os no comando padrão de verificação. Eles devem provar, no mínimo:

- direção das dependências entre `domain`, `application`, `adapter` e `bootstrap`;
- ausência de imports de framework e infraestrutura no núcleo;
- ausência de ciclos e restrição de imports entre módulos a `application.port.in` e `application.contract` do provedor.

Teste regras de domínio com JUnit puro, casos de uso pelos ports de entrada com adapters locais e adapters tecnológicos com testes de integração Quarkus. A interface do módulo é a superfície de teste; testes devem observar resultados, eventos e efeitos nos ports em vez de estado interno.

## Critério de conclusão

Uma mudança de aplicação termina quando:

1. o módulo proprietário e as fronteiras atravessadas estão identificados;
2. a regra de dependências e a separação de modelos estão cobertas pelos testes estruturais aplicáveis;
3. regras do núcleo têm testes sem runtime Quarkus e adapters alterados têm testes de integração proporcionais ao risco;
4. o comando de verificação pelo wrapper passa com Java 25 e o patch fixado do Quarkus `3.31.x`;
5. mudanças de vocabulário ou fronteira atualizam a documentação de domínio, e decisões difíceis de reverter, surpreendentes sem contexto e resultantes de trade-offs reais atualizam a ADR correspondente;
6. o resumo da entrega informa o módulo afetado, os ports/adapters criados e os comandos de verificação executados.
