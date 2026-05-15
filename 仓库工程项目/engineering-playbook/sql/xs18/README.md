# XS18 Investigation SQL

This folder contains reusable SQL from an `ads_gx_xs_18` style data warehouse chain.

## Files

- `find_dolphin_xs18_blockers.sql`: find Dolphin tasks related to the chain.
- `find_dolphin_online_schedules_xs18_blockers.sql`: find released online schedules that can affect the chain.
- `find_dolphin_recent_xs18_blockers.sql`: inspect recent task instances and possible blockers.
- `validate_xs18_march*.sql`: compare old and new logic over a March validation window.
- `xs18_index_only.sql`: index-only optimization proposal.
- `xs_18_final.sql`: final refresh rewrite pattern using staging and safer refresh flow.

## Lessons

- Search Dolphin metadata by table names, not only workflow names.
- Validate a rewritten chain on a bounded historical month before replacing production logic.
- Keep index-only and logic-rewrite plans separate so risk can be staged.

