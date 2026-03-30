#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "[one-keep] install dependencies"
npm ci

echo "[one-keep] generate prisma client"
npm run db:generate

echo "[one-keep] sync database schema"
npm run db:push

echo "[one-keep] build server"
npm run build

mkdir -p logs

if command -v pm2 >/dev/null 2>&1; then
  echo "[one-keep] reload pm2"
  pm2 startOrReload ecosystem.config.json --update-env
  pm2 save
else
  echo "[one-keep] pm2 not found, start with npm start"
  npm start
fi
