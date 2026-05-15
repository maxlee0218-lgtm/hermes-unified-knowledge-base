# Django Rebuild

这是基于 `Django + Django Admin + RQ` 的证书管理平台重建版本。

## 启动

```bash
cd django_rebuild
cp .env.example .env
../.venv/bin/python manage.py migrate
../.venv/bin/python manage.py createsuperuser
../.venv/bin/python manage.py runserver
```

## 地址

- 仪表盘: `/`
- 健康检查: `/health/`
- 管理后台: `/admin/`

## 队列

默认读取 `REDIS_URL=redis://127.0.0.1:6379/0`

```bash
cd django_rebuild
../.venv/bin/rq worker cert_queries
```

## Gunicorn 本地启动

```bash
cd django_rebuild
chmod +x deploy_local.sh
./deploy_local.sh
```
