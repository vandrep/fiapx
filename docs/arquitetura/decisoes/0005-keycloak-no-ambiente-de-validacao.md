---
context_id: DEC-0005
context_type: decision
status: aceita
recorded_at: 2026-08-03
valid_from: 2026-08-03
relations:
  - type: derived_from
    target: CTX-REQ-001
  - type: informed_by
    target: CTX-CHAR-001
  - type: informed_by
    target: https://www.keycloak.org/securing-apps/oidc-layers
  - type: informed_by
    target: https://www.keycloak.org/server/configuration-production
  - type: affects
    target: CTX-CMP-003
  - type: affects
    target: CTX-ARCH-001
  - type: affects
    target: DEC-0002
  - type: governed_by
    target: CTX-GOV-001
---

# DEC-0005 — Empacotar Keycloak no ambiente Kubernetes de validação

## Pergunta

Como fornecer autenticação por usuário e senha de forma reproduzível na máquina do avaliador, sem implementar credenciais no FIAP X nem depender do homelab do responsável?

## Contexto e evidências

A [`US-01`](../../requisitos/historias.md#us-01) exige autenticação, e a característica de [segurança `CA-02`](../caracteristicas.md#ca-02--seguran%C3%A7a) exige identidade confiável e teste entre dois usuários. Um Keycloak existente no homelab reduz aprendizado, mas não é uma dependência aceitável para a validação na máquina do professor.

Keycloak fornece OpenID Connect, login, contas, sessões e tokens. A aplicação continua responsável por validar o token e autorizar cada trabalho por proprietário. A [documentação oficial de OIDC](https://www.keycloak.org/securing-apps/oidc-layers) recomenda Authorization Code para aplicações interativas e desaconselha entregar usuário/senha diretamente à aplicação.

## Opções e trade-offs

| Opção | Benefícios | Custos e riscos |
|---|---|---|
| Depender do Keycloak do homelab | já conhecido e operado | avaliador depende de rede/ambiente externo e a prova não é autocontida |
| Fornecer Keycloak apenas em Docker Compose | bootstrap local simples | cria uma segunda topologia e não valida o ambiente Kubernetes escolhido |
| **Incluir Keycloak em Kubernetes** | uma distribuição reproduzível valida aplicação e IdP na mesma plataforma | aumenta CPU, memória, tempo de subida, configuração e superfície operacional |
| Implementar autenticação própria | menos workload externo | passa a possuir senha, sessão e recuperação; risco e esforço sem valor para o domínio |

## Decisão

O ambiente acadêmico reproduzível incluirá Keycloak como workload de plataforma Kubernetes, com imagem/versionamento fixados no manifesto e persistência em banco próprio. Ele não é componente, quantum ou microsserviço de negócio do FIAP X.

O bootstrap deve criar de forma reproduzível:

- realm dedicado `fiapx`;
- cliente interativo com Authorization Code e PKCE;
- audiência destinada à API de `gestao-trabalhos`;
- ao menos dois usuários de demonstração para o teste de propriedade;
- configuração de issuer, redirects e origins coerente com o Ingress local.

Segredos administrativos e senhas dos usuários não entram no Git. O mecanismo de bootstrap os recebe por `Secret`/entrada externa e deve permitir que o professor suba o ambiente sem editar manifests internos.

`CMP-18` valida assinatura, expiração, emissor e audiência do JWT e fornece `(issuer, subject)`. Nome de usuário, e-mail e roles não substituem esse identificador. Autorizações de proprietário permanecem em `CMP-20`, `CMP-23` e `CMP-24`.

## Consequências

- novos logins dependem da disponibilidade do Keycloak, mas senhas nunca chegam aos serviços de domínio;
- o cluster terá três `Deployment`s de aplicação e um workload adicional de identidade, além de dados/mensageria/observabilidade;
- o Keycloak necessita hostname/issuer estável, probes, recursos, banco, migração, reinício e configuração idempotente;
- CI e testes podem usar instância efêmera equivalente, mas a validação final usa os manifests Kubernetes entregues;
- a decisão descreve o ambiente acadêmico autocontido e não afirma que uma instalação de produção deveria operar Keycloak da mesma forma.

## Validação

- uma máquina limpa cria o ambiente e o realm por procedimento documentado;
- dois usuários autenticam por fluxo OIDC sem a aplicação receber suas senhas;
- token ausente, expirado, com issuer ou audiência incorretos recebe `401`;
- usuário A não lista nem baixa trabalho de B;
- reinício do Keycloak preserva realm, cliente e contas;
- nenhum segredo real aparece no repositório, imagem, logs ou `ConfigMap`;
- consumo total e tempo de bootstrap cabem na máquina-alvo da demonstração.

## Condições de revisão

- recursos mínimos do avaliador não suportarem o ambiente autocontido;
- a banca determinar explicitamente Docker Compose em vez de Kubernetes;
- um IdP gerenciado passar a ser requisito do ambiente de destino;
- o fluxo de interação deixar de ser compatível com Authorization Code e PKCE;
- a operação exigir disponibilidade, backup ou federação além do escopo acadêmico.

## Histórico temporal

| Data | Estado | Alteração | Evidência ou responsável |
|---|---|---|---|
| 2026-08-03 | `aceita` | Keycloak incluído no Kubernetes de validação como dependência de plataforma reproduzível | decisão do responsável pelo projeto |
