# Default GitHub Operating Mandate

## Purpose

This document records the standing operating mandate for the multi-agent warehouse rebuild coordination system.

The user has authorized the coordinator ChatGPT to directly use the connected GitHub repositories as the working substrate for this project, without repeatedly asking for permission for normal read / issue / PR / documentation coordination operations.

## Default Repositories

Primary data rebuild repository:

```text
maxlee0218-lgtm/warehouse-rebuild
```

External infrastructure / multi-agent runtime repository:

```text
maxlee0218-lgtm/openclaw-v2-infra
```

## Default Operating Rule

For future project work, the coordinator should directly use GitHub as the fact source and coordination layer.

Allowed by default:

1. Read repository files.
2. Read issues, PRs, commits, comments, labels, and diffs.
3. Create GitHub issues for planned work.
4. Add labels to issues and PRs.
5. Comment on issues and PRs for coordination, review, and handoff.
6. Create or update documentation files that record coordination state, architecture decisions, task plans, and review notes.
7. Register external project status into `warehouse-rebuild` coordination documents.
8. Create review comments when requested by project flow.

## Default Review / Coordination Behavior

The coordinator should not repeatedly ask the user for authorization before routine GitHub coordination actions.

Instead, it should:

```text
1. Inspect the relevant repository / issue / PR directly.
2. Make a best-effort judgment.
3. Record durable state into GitHub files or issue comments.
4. Report the result to the user.
```

## Safety Boundaries

This mandate does not authorize unsafe or secret-bearing operations.

Still forbidden by default:

1. Writing real API keys, database passwords, tokens, or secrets into any repository, issue, PR, log, or comment.
2. Modifying production databases.
3. Running or generating write-capable production SQL unless a future reviewed stage explicitly permits it.
4. Executing `DROP / DELETE / UPDATE / INSERT / TRUNCATE / INSERT OVERWRITE` against production systems.
5. Merging PRs that change security boundaries without review.
6. Enabling auto-merge without explicit project-level approval.
7. Deleting files, closing issues, or merging PRs when the project state is ambiguous.

## SQL Boundary For Current Warehouse Rebuild Stage

Current warehouse rebuild SQL is read-only unless explicitly reviewed in a future safe stage:

```text
Allowed:
- SELECT
- SHOW
- DESC
- EXPLAIN

Forbidden by default:
- DROP
- DELETE
- UPDATE
- INSERT
- TRUNCATE
- INSERT OVERWRITE
- CREATE TABLE AS against production
```

## Multi-Agent Coordination Default

The coordinator should assume this operating model:

```text
warehouse-rebuild = data lineage / SQL / recon / audit fact source
openclaw-v2-infra = multi-agent runtime / Model Gateway / readonly tool architecture fact source
GitHub Issue = task order
Issue label = state machine
Commit or PR = execution result
Issue / PR comment = handoff receipt
```

## Codex Project Boundary

Codex may run in a separate project.

That is acceptable as long as Codex reads and writes through the shared GitHub repositories and follows the issue-label workflow.

Codex should not rely on private chat context from this ChatGPT project.

## Current External Project State

`openclaw-v2-infra` Stage 7.6 is registered in:

```text
docs/external_projects/openclaw-v2-infra-stage07_6.md
```

Stage 7.6 PR:

```text
maxlee0218-lgtm/openclaw-v2-infra#2
Stage 7.6: Align Model Gateway with OpenAI-compatible proxy
```

Current next step for that external repo:

```text
Architecture review, then Stage 8 database readonly tools.
```

## Persistence Note

If a future assistant or agent lacks chat history, it should read this file together with:

```text
README.md
docs/05_multi_agent_coordination.md
docs/external_projects/openclaw-v2-infra-stage07_6.md
lineage/ads_sc_xl_13/05_missing_links.md
lineage/ads_sc_xl_13/06_next_rebuild_order.md
```

This file is the durable authorization / operating-mandate record for routine GitHub-based project coordination.
