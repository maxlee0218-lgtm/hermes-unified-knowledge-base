# SQL Library

This directory stores sanitized operational SQL patterns.

## Rules

- Keep credentials out of SQL files.
- Prefer reusable investigation and validation SQL over one-off production patches.
- Add comments explaining the business scenario and safety constraints.
- For destructive SQL, include backup and validation queries in the same file.

## Current Topics

- `xs18/`: investigation, validation, indexing, and final refresh plan for an `ads_gx_xs_18` style sales/inventory chain.

