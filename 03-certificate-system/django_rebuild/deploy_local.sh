#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$BASE_DIR/.." && pwd)"
VENV_DIR="$ROOT_DIR/.venv"
ENV_FILE="$BASE_DIR/.env"

if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

if [ ! -f "$ENV_FILE" ]; then
  cp "$BASE_DIR/.env.example" "$ENV_FILE"
fi

set -a
source "$ENV_FILE"
set +a

pip install -r "$ROOT_DIR/requirements.txt"

cd "$BASE_DIR"
python manage.py migrate
python manage.py collectstatic --noinput

if [ -n "${DJANGO_SUPERUSER_USERNAME:-}" ] && [ -n "${DJANGO_SUPERUSER_PASSWORD:-}" ]; then
  python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
username='${DJANGO_SUPERUSER_USERNAME}'
email='${DJANGO_SUPERUSER_EMAIL:-admin@example.com}'
password='${DJANGO_SUPERUSER_PASSWORD}'
if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username=username, email=email, password=password)
"
fi

exec gunicorn --config "$BASE_DIR/gunicorn.conf.py" cert_platform.wsgi:application
