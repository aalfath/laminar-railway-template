# RabbitMQ: queues spans between ingestion and processing, as in upstream's
# docker-compose-full.yml. Official image 4.2.9 (alpine), pinned by digest.
FROM rabbitmq:4.2.9-alpine@sha256:cd4f5c5bb4ffe530dba84770a8d139b8518470cdd385fec9cf014ebfff6bb009

# A fixed node name: RabbitMQ keeps its data under the node name, and Railway
# gives every deploy a new hostname, so the default name would start empty.
# The Prometheus plugin (on by default in this image) serves /metrics on 15692
# without a login, which Railway uses as the health check.
ENV RABBITMQ_NODENAME=rabbit@localhost \
    RABBITMQ_DEFAULT_USER=laminar \
    PORT=15692
