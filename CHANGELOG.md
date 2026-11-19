# Changelog

## v0.3.4 (2026-11-19)

First release of the template.

- Laminar v0.3.4 (`ghcr.io/lmnr-ai/frontend` and `ghcr.io/lmnr-ai/app-server`, pinned by digest) with the full stack from upstream's `docker-compose-full.yml` (`ENVIRONMENT=FULL`): RabbitMQ 4.2.9 for span processing, Railway Redis for cache and pub/sub, Railway Postgres, ClickHouse 26.5.7.64 and Quickwit v0.9.1.
- Caddy 2.11.9 gateway as the one public URL: the dashboard behind a generated login, `/v1/*` ingestion with project API keys.
- A separate read-only ClickHouse user for the SQL editor and a read-only Postgres role for the SQL tables backed by Postgres (signals, evaluations, datasets).
- Each service waits for the ones it needs before it starts. RabbitMQ and ClickHouse apply their passwords on every boot.
