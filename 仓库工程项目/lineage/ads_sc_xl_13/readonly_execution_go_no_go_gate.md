# readonly execution go/no-go gate

| Gate ID | Gate name | Required evidence | Current status | Can proceed? | Reason | Next action |
|---|---|---|---|---|---|---|
| `DRY-001` | readonly dry-run package exists | runbook / ledger / wrapper SQL / summary | `ready` | `Yes` | dry-run artifacts are now present | collect evidence |
| `DRY-002` | P1 evidence ledger ready | ledger rows for all P1 chains | `ready` | `Yes` | template is complete | collect evidence |
| `DRY-003` | candidate validation SQL ready | candidate inspect/recon SQL available | `ready` | `Yes` | validation SQL exists | collect evidence |
| `DRY-004` | complete combined_local readiness | all P1 chains executed/closed | `blocked` | `No` | actual readonly evidence is still missing | keep blocked |

## Rule

- readonly dry-run pass 不等于 complete combined_local pass
- 任何 P1 支撑链缺 actual evidence，则 complete combined_local 仍 blocked
