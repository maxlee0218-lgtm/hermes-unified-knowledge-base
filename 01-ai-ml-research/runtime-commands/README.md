# Multica Command Gateway

Minimal audited command-file gateway for Multica runtime operations.

Default mode: dry-run.

Approved mode can create a real Multica issue, but only for `type=create_issue`
and only when the command file contains both:

```yaml
mode: approved
approval: APPROVED_CREATE_ISSUE
approved_by: <human-or-runtime-name>
```

Supported command files:

```text
runtime-commands/pending/*.yaml
```

Supported type:

```text
create_issue
```

The processor renders a `multica issue create` command and writes an audit JSON
to `done/` or `failed/`. In approved mode it executes the Multica CLI directly
with an argument array, never via shell interpolation. It does not delete
original command files and does not execute arbitrary shell commands.

Example approved command:

```yaml
command_id: CMD-YYYYMMDD-001-example
type: create_issue
mode: approved
approval: APPROVED_CREATE_ISSUE
approved_by: Runtime首脑
workspace: default
title: Example task from GPT via Git
assignee: Runtime首脑
priority: high
status: todo
body: |
  Goal: create a Multica task from a Git command file.

  Forbidden:
  - no production DB changes
  - no file deletion
  - no secrets
forbidden_actions:
  - modify_production_db
  - delete_files
  - expose_secrets
```

Idempotency: if a command already has a `done/<command_id>.json` with
`created_issue=true` or `executed=true`, the processor skips it and does not
create a duplicate issue.
