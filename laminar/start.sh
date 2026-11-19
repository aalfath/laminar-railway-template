#!/bin/sh
# Hashes the dashboard password and starts Caddy.
set -eu
export LAMINAR_USERNAME="${LAMINAR_USERNAME:-admin}"
: "${LAMINAR_PASSWORD:?LAMINAR_PASSWORD is required}"
: "${FRONTEND_HOST:?FRONTEND_HOST is required}"
: "${APP_SERVER_HOST:?APP_SERVER_HOST is required}"
export PORT="${PORT:-8080}"
export FRONTEND_PORT="${FRONTEND_PORT:-5667}"
export APP_SERVER_PORT="${APP_SERVER_PORT:-8000}"
LAMINAR_PASSWORD_HASH="$(caddy hash-password --plaintext "$LAMINAR_PASSWORD")"
export LAMINAR_PASSWORD_HASH
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
