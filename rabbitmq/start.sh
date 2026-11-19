#!/bin/bash
# Starts RabbitMQ, then makes sure the Laminar user exists with the password
# from RABBITMQ_DEFAULT_PASS. RabbitMQ applies RABBITMQ_DEFAULT_USER/PASS only
# on the first boot of an empty volume, so without this a changed password
# would lock the app server out.
set -euo pipefail
user="${RABBITMQ_DEFAULT_USER:-laminar}"

docker-entrypoint.sh rabbitmq-server &
pid=$!
trap 'kill -TERM "$pid" 2>/dev/null; wait "$pid"; exit $?' TERM INT

if rabbitmqctl -q await_startup --timeout 300 >/dev/null 2>&1; then
  if [[ -n "${RABBITMQ_DEFAULT_PASS:-}" ]]; then
    if rabbitmqctl -q list_users 2>/dev/null | awk '{print $1}' | grep -qx "$user"; then
      printf '%s' "$RABBITMQ_DEFAULT_PASS" | rabbitmqctl -q change_password "$user" >/dev/null 2>&1 \
        || rabbitmqctl -q change_password "$user" "$RABBITMQ_DEFAULT_PASS" >/dev/null
    else
      printf '%s' "$RABBITMQ_DEFAULT_PASS" | rabbitmqctl -q add_user "$user" >/dev/null 2>&1 \
        || rabbitmqctl -q add_user "$user" "$RABBITMQ_DEFAULT_PASS" >/dev/null
    fi
    rabbitmqctl -q set_user_tags "$user" administrator >/dev/null
    rabbitmqctl -q set_permissions -p / "$user" '.*' '.*' '.*' >/dev/null
    echo "laminar: RabbitMQ user $user is ready"
  fi
else
  echo "laminar: RabbitMQ did not finish starting within 300 s" >&2
fi

wait "$pid"
