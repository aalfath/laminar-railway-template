# ClickHouse for Laminar's spans, traces and evaluations.
# Official image 26.5.7.64 (the 26.5 line upstream's compose uses), pinned by digest.
FROM clickhouse/clickhouse-server:26.5.7.64@sha256:84d05b9c205e8de9d8e471fc8fbb3aaf0c07a8bec1bd57ac3a4a4ac2399abe38

# Users: laminar (admin, used by the dashboard and app server) and laminar_ro
# (read-only, used by Laminar's SQL editor). Their passwords, CLICKHOUSE_PASSWORD
# and CLICKHOUSE_RO_PASSWORD, come from the template variables.
# Access management lets the admin create the read-only user, and the init
# script runs on every boot so a changed password is applied.
ENV CLICKHOUSE_USER=laminar \
    CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT=1 \
    CLICKHOUSE_ALWAYS_RUN_INITDB_SCRIPTS=1 \
    CLICKHOUSE_RO_USER=laminar_ro \
    MALLOC_CONF=thp:never

COPY config.d/ /etc/clickhouse-server/config.d/
COPY users.d/ /etc/clickhouse-server/users.d/
COPY initdb/ /docker-entrypoint-initdb.d/
