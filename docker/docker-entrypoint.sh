#!/bin/bash
set -e

if [ -n "${UID+x}" ] && [ "${UID}" != "0" ]; then
  usermod -u "$UID" monero 2>/dev/null || true
fi

if [ -n "${GID+x}" ] && [ "${GID}" != "0" ]; then
  groupmod -g "$GID" monero 2>/dev/null || true
fi

echo "$0: assuming uid:gid for monero:monero of $(id -u monero):$(id -g monero)"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  echo "$0: assuming arguments for monerod"
  set -- monerod "$@"
fi

if [ "$(echo "$1" | cut -c1)" = "-" ] || [ "$1" = "monerod" ]; then
  mkdir -p "$MONERO_DATA"
  chmod 700 "$MONERO_DATA"
  # Use find to chown — skips read-only ConfigMap subPath mounts safely
  find "$(getent passwd monero | cut -d: -f6)" -writable -exec chown monero:monero {} + 2>/dev/null || true
  find "$MONERO_DATA" -writable -exec chown monero:monero {} + 2>/dev/null || true
  echo "$0: setting data directory to $MONERO_DATA"
  set -- "$@" --data-dir="$MONERO_DATA"
fi

if [ "$1" = "monerod" ] || [ "$1" = "monero-wallet-rpc" ] || [ "$1" = "monero-wallet-cli" ]; then
  exec gosu monero "$@"
fi

exec "$@"
