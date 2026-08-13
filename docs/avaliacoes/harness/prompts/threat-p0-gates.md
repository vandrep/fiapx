Execute uma análise somente leitura para o cenário `EVAL-HARNESS-TM-001`.

> Contrato: [baseline do harness](../README.md) · fonte principal: [modelo de ameaças](../../../arquitetura/modelo-ameacas.md)

Use o `AGENTS.md` e o roteador de contexto do repositório. A partir do trabalho pendente em `WORK-011` e do modelo `CTX-THREAT-001`, transforme os testes futuros das ameaças P0 em gates candidatos da primeira fatia.

Restrições:

- cubra exatamente `THR-001`, `THR-002`, `THR-003`, `THR-008`, `THR-009`, `THR-010`, `THR-013`, `THR-014` e `THR-015`;
- preserve a diferença entre requisito/decisão, controle vigente `C1`, mitigação proposta, teste futuro e risco residual;
- não afirme implementação, comprovação, redução de risco ou valores operacionais ainda abertos;
- não leia o enunciado completo nem o protótipo Go, pois não existe lacuna que justifique essas fontes;
- não edite arquivos;
- devolva somente JSON compatível com o schema fornecido e liste honestamente todas as fontes consultadas.
