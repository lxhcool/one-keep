#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SERVER_USER="${SERVER_USER:-root}"
SERVER_HOST="${SERVER_HOST:-119.45.243.103}"
SERVER_PATH="${SERVER_PATH:-/www/wwwroot/liqing.eatdesk.net/client/}"
API_BASE_URL="${API_BASE_URL:-https://liqing.eatdesk.net}"
SERVER_PASSWORD="${SERVER_PASSWORD:-}"

cd "$PROJECT_ROOT/client"

echo "[deploy-client] building Flutter web with API_BASE_URL=$API_BASE_URL"
flutter build web --release --dart-define=API_BASE_URL="$API_BASE_URL"

cd "$PROJECT_ROOT"

RSYNC_RSH="ssh -o StrictHostKeyChecking=no"
if [[ -n "$SERVER_PASSWORD" ]]; then
  if ! command -v sshpass >/dev/null 2>&1; then
    echo "[deploy-client] sshpass is required when SERVER_PASSWORD is set" >&2
    exit 1
  fi
  RSYNC_RSH="sshpass -p $SERVER_PASSWORD ssh -o StrictHostKeyChecking=no"
fi

echo "[deploy-client] syncing build/web to $SERVER_USER@$SERVER_HOST:$SERVER_PATH"
rsync -av --delete -e "$RSYNC_RSH" \
  "$PROJECT_ROOT/client/build/web/" \
  "$SERVER_USER@$SERVER_HOST:$SERVER_PATH"

echo "[deploy-client] done"
