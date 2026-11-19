#!/bin/sh
# Waits for Postgres, ClickHouse and Quickwit, then starts the dashboard.
# On boot the dashboard runs the Postgres and ClickHouse migrations and
# creates the Quickwit index, so its dependencies must answer first.
set -eu
node /app/railway/wait.mjs
exec node server.js
