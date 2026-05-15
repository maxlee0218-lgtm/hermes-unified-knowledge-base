# Parallel Task Pool

## Track A can continue

| Task name | Track | Can run now? | Conflict risk | Allowed write path | Blocked by | Expected output | Recommended package size |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Support-chain execution validation bundle | Track A | Yes, if read-only execution environment exists | medium | `lineage/ads_sc_xl_13/`, `sql/inspect/`, `sql/recon/`, `audit/`, `handoff/` | real read-only execution access | executed results for `dim_date_info`, `with_attr_value`, `ads_sc_xl_01_local`, `with_result_confirm_local`, `total_rows_postprocess_local` | large |
| Candidate execution validation plan refresh | Track A | Yes | low | `lineage/ads_sc_xl_13/`, `audit/`, `handoff/` | none | explicit execution order and acceptance criteria for already-written SQL | medium |
| Full `complete combined_local` implementation | Track A | No | high | `sql/rebuild/`, `lineage/`, `audit/`, `handoff/` | P1 gates still open | none; should not start yet | large |

## Track B can continue

| Task name | Track | Can run now? | Conflict risk | Allowed write path | Blocked by | Expected output | Recommended package size |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Review/sign-off on PR `#14` / PR `#17` path | Track B | Yes | low | `openclaw-v2-infra` only | coordinator approval path | reviewed connector-readiness package | medium |
| Connector/tool registration prep | Track B | Yes | low | `openclaw-v2-infra` only | connector registration still absent | runbook/registration readiness follow-up | medium |
| Direct-call verification from current ChatGPT tool space | Track B | No | medium | `openclaw-v2-infra` only | missing registered connector/tool path and local validation | none yet | medium |

## Track C can continue

| Task name | Track | Can run now? | Conflict risk | Allowed write path | Blocked by | Expected output | Recommended package size |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Governance refresh after new execution receipts | Track C | Yes, but only after new evidence lands | low | `governance/`, `clarifications/`, `reviews/`, `decision_log/` | depends on newer executed evidence | refreshed readiness gate and issue matrix | medium |
| Clarification queue maintenance | Track C | Yes | low | `clarifications/`, `governance/` | none | exact unresolved questions preserved without guessing | small |

## Track D can continue

| Task name | Track | Can run now? | Conflict risk | Allowed write path | Blocked by | Expected output | Recommended package size |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Static dashboard build | Track D | Yes | low | `docs/progress_dashboard/` | issue `#11` has not been switched to `track-d-running` yet | `index.html`, `progress_snapshot.json`, `README.md`, timer file | large |
| Snapshot-only status page | Track D | Yes | low | `docs/progress_dashboard/` | same as above | minimal visibility package if full UI is deferred | medium |

## Track E can continue

| Task name | Track | Can run now? | Conflict risk | Allowed write path | Blocked by | Expected output | Recommended package size |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Periodic repository-wide refresh | Track E | Yes | low | `discovery/warehouse_rebuild_global/`, `assessments/warehouse_rebuild_global/`, `roadmap/warehouse_rebuild_global/` | none | updated inventory, blocker map, route plan | medium |
| Cross-track delta monitoring | Track E | Yes | low | same as above | none | refreshed issue matrix against live GitHub state | small |

## Temporarily cannot continue

| Task name | Track | Can run now? | Conflict risk | Allowed write path | Blocked by | Expected output | Recommended package size |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Mark `complete combined_local` as ready | Cross-track | No | high | N/A | P1 gates open | none | large |
| Declare non-`ADS_SC_XL_13` warehouse domains closed/open | Cross-track | No | low | N/A | domains not registered in repo | none | small |
| Treat `partial/pending_execution` as closed | Cross-track | No | high | N/A | governance rule and evidence gap | none | small |

## Needs business clarification

| Task name | Track | Can run now? | Conflict risk | Allowed write path | Blocked by | Expected output | Recommended package size |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `with_result_confirm` override semantics clarification | Track C / Coordinator | Yes | low | `clarifications/`, `governance/` | business owner response | answered clarification rows | small |
| warehouse/doc-type `attribute*` slot mapping clarification | Track C / Coordinator | Yes | low | `clarifications/`, `governance/` | business owner response | scene-local slot mapping answers | medium |
| `合计/总计` generation-order clarification | Track C / Coordinator | Yes | low | `clarifications/`, `governance/` | business owner response | summary-row rule answers | small |

## Needs real execution environment

| Task name | Track | Can run now? | Conflict risk | Allowed write path | Blocked by | Expected output | Recommended package size |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Run `inspect_dim_date_info.sql` / `recon_dim_date_zero_fill.sql` | Track A | No in current repo-only context | medium | `audit/`, `lineage/`, `handoff/` | read-only execution environment missing here | executed zero-fill evidence | medium |
| Run `inspect_ads_sc_xl_01_local.sql` / `recon_ads_sc_xl_01_local_join.sql` | Track A | No in current repo-only context | medium | `audit/`, `lineage/`, `handoff/` | read-only execution environment missing here | executed inbound-join evidence | medium |
| Run `inspect_with_result_confirm_local.sql` / `recon_with_result_confirm_local.sql` | Track A | No in current repo-only context | medium | `audit/`, `lineage/`, `handoff/` | read-only execution environment missing here | executed confirm-layer evidence | medium |
| Run `inspect_total_rows_postprocess.sql` / `recon_total_rows_postprocess.sql` | Track A | No in current repo-only context | medium | `audit/`, `lineage/`, `handoff/` | read-only execution environment missing here | executed summary-row evidence | medium |

## Needs Hermes connector

| Task name | Track | Can run now? | Conflict risk | Allowed write path | Blocked by | Expected output | Recommended package size |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Direct ChatGPT Coordinator call into Hermes | Track B | No | medium | `openclaw-v2-infra` only | connector/tool registration absent | verified direct-call path | medium |
| Tool-path `/health` and `/capabilities` validation from ChatGPT | Track B | No | low | `openclaw-v2-infra` only | connector/tool registration + local validation absent | verified local dry-run endpoint access | small |

## Pool-level conclusion

1. Parallel work is available right now.
2. What is not available right now is only the final closure path.
3. The highest-value next warehouse package is not another discovery package; it is an execution-validation package against the already-written SQL.
