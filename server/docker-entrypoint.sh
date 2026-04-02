#!/usr/bin/env sh

set -eu

mkdir -p /app/data

echo "[one-keep] sync database schema"
npx prisma db push

echo "[one-keep] start server"
exec node dist/server.js
