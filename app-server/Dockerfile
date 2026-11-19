# Laminar app server (Rust): trace ingestion, queue workers, realtime.
# Official image v0.3.4, pinned by digest.
FROM ghcr.io/lmnr-ai/app-server:v0.3.4@sha256:28f0d9d8c784cc7cca91300285c13cadfe02153d80a51efc2a23777c8bca3d0b

# HTTP API 8000, gRPC ingestion 8001, realtime/consumer 8002.
# FULL mode uses RabbitMQ for span processing and Redis for cache and pub/sub,
# as upstream's docker-compose-full.yml does.
ENV PORT=8000 \
    GRPC_PORT=8001 \
    CONSUMER_PORT=8002 \
    ENVIRONMENT=FULL \
    CLICKHOUSE_USER=laminar \
    CLICKHOUSE_RO_USER=laminar_ro \
    QUICKWIT_SPANS_INDEX_ID=spans_v2

COPY start.sh /app-server/railway-start.sh
CMD ["bash", "/app-server/railway-start.sh"]
