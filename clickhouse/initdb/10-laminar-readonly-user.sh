#!/bin/bash
# Creates (or updates) the read-only user Laminar's SQL editor queries as.
# The dashboard grants it SELECT on the Laminar tables and revokes everything
# else on each boot. Runs on every container start.
set -euo pipefail
ro_user="${CLICKHOUSE_RO_USER:-laminar_ro}"
if [[ -z "${CLICKHOUSE_RO_PASSWORD:-}" ]]; then
  echo "laminar: CLICKHOUSE_RO_PASSWORD is not set, skipping the read-only user"
  exit 0
fi
if [[ ! "$ro_user" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
  echo "laminar: CLICKHOUSE_RO_USER must be a simple identifier" >&2; exit 1
fi
pw="${CLICKHOUSE_RO_PASSWORD//\\/\\\\}"; pw="${pw//\'/\\\'}"
"${clickhouseclient[@]}" <<SQL
CREATE USER IF NOT EXISTS ${ro_user} IDENTIFIED WITH sha256_password BY '${pw}';
ALTER USER ${ro_user} IDENTIFIED WITH sha256_password BY '${pw}';
GRANT SELECT ON default.* TO ${ro_user};
SQL
echo "laminar: read-only user ${ro_user} is ready"
