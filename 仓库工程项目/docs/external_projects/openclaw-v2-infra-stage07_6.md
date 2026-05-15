# External Project Register: openclaw-v2-infra Stage 7.6

## Purpose

This file connects the external Codex project `openclaw-v2-infra` into the `warehouse-rebuild` multi-agent coordination system.

The external project is treated as infrastructure / execution-environment work that supports the broader multi-agent operating model.

## External Repository

```text
maxlee0218-lgtm/openclaw-v2-infra
```

## Current Stage

```text
Stage 7.6: Align Model Gateway with OpenAI-compatible proxy
```

## Branch

```text
stage/07_6-model-gateway-proxy-alignment
```

## Pull Request

```text
maxlee0218-lgtm/openclaw-v2-infra#2
Stage 7.6: Align Model Gateway with OpenAI-compatible proxy
```

## Commit

```text
623591e341a19c5f33b6e3bb095c560b6e24736c
```

## PR Status Snapshot

As of 2026-04-26:

- PR state: open
- Draft: false
- Mergeable: true
- Changed files: 11
- Commits: 1
- Acceptance reply: 001-028 posted in PR comment
- `project_repo_check.sh`: PASS

## Unified Model Chain

The accepted model chain is:

```text
Agent
-> Model Gateway
-> OpenAI-compatible proxy / relay API
-> Real model provider
```

Expanded operating chain:

```text
User / PocketClaw / OpenClaw
-> ChiefShrimp
-> Task Center
-> Agent Role Package
-> Model Gateway
-> OpenAI-compatible proxy / relay API
-> Real model provider
```

## Stage 7.6 File Changes

The external PR reports updates to:

```text
ARCHITECTURE.md
CHANGELOG.md
README.md
ROADMAP.md
SECURITY.md
config-templates/model_policy.json
config-templates/model_routes.json
config-templates/models.json
docs/model-gateway.md
scripts/linux/project_repo_check.sh
stages/stage07_6-model-gateway-proxy-alignment.md
```

## Contract Imported Into warehouse-rebuild Coordination

The following rules are now part of our multi-agent coordination assumptions:

1. Agent role packages declare `model_profile` only.
2. Model Gateway owns provider selection, base URL, API key binding, fallback, retry, timeout, cooldown, cost logging, and error logging.
3. Real providers stay behind an OpenAI-compatible proxy / relay API.
4. No real API key is stored in Git.
5. No real proxy base URL is stored in Git.
6. Windows / WSL2 / Hermes do not store model keys.
7. PocketClaw does not call models directly.
8. Agent-side infinite retry is forbidden.
9. Database tools must not become a side channel for model credentials.
10. `api_key_env`, `base_url_env`, `*_ENV`, and `replace_me` placeholders are allowed template tokens and should not be flagged as leaked secrets.

## Validation Receipt

The PR comment reports the following relevant acceptance points:

```text
001 branch created: yes
002 branch name: stage/07_6-model-gateway-proxy-alignment
003 README.md model chain updated: yes
004 ARCHITECTURE.md model chain updated: yes
005 SECURITY.md model security boundary updated: yes
006 docs/model-gateway.md created or updated: yes
007 config-templates/models.json updated: yes
008 config-templates/model_routes.json updated: yes
009 config-templates/model_policy.json updated: yes
010 provider_type=openai_compatible_proxy explicit: yes
011 OPENCLAW_MODEL_API_KEY used: yes
012 OPENCLAW_MODEL_BASE_URL used: yes
013 no real API key written: yes
014 no real base_url written: yes
015 agents declare model_profile only: yes
016 Windows / WSL2 / Hermes do not save model keys: yes
017 PocketClaw does not directly call models: yes
018 503 / rate limit / No healthy accounts handling strategy added: yes
019 project_repo_check.sh passed: yes
020 committed: yes
021 commit hash: 623591e
022 pushed: yes
023 PR created: yes
024 PR: https://github.com/maxlee0218-lgtm/openclaw-v2-infra/pull/2
025 recommends entering Stage 8: yes
026 failure step: none
027 failure class: none
028 next action: architecture review, then Stage 8 database readonly tools
```

## Relationship To warehouse-rebuild

`warehouse-rebuild` remains the data lineage / warehouse rebuild fact source.

`openclaw-v2-infra` is registered as the external infrastructure project for:

- multi-agent runtime architecture
- model gateway contract
- model routing and provider abstraction
- future readonly database tool guardrails
- Codex / agent execution environment constraints

The two repositories must remain loosely coupled:

```text
warehouse-rebuild
  owns ADS_SC_XL_13 lineage, SQL, recon, audit, and data rebuild decisions

openclaw-v2-infra
  owns agent runtime, model gateway, model security boundary, and future readonly tool architecture
```

## Stage 8 Bridge

The next infrastructure stage should be treated as:

```text
Stage 8: database readonly tools
```

Stage 8 must preserve these constraints:

1. Readonly database access only.
2. No write-capable database credentials.
3. No model credentials in database tool configs.
4. No model provider config routed through database tools.
5. No PocketClaw direct database access.
6. No Windows direct database access.
7. No bypass of Tool Gateway for database access.
8. No bypass of Model Gateway for model access.
9. All generated SQL for warehouse work stays within `SELECT / SHOW / DESC / EXPLAIN` unless explicitly reviewed in a future safe stage.

## Current Integration Decision

Status in our coordination system:

```text
external_project_registered: yes
stage_07_6_status: completed_on_branch
pr_status: open_mergeable
architecture_review_required: yes
stage_8_allowed_after_review: yes
warehouse_rebuild_direct_change_required: no
```

## Next Coordinator Action

Recommended next action from this coordinator:

1. Do not merge Stage 7.6 automatically.
2. Request architecture review on `openclaw-v2-infra#2`.
3. After review, allow Codex to create Stage 8 issue / PR for readonly database tools.
4. Keep `warehouse-rebuild` data-chain tasks separate from `openclaw-v2-infra` runtime/tooling tasks.
