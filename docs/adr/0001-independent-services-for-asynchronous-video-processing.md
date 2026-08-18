# Independent services for asynchronous video processing

FIAP X will use independently deployable Java/Quarkus services: an API service accepts and exposes Processing Jobs, while worker services process them asynchronously. Keycloak supplies user authentication, PostgreSQL persists metadata, MinIO stores videos and Image Archives, RabbitMQ carries durable work messages, and a notification service sends failure emails through SMTP. This accepts additional operational complexity in exchange for durable peak handling and independent scaling of CPU-intensive processing.
