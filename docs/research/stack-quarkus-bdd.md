# Stack Quarkus e BDD compatível

> Resposta à pergunta de pesquisa **Verificar a stack Quarkus e BDD compatível**. Pesquisa realizada em 16 de agosto de 2026, usando documentação e repositórios oficiais dos fornecedores.

## Decisão recomendada

Usar **Quarkus 3.31.4**, Java 25 e Maven Wrapper com Maven 3.9 ou superior para os dois serviços. É o último patch publicado da linha 3.31.x na data da pesquisa; o anúncio do Quarkus 3.31 confirma suporte completo a Java 25 (JVM e native) e torna Maven 3.9 obrigatório. Fixar o patch no bootstrap, importar um único BOM e não atribuir versões às extensões Quarkus. [Notas de lançamento do Quarkus 3.31](https://quarkus.io/blog/quarkus-3-31-released/) · [índice oficial de releases](https://quarkus.io/releases/)

```xml
<properties>
  <quarkus.platform.group-id>io.quarkus.platform</quarkus.platform.group-id>
  <quarkus.platform.artifact-id>quarkus-bom</quarkus.platform.artifact-id>
  <quarkus.platform.version>3.31.4</quarkus.platform.version>
  <maven.compiler.release>25</maven.compiler.release>
  <cucumber.version>7.34.6</cucumber.version>
</properties>

<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>${quarkus.platform.group-id}</groupId>
      <artifactId>${quarkus.platform.artifact-id}</artifactId>
      <version>${quarkus.platform.version}</version>
      <type>pom</type><scope>import</scope>
    </dependency>
    <dependency>
      <groupId>io.cucumber</groupId><artifactId>cucumber-bom</artifactId>
      <version>${cucumber.version}</version>
      <type>pom</type><scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>

<build><plugins><plugin>
  <groupId>io.quarkus.platform</groupId><artifactId>quarkus-maven-plugin</artifactId>
  <version>${quarkus.platform.version}</version><extensions>true</extensions>
</plugin></plugins></build>
```

O novo packaging `quarkus` é o padrão para aplicações novas na linha 3.31, mas é opcional nesta migração: adote-o apenas no módulo de aplicação depois de o build multi-módulo estar estruturado. [Documentação de packaging Quarkus](https://quarkus.io/blog/building-large-applications/)

## Dependências de produção

Todas as dependências desta tabela são `io.quarkus` e gerenciadas pelo BOM 3.31.4; portanto, não recebem `<version>` no `pom.xml`.

| Necessidade | Artefato | Uso e configuração relevante |
| --- | --- | --- |
| API JSON e upload | `quarkus-rest-jackson` | Recurso HTTP REST; para `multipart/form-data`, receber o arquivo com `@RestForm FileUpload` (não é necessária outra extensão). [REST JSON](https://quarkus.io/guides/rest-json) · [multipart Quarkus REST](https://quarkus.io/guides/rest#multipart-form-data) |
| Contrato e console da API | `quarkus-smallrye-openapi` | OpenAPI em `/q/openapi` e Swagger UI em `/q/swagger-ui`; definir `quarkus.swagger-ui.always-include=true` para a demonstração em produção. [OpenAPI/Swagger UI](https://quarkus.io/guides/openapi-swaggerui) |
| Tokens Keycloak | `quarkus-oidc` | API é um resource server bearer. Configurar `quarkus.oidc.auth-server-url`, `quarkus.oidc.client-id=video-api` e, se o realm emitir audiência, `quarkus.oidc.token.audience=${quarkus.oidc.client-id}`. Converter a `SecurityIdentity` no adapter HTTP antes do port. [OIDC bearer](https://quarkus.io/guides/security-oidc-bearer-token-authentication) |
| Metadados e outbox | `quarkus-hibernate-orm`, `quarkus-jdbc-postgresql` | Configurar `quarkus.datasource.db-kind=postgresql` e URL JDBC; manter entidades JPA somente nos adapters. [Hibernate ORM](https://quarkus.io/guides/hibernate-orm) |
| Migrations | `quarkus-flyway`, `org.flywaydb:flyway-database-postgresql` | A segunda também é gerenciada pelo BOM. Ativar `quarkus.flyway.migrate-at-start=true`; migrations pertencem ao serviço que possui o schema. [Flyway](https://quarkus.io/guides/flyway) |
| Trabalho e eventos | `quarkus-messaging-rabbitmq` | Canais separados com `mp.messaging.outgoing.<canal>.connector=smallrye-rabbitmq` e `mp.messaging.incoming.<canal>.connector=smallrye-rabbitmq`; declarar exchange e fila duráveis. [RabbitMQ connector](https://quarkus.io/guides/rabbitmq) |
| E-mail de falha | `quarkus-mailer` | Para MailHog: `quarkus.mailer.host=mailhog`, `port=1025`, `tls=false`, `login=DISABLED`, `mock=false`. [Mailer reference](https://quarkus.io/guides/mailer-reference) |
| Liveness/readiness | `quarkus-smallrye-health` | Expor `/q/health/live` e `/q/health/ready`; incluir checks das dependências relevantes. [SmallRye Health](https://quarkus.io/guides/smallrye-health) |
| Métricas Prometheus | `quarkus-micrometer-registry-prometheus` | Expõe métricas Prometheus; ativar métricas por canal com `smallrye.messaging.observation.enabled=true`. [Micrometer](https://quarkus.io/guides/telemetry-micrometer) · [Messaging observability](https://quarkus.io/guides/messaging#observability) |

### Armazenamento MinIO

Não adicionar uma extensão Quarkus de terceiros para storage. Usar o SDK oficial diretamente no adapter de saída, com o `MinioClient` construído e configurado no bootstrap:

```xml
<dependency>
  <groupId>io.minio</groupId><artifactId>minio</artifactId><version>9.0.3</version>
</dependency>
```

`io.minio:minio:9.0.3` é uma dependência externa ao BOM, por isso sua versão é explícita e deve ser validada em teste de integração contra o MinIO do Compose. O SDK é a integração mantida pelo próprio MinIO. [MinIO Java SDK](https://github.com/minio/minio-java#readme) · [metadados do artefato no repositório Maven Central](https://repo1.maven.org/maven2/io/minio/minio/maven-metadata.xml)

## BDD executável

Usar Cucumber-JVM **7.34.6** com o JUnit Platform, mantendo todos os artefatos Cucumber na mesma versão. Colocar arquivos `.feature` em `src/test/resources/features` e steps na camada de aceitação, consumindo a API ou ports públicos — nunca entidades JPA ou internals do núcleo.

```xml
<dependencies>
  <dependency><groupId>io.cucumber</groupId><artifactId>cucumber-java</artifactId><scope>test</scope></dependency>
  <dependency><groupId>io.cucumber</groupId><artifactId>cucumber-junit-platform-engine</artifactId><scope>test</scope></dependency>
  <dependency><groupId>org.junit.platform</groupId><artifactId>junit-platform-suite</artifactId><scope>test</scope></dependency>
</dependencies>
```

Uma classe de suíte no escopo de testes deve selecionar o engine e o classpath de features; isso dá ao Surefire uma classe descoberta para executar os cenários.

```java
@Suite
@IncludeEngines("cucumber")
@SelectClasspathResource("features")
@ConfigurationParameter(key = GLUE_PROPERTY_NAME, value = "br.com.fiapx.acceptance")
class CucumberSuite {}
```

Usar as anotações de `org.junit.platform.suite.api` e a constante `io.cucumber.junit.platform.engine.Constants.GLUE_PROPERTY_NAME`. Esta é a integração oficial recomendada pelo Cucumber para JUnit Platform. [Instalação Cucumber-JVM](https://cucumber.io/docs/installation/java/) · [engine JUnit Platform do Cucumber](https://github.com/cucumber/cucumber-jvm/tree/main/cucumber-junit-platform-engine)

O Quarkus 3.31 atualizou a sua plataforma para JUnit 6. A documentação Cucumber consultada não declara explicitamente uma matriz de compatibilidade Cucumber 7.34.6 × JUnit 6 × Java 25. Logo, tratar a composição como **compatível a validar**, não como garantia do fornecedor: o primeiro slice deve executar `./mvnw verify` com cenários BDD de sucesso, falha e isolamento de User em CI. Se houver incompatibilidade real, manter Gherkin e migrar apenas o runner para a versão Cucumber que declare suporte, por decisão explícita.

## Containers e verificação

- Compilar/testar inicialmente em imagem JVM Java 25 e executar o artefato JVM em runtime Java 25. A entrega não exige binário nativo; isso reduz risco para FFmpeg e SDK de objetos.
- Se a apresentação exigir native, o Quarkus recomenda Mandrel e build em container; usar a família oficial `quay.io/quarkus/ubi9-quarkus-mandrel-builder-image` compatível com UBI 9 e escolher uma tag publicada para Java 25 no momento de configurar o pipeline. Não fixar uma tag inventada nesta pesquisa. [Building a native executable](https://quarkus.io/guides/building-native-image)
- No GitHub Actions, usar `./mvnw -B verify` com JDK 25 e construir as imagens Docker após a verificação. Incluir no primeiro build `dependency:tree` e os testes de integração para MinIO, PostgreSQL, RabbitMQ, Keycloak e MailHog.

## Riscos a fechar na implementação

1. A documentação do RabbitMQ connector marca-o como **preview**. A arquitetura veda extensões experimentais, portanto registrar uma decisão explícita: aceitá-lo para este produto por ser o conector mantido pelo Quarkus, ou trocar o adapter por cliente RabbitMQ Java diretamente. [Status do connector RabbitMQ](https://quarkus.io/guides/rabbitmq)
2. Há risco de mediação de dependências entre o BOM Quarkus e o SDK MinIO (que traz Jackson/HTTP próprios); provar upload/download no teste de integração e revisar `mvn dependency:tree` antes de congelar o primeiro `pom.xml`.
3. A compatibilidade do runner Cucumber com a versão de JUnit trazida pelo Quarkus precisa ser confirmada pelo `verify` inicial, pois a fonte Cucumber não a declara de forma explícita.
