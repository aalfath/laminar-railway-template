#!/bin/sh
# End-to-end check through the gateway: login gate, sign-in, workspace and
# project, project API key, one OTLP/HTTP trace, and the trace in the API.
# Usage: BASE=https://your-app.up.railway.app USER=admin PASS=... sh test/smoke.sh
# Needs curl and python3.
set -eu
BASE="${BASE:-http://localhost:8080}"
USER="${USER:-admin}"; PASS="${PASS:?set PASS}"
J=$(mktemp); trap 'rm "$J"' EXIT
c() { curl -sS -b "$J" -c "$J" -u "$USER:$PASS" "$@"; }

echo "health: $(curl -s -o /dev/null -w '%{http_code}' "$BASE/healthz")"
echo "dashboard without login: $(curl -s -o /dev/null -w '%{http_code}' "$BASE/sign-in")"
echo "dashboard with login: $(c -o /dev/null -w '%{http_code}' "$BASE/sign-in")"
echo "api without key: $(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/v1/traces")"

c -o /dev/null -X POST -H 'Content-Type: application/json' -H "Origin: $BASE" \
  -d '{"email":"smoke@example.com","name":"Smoke"}' "$BASE/api/auth/sign-in/local-email"
WS=$(c -X POST -H 'Content-Type: application/json' -H "Origin: $BASE" \
  -d '{"name":"Smoke WS","projectName":"smoke"}' "$BASE/api/workspaces")
PID=$(echo "$WS" | python3 -c 'import json,sys;print(json.load(sys.stdin)["projectId"])')
echo "project: $PID"
KEY=$(c -X POST -H 'Content-Type: application/json' -H "Origin: $BASE" -d '{"name":"smoke"}' \
  "$BASE/api/projects/$PID/api-keys" | python3 -c 'import json,sys;print(json.load(sys.stdin)["value"])')
echo "api key: created (${#KEY} chars)"

TID=$(python3 -c 'import secrets;print(secrets.token_hex(16))'); SID=$(python3 -c 'import secrets;print(secrets.token_hex(8))')
NOW=$(python3 -c 'import time;print(time.time_ns())')
BODY=$(cat <<JSON
{"resourceSpans":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"smoke"}}]},
 "scopeSpans":[{"scope":{"name":"smoke"},"spans":[{"traceId":"$TID","spanId":"$SID","name":"smoke-span",
 "kind":1,"startTimeUnixNano":"$((NOW-1000000000))","endTimeUnixNano":"$NOW",
 "attributes":[{"key":"lmnr.span.input","value":{"stringValue":"\"hello laminar\""}},
 {"key":"lmnr.span.output","value":{"stringValue":"\"hi\""}}]}]}]}]}
JSON
)
echo "ingest: $(curl -sS -o /dev/null -w '%{http_code}' -X POST -H "Authorization: Bearer $KEY" \
  -H 'Content-Type: application/json' -d "$BODY" "$BASE/v1/traces")"
echo "trace id: $TID"
printf '%s\n' "$PID" > /tmp/laminar-smoke-project
printf '%s\n' "$KEY" > /tmp/laminar-smoke-key
