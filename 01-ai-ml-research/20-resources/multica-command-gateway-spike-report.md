# Multica Command Gateway SPIKE Report

Date: 2026-05-10

## Summary

Implemented the Multica Command Gateway minimum prototype in the `llm-wiki`
repository. Phase one is dry-run only: it reads command YAML files, renders a
target-specific `multica issue create` command, writes audit JSON, and does not
create a real Multica Issue.

## Directory Creation

Created and verified:

```text
runtime-commands/pending/
runtime-commands/running/
runtime-commands/done/
runtime-commands/failed/
```

Also added:

```text
runtime-commands/README.md
runtime-commands/process_runtime_command.py
```

## Script Implementation

Implemented:

```text
runtime-commands/process_runtime_command.py
```

Supported behavior:

- Scans `runtime-commands/pending/*.yaml`.
- Supports `type=create_issue`.
- Defaults to `mode=dry_run`.
- Renders a `multica issue create` command in dry-run mode.
- Writes result JSON to `runtime-commands/done/*.json` or `runtime-commands/failed/*.json`.
- Copies command files to `running/` for audit but does not delete originals.
- Does not execute arbitrary shell commands.
- Keeps `mode=approved` disabled for this SPIKE.

## CLI Probe

Target Multica CLI:

```text
C:\Users\39169\.multica\bin\multica.exe
```

Required probes were executed on the Windows runtime host:

```text
multica --help
multica issue --help
multica issue create --help
multica issue list --help
multica workspace get --output json
```

`multica issue create --help` returned these real flags:

```text
--assignee string      Assignee name (member or agent; fuzzy match)
--assignee-id string   Assignee UUID (mutually exclusive with --assignee)
--attachment strings   File path(s) to attach (can be specified multiple times)
--description string   Issue description (decodes \n, \r, \t, \\; pipe via --description-stdin to preserve literal backslashes)
--description-stdin    Read issue description from stdin (preserves multi-line content verbatim)
--due-date string      Due date (RFC3339 format)
--output string        Output format: table or json (default "json")
--parent string        Parent issue ID
--priority string      Issue priority
--project string       Project ID
--status string        Issue status
--title string         Issue title (required)
```

`multica issue list --help` returned these relevant flags:

```text
--assignee string
--assignee-id string
--full-id
--limit int
--offset int
--output string
--priority string
--project string
--status string
```

`multica workspace get --output json` confirmed workspace:

```json
{
  "id": "1496e790-22d8-4e55-8657-222a40bb9715",
  "issue_prefix": "LEE",
  "name": "LEE",
  "slug": "lee"
}
```

## Dry-Run Command File

Created:

```text
runtime-commands/pending/CMD-20260510-001-kimi-claw-handshake.yaml
```

Target title:

```text
Kimi Claw Windows 接入 Multica 握手验证
```

## Dry-Run Test

Executed on the Windows runtime host:

```text
D:\AIWorker\agent-tools\Python312\python.exe runtime-commands\process_runtime_command.py
```

Observed dry-run output:

```text
CMD-20260510-001-kimi-claw-handshake.yaml: dry_run_rendered -> C:\root\wiki\runtime-commands\done\CMD-20260510-001-kimi-claw-handshake.json
```

Rendered command:

```text
'C:\Users\39169\.multica\bin\multica.exe' issue create --title 'Kimi Claw Windows 接入 Multica 握手验证' --description-stdin --assignee 'Kimi Claw Windows Worker' --output json
```

The script retained labels in the audit JSON only, because this Multica CLI
version does not advertise a label flag for `issue create`.

## Result JSON

Done JSON:

```text
runtime-commands/done/CMD-20260510-001-kimi-claw-handshake.json
```

Failed directory:

```text
runtime-commands/failed/
```

No failed JSON was produced by the final clean dry-run.

The done JSON includes:

```json
{
  "status": "dry_run_rendered",
  "created_issue": false,
  "executed": false
}
```

## Safety Verification

Real Multica Issue created:

```text
No
```

Production modified:

```text
No
```

DolphinScheduler modified:

```text
No
```

DataX modified:

```text
No
```

Files deleted:

```text
No
```

Secrets, tokens, or connection strings printed:

```text
No
```

`mode=approved` enabled:

```text
No
```

## Git

Commit message:

```text
spike: add multica command gateway dry-run
```

Git commit id:

```text
SPIKE implementation commit: 67d6c084f3dd
Base commit before this SPIKE: 08d2a6a299d4
```

## GPT Git Task Ingress Update

Follow-up update: GPT sends tasks through Git command files, not direct Multica
comments. The gateway has therefore been extended from dry-run-only SPIKE into a
controlled Git ingress path.

New behavior:

- `mode=dry_run` remains the default.
- `mode=approved` is supported only for `type=create_issue`.
- Approved mode requires both:
  - `approval: APPROVED_CREATE_ISSUE`
  - non-empty `approved_by`
- The script still never executes arbitrary shell commands.
- Real issue creation uses direct subprocess argv execution of:
  `multica issue create`
- Existing successful `done/<command_id>.json` files are idempotency guards; they
  prevent duplicate issue creation if Git/processors rerun the same command.
- Workspace is allowlisted to `default` / `lee`.
- Labels are still recorded in audit JSON only because the current CLI has no
  `issue create --label` flag.

This means the intended GPT collaboration path is:

```text
GPT commit/push YAML -> runtime-commands/pending/*.yaml
Codex/Runtime processor pulls Git -> process_runtime_command.py
approved create_issue -> Multica issue
Runtime首脑 routes -> domain agent executes
验收官/审计官 verdict -> Runtime首脑 closes
done/*.json records created issue
```

## Next Step

The gateway is ready for controlled approved issue creation, but still needs an
always-on Git watcher/daemon if the team should pick up GPT commits without
manual `git pull` + processor execution.

Recommended next hardening:

- Install a small daemon or scheduled task that runs:
  `git pull --ff-only && python3 runtime-commands/process_runtime_command.py`
- Require signed commits or an allowlisted GitHub author for approved commands.
- Add a `runtime-commands/done` Git push-back step so GPT can read created issue
  identifiers from Git without querying Multica.
- Add an integration test command that creates a harmless dry-run issue assigned
  to Runtime首脑, then verifies Runtime routes instead of executing.
