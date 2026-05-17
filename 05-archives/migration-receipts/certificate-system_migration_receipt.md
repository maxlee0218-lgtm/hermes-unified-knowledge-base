# certificate-system Migration Receipt

```yaml
source_repo: maxlee0218-lgtm/certificate-system
source_default_branch: main
source_last_commit: 154dde12643e43fd5ca7871abd5b2a4b65f66b99
source_last_message: Initial commit: certificate system
source_size_kb: 1105
target_path: 05-archives/source-repos/certificate-system/
migrated_files: 582
skipped_files: 1
total_files: 583
migrated_dirs: 26
```

## Migrated Paths

```
.gitignore
README.md
app.py
cert_query_to_aitable.py
cert_scrapling_query.py
deploy_local_operational.sh
django_rebuild/README.md
django_rebuild/cert-platform-django.service
django_rebuild/cert_platform/__init__.py
django_rebuild/cert_platform/asgi.py
django_rebuild/cert_platform/settings.py
django_rebuild/cert_platform/urls.py
django_rebuild/cert_platform/wsgi.py
django_rebuild/certs/__init__.py
django_rebuild/certs/admin.py
django_rebuild/certs/apps.py
django_rebuild/certs/jobs.py
django_rebuild/certs/migrations/0001_initial.py
django_rebuild/certs/migrations/__init__.py
django_rebuild/certs/models.py
... and 562 more
```

## Skipped Paths

```
django_rebuild/.env.example
```

## Skip Reason

```text
Skipped files matching:
- .git/ directories
- node_modules/
- venv/
- __pycache__/
- .env files
- Files containing 'token', 'secret', 'key', 'password', 'credential'
- Binary files (.pyc, .pyo, .so, .dll, .exe)
```

## Sensitive Files Excluded

```text
django_rebuild/.env.example
```

## Verification Method

```text
1. File count matches between source and target
2. File tree structure preserved
3. No sensitive files in target
```

## Verification Result

```text
Status: PENDING
Files to migrate: 582
Files skipped: 1
Directories: 26
```

## Can Delete

```yaml
can_delete: pending
reason: Migration not yet verified by GPT
```

## Notes

```text
- This is a raw archive, no curation performed
- Original directory structure preserved
- Content not modified
- Duplicate files not merged
```
