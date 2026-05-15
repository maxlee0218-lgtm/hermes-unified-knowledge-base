# Redaction Guide

## Replace Before Commit

Use placeholders for sensitive values:

- `<db-host>`
- `<db-port>`
- `<db-user>`
- `<db-password>`
- `<server-ip>`
- `<ssh-user>`
- `<api-token>`

## Keep Or Remove?

Usually safe in a private engineering repository:

- table names
- report names
- workflow/task names
- sanitized SQL patterns
- aggregate row counts

Usually unsafe:

- passwords
- direct connection strings
- public IPs with usernames
- employee personal records
- raw certificate/personnel exports

## Pre-Push Scan

```bash
rg -n "password|passwd|pwd|secret|token|BEGIN .*PRIVATE KEY|ssh-rsa|aliyuncs|root@|admin|da_user|hw_dev" .
```

Review every hit manually.

