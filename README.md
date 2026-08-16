# FIAP X Video Processing

Serviços Java 25/Quarkus 3.31.4 para receber uma **Video Submission** autenticada, acompanhar seu **Processing Job** e disponibilizar o **Image Archive** gerado. A API expõe OpenAPI em `/q/swagger-ui`, health checks em `/q/health` e métricas em `/q/metrics`.

## Executar localmente

```bash
docker compose up -d
./mvnw verify
./mvnw -pl api-service -am quarkus:dev
```

O Compose disponibiliza PostgreSQL, RabbitMQ, MinIO, Keycloak e MailHog (interface em `http://localhost:8025`). A API tem como superfície `POST /processing-jobs` (multipart, campo `video`) e `GET /processing-jobs`; ambas requerem um token Keycloak.

## Garantia assíncrona

A API é proprietária dos estados de `Processing Job`. O desenho usa outbox transacional para publicar trabalho após o aceite, e o worker deve retornar eventos idempotentes de sucesso/falha; tentativas técnicas e DLQ pertencem aos adapters de mensageria. O núcleo limita falhas de processamento a três tentativas antes do estado `FAILED`.
