#!/bin/bash
# Waits for the services the app server connects to at boot, then starts it.
# Same order as upstream's docker-compose-full.yml: Postgres, RabbitMQ, Redis,
# ClickHouse and Quickwit first. The app server gives up on Quickwit for good
# if it can't reach it at boot, and crashes if RabbitMQ isn't up.
set -euo pipefail

deadline=$(( $(date +%s) + ${WAIT_TIMEOUT:-240} ))

hostport() { # URL [default port] -> "host port"
  local rest="${1#*://}"; rest="${rest#*@}"; rest="${rest%%/*}"; rest="${rest%%\?*}"
  local host port
  if [[ "$rest" == \[* ]]; then host="${rest%%]*}"; host="${host#[}"; port="${rest##*]:}"; [[ "$port" == "$rest" ]] && port=""
  else host="${rest%%:*}"; port="${rest##*:}"; [[ "$port" == "$rest" ]] && port=""; fi
  echo "$host ${port:-$2}"
}

wait_for() { # name host port
  local name=$1 host=$2 port=$3 logged=0
  while ! (exec 3<>"/dev/tcp/$host/$port") 2>/dev/null; do
    if (( $(date +%s) > deadline )); then echo "[wait] $name ($host:$port) still not reachable, starting anyway"; return 0; fi
    (( logged )) || { echo "[wait] waiting for $name ($host:$port)"; logged=1; }
    sleep 2
  done
}

[[ -n "${DATABASE_URL:-}" ]] && wait_for Postgres $(hostport "$DATABASE_URL" 5432)
[[ -n "${RABBITMQ_URL:-}" ]] && wait_for RabbitMQ $(hostport "$RABBITMQ_URL" 5672)
[[ -n "${REDIS_URL:-}" ]] && wait_for Redis $(hostport "$REDIS_URL" 6379)
[[ -n "${CLICKHOUSE_URL:-}" ]] && wait_for ClickHouse $(hostport "$CLICKHOUSE_URL" 8123)
[[ -n "${QUICKWIT_INGEST_URL:-}" ]] && wait_for Quickwit $(hostport "$QUICKWIT_INGEST_URL" 7281)
echo "[wait] dependencies are up"

exec ./app-server
