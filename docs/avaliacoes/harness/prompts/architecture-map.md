Execute uma análise arquitetural consultiva e somente leitura para o cenário `EVAL-HARNESS-ARCH-001`.

> Contrato: [avaliação do harness](../README.md) · mapa principal: [`ARCHITECTURE.md`](../../../../ARCHITECTURE.md)

Use o `AGENTS.md`, o roteador de contexto e o `ARCHITECTURE.md` para descrever apenas o estado arquitetural vigente. Consulte uma fonte detalhada somente quando o mapa não for suficiente para resolver uma lacuna concreta.

Restrições:

- diferencie aplicação observada, arquitetura decidida, decisão em análise e preferência;
- identifique exatamente o modelo lógico vigente `CTX-CMP-003`, seus oito componentes e os três quanta aceitos por `DEC-0002`;
- trate Keycloak como plataforma, não como componente ou quantum da aplicação;
- preserve `DEC-0003` como `em_analise` e Java com Quarkus como preferência;
- não use modelos históricos ou propostas como definição corrente;
- não leia o enunciado completo nem o protótipo Go, pois o mapa já registra o estado observado necessário;
- não edite arquivos;
- devolva somente JSON compatível com o schema fornecido e liste honestamente todas as fontes consultadas.
