# Executor No Midpoint Prompt Policy

## Purpose

This policy captures the execution style expected from the Codex executor in `warehouse-rebuild`.

## Rule

When an issue is accepted and falls within the safety boundary:

- do not stop in the middle to ask whether to continue
- do not ask for routine confirmation
- keep moving until the issue is either:
  - completed
  - safely blocked
  - or reaches a hard external dependency

## What counts as a hard blocker

Only pause and mark blocked when at least one of these is true:

1. A required repository fact source is missing and cannot be reconstructed safely.
2. A required GitHub write action cannot be performed after reasonable retries.
3. The issue would require crossing the production SQL safety boundary.
4. The issue depends on a still-running task and strict serial execution forbids overlap.
5. The issue asks for a conclusion that cannot be supported without inventing facts.

## What does not justify interrupting

- ordinary branching choices
- small file structure decisions
- whether to keep documenting while evidence is partial
- whether to proceed from one read-only validation layer to the next when the issue already instructs it

## Expected executor behavior

1. Read the issue and current fact files.
2. Make conservative assumptions inside the safety boundary.
3. Write all findings into repository files.
4. Commit only what is justified by available evidence.
5. Comment back on the issue with the current result.
