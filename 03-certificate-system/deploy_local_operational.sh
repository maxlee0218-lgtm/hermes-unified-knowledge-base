#!/bin/bash
set -e

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$APP_DIR"

set -a
source "$APP_DIR/.env"
set +a

echo "启动本地证书系统..."
APP_PORT="${APP_PORT:-8020}"
exec "$APP_DIR/.venv/bin/gunicorn" -w 1 -b "127.0.0.1:${APP_PORT}" --timeout 180 operational_app:app
