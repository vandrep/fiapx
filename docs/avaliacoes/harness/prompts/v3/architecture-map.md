Execute o cenário `EVAL-HARNESS-ARCH-001` em modo consultivo e somente leitura.

Siga o [`AGENTS.md`](../../../../../AGENTS.md), o roteador e o [`ARCHITECTURE.md`](../../../../../ARCHITECTURE.md). Recupere apenas o estado arquitetural vigente: aplicação observada, modelo lógico, componentes, topologia, quanta, plataformas, decisões em análise e preferências.

Não use histórico ou propostas como estado atual nem afirme implementação ausente. Consulte detalhes somente quando o mapa deixar uma lacuna concreta e use no máximo sete fontes. Não leia contratos, schemas, fixtures, resultados ou documentação do avaliador. Não edite arquivos e devolva somente o JSON solicitado.

Campos categóricos usam vocabulário estável, não frases: `application_state` recebe `target_absent`, `implemented` ou `unknown`; `keycloak_role` recebe `plataforma`, `componente`, `quantum` ou `unknown`; estados de decisão preservam o literal documental; `java_quarkus_status` recebe `preferencia`, `decidida` ou `unknown`.

Em `sources_consulted`, liste também `AGENTS.md`, fornecido automaticamente como instrução do repositório, além dos arquivos abertos por comandos.
