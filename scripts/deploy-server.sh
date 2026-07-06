#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SERVER_USER="${SERVER_USER:-root}"
SERVER_HOST="${SERVER_HOST:-119.45.243.103}"
SERVER_PATH="${SERVER_PATH:-/www/wwwroot/liqing.eatdesk.net/server}"
SERVER_PASSWORD="${SERVER_PASSWORD:-}"
PM2_APP_NAME="${PM2_APP_NAME:-one-keep-server}"
DB_PUSH="${DB_PUSH:-0}"

cd "$PROJECT_ROOT"

RSYNC_RSH="ssh -o StrictHostKeyChecking=no"
SSH_BIN=(ssh -o StrictHostKeyChecking=no)
if [[ -n "$SERVER_PASSWORD" ]]; then
  if ! command -v sshpass >/dev/null 2>&1; then
    echo "[deploy-server] sshpass is required when SERVER_PASSWORD is set" >&2
    exit 1
  fi
  RSYNC_RSH="sshpass -p $SERVER_PASSWORD ssh -o StrictHostKeyChecking=no"
  SSH_BIN=(sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no)
fi

echo "[deploy-server] syncing server sources to $SERVER_USER@$SERVER_HOST:$SERVER_PATH"
rsync -av --delete -e "$RSYNC_RSH" \
  --exclude node_modules \
  --exclude dist \
  --exclude logs \
  --exclude .env \
  "$PROJECT_ROOT/server/" \
  "$SERVER_USER@$SERVER_HOST:$SERVER_PATH/"

REMOTE_CMD=$'set -euo pipefail\n'
REMOTE_CMD+=$'cd '"$SERVER_PATH"$'\n'
REMOTE_CMD+=$'export PATH=/usr/local/nodejs20/bin:$PATH\n'
REMOTE_CMD+=$'if grep -q "^DATABASE_URL=\\"\\?mysql:" .env 2>/dev/null; then cp prisma/schema_mysql.prisma prisma/schema.prisma; fi\n'
REMOTE_CMD+=$'npm ci\n'
REMOTE_CMD+=$'npm run db:generate\n'
if [[ "$DB_PUSH" == "1" ]]; then
  REMOTE_CMD+=$'npm run db:push\n'
fi
REMOTE_CMD+=$'npm run build\n'
REMOTE_CMD+=$'pm2 restart '"$PM2_APP_NAME"$' --update-env\n'

echo "[deploy-server] installing dependencies, building, and restarting $PM2_APP_NAME"
"${SSH_BIN[@]}" "$SERVER_USER@$SERVER_HOST" "$REMOTE_CMD"

echo "[deploy-server] health check"
for attempt in {1..10}; do
  if curl -fsS "https://liqing.eatdesk.net/api/health"; then
    break
  fi
  if [[ "$attempt" == "10" ]]; then
    exit 1
  fi
  sleep 2
done

echo
echo "[deploy-server] done"
