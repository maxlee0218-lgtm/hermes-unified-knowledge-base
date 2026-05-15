# Security Policy

This repository is intended for operational knowledge, not secrets.

## Do Not Commit

- Database hostnames with credentials.
- Usernames and passwords.
- API tokens, cookies, session IDs, or DolphinScheduler login tokens.
- SSH private keys or server passwords.
- Raw production extracts containing personal information.

## Before Push Checklist

Run a secret scan before each push:

```bash
rg -n "password|passwd|pwd|secret|token|AKIA|BEGIN .*PRIVATE KEY|aliyuncs|root@|admin|da_user|hw_dev" .
```

If a real secret is found, remove it from the file and from Git history before pushing.

## Data Handling

- Prefer aggregated examples over raw rows.
- Keep business identifiers only when they are necessary for internal troubleshooting.
- Use private GitHub repositories for operational SQL involving internal table names.

