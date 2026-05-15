# Global Blocker Diagnosis

## Executive answer

- Is the warehouse rebuild actually blocked:
  - `partially`
- Reason:
  - the repository is not blocked for discovery, planning, governance, or candidate-level design
  - it is blocked for `complete combined_local` because multiple P1 support chains remain `partial + pending_execution`, and some still require business clarification

## Why it feels stuck

1. The repository has many stage packages, but most of them intentionally stop at `pending_execution` instead of executed validation.
2. The core unknown is no longer the main chain; the real problem is support-chain closure:
   - `with_attr_value`
   - `ads_sc_xl_01_local`
   - `with_result_confirm_local`
   - `total_rows_postprocess_local`
3. The repo only registers one active warehouse domain, so progress can feel repetitive even when new evidence is being added.
4. Repo governance documents were accurate when written, but some are now stale relative to newer live issue receipts, which creates a “still running” impression after the facts have moved on.
5. Direct ChatGPT-to-Hermes execution is still blocked by connector registration and local validation, which slows any future plan that assumes automated execution from the current tool space.

## Blocker grading

### P0: blocks all routes

- None currently open inside `warehouse-rebuild`.
- Explanation:
  - discovery, diagnosis, governance refresh, dashboard work, and candidate planning can still continue.

### P1: blocks `complete combined_local`

1. `with_attr_value` scene-local closure is still `partial + pending_execution`, and some slot meanings remain `needs_business_clarification`.
2. `ads_sc_xl_01_local` is still a join skeleton / candidate join package, not an executed closed support layer.
3. `with_result_confirm_local` is structurally mapped but still unexecuted.
4. `total_rows_postprocess_local` is only a design package and still depends on executed upstream detail plus summary-row business interpretation.
5. `combined_candidate` is ready for blueprint, but blueprint readiness is explicitly not equivalent to complete readiness.

### P2: blocks quality acceptance / automation efficiency

1. Governance/review files in repo still reflect older issue timing for `#9` and do not incorporate live `#12` completion facts.
2. Current ChatGPT tool space still cannot call Hermes directly because connector/tool registration and `pwsh` local validation are not completed.
3. Generic sync commits make cross-track archaeology slower than necessary.

### P3: documentation / visibility improvement

1. `docs/progress_dashboard/` is still `not_found` even though Track D issue `#11` exists.
2. The repo has no second warehouse-domain registration, so Track E must repeatedly state that non-`ADS_SC_XL_13` domains are `not_found / not_yet_registered`.

## Real blockers vs fake blockers

## Real blockers

| Item | Why it is real | Grade |
| --- | --- | --- |
| `with_attr_value` unfinished closure | controls mapping semantics used by main report layers and inbound support logic | `P1` |
| `ads_sc_xl_01_local` still blueprint-only | blocks inbound quantity fields from becoming acceptance-grade evidence | `P1` |
| `with_result_confirm_local` unexecuted | blocks downtime/remark fields from becoming acceptance-grade evidence | `P1` |
| `total_rows_postprocess_local` unexecuted | blocks `合计/总计` rows and terminal display completeness | `P1` |

## Not real blockers / can run in parallel

| Item | Why it is not a full blocker |
| --- | --- |
| Track E global discovery | only needs repo + live issue facts; does not require DB execution |
| Track C governance refresh | can be done after new receipts without touching SQL |
| Track D dashboard | can start even while support chains remain pending |
| Track B review / connector-readiness docs | useful for future execution, but not required to inspect repo assets |
| candidate-level planning | explicitly allowed while complete readiness remains blocked |

## Which blockers are just `pending_execution`

1. `dim_date_info_local`
2. `process1 -> defined` zero-fill validation
3. `defined -> defined_manuf_line_name` aggregation validation
4. `with_attr_value` scene-family validation SQL
5. `ads_sc_xl_01_local` candidate join validation
6. `with_result_confirm_local` validation
7. `total_rows_postprocess_local` validation
8. `combined_candidate` execution validation
9. Hermes `pwsh` contract tests and local validation

These items are important, but they are not all “unknown blockers.” Most are already structurally mapped and simply lack read-only execution evidence.

## Which blockers require business clarification

1. For `with_result_confirm` `report_id 237 / 239 / 543`, which fields are authoritative overrides?
2. For warehouse/doc-type scene families, which `attribute*` slot maps to which business field under each scene or tenant?
3. For `attr1='合计'` and `manuf_line_name='总计'`, at which layer are rows generated, and how do zero-fill rows participate?
4. Whether `group_manuf_line_name` is only a label or a higher-level grouping dimension that must survive candidate assembly.

## Which tasks can run in parallel now

1. Track D dashboard build from existing issue/PR facts.
2. Track C governance refresh after Track E or later execution receipts.
3. Track B review/sign-off and connector registration preparation.
4. Track A execution-plan packaging for existing inspect/recon SQL.
5. Track E ongoing repository-wide inventory/diagnosis updates.

## Which tasks must wait for real SQL execution

1. Closing `dim_date_info_local` from blueprint to executed evidence.
2. Closing `with_attr_value` scene validation from `partial` to `executed`.
3. Closing `ads_sc_xl_01_local`, `with_result_confirm_local`, and `total_rows_postprocess_local`.
4. Any claim that `combined_candidate` is acceptance-grade.
5. Any opening of `complete combined_local`.

## Which tasks require Hermes connector readiness

1. Direct Coordinator-to-Hermes calls from the current ChatGPT tool space.
2. Future automated local `/health` / `/capabilities` / dry-run task validation from a registered tool path.
3. Any plan that assumes ChatGPT can trigger a local Hermes validation flow without a separate manual environment.

What does **not** require Hermes connector readiness:

- repo discovery
- markdown diagnosis
- issue matrix synthesis
- dashboard design
- governance refresh

## Governance and automation friction

1. `docs/09_execution_wip_policy.md` says only one issue may be actively executed at a time, but the repo now also uses Track C, D, and E label families. This is workable, but the policy wording is behind the actual multi-track operating model.
2. Track D has a watcher comment and expected timer path, but no dashboard files yet. Visibility is lagging the issue system.
3. Track C repo docs were completed before newer live receipts landed, so repo-state visibility is slightly behind GitHub-state reality.

## Diagnosis by core question

1. Did Track E inspect the whole repository?
   - Yes.
2. How many table/report/domain assets were detected?
   - `36` logical table/report/domain assets in repo evidence.
3. Was `ADS_SC_XL_13` the only detected active domain?
   - Yes.
4. What non-`ADS_SC_XL_13` domains were detected?
   - `not_found`.
5. Is the warehouse rebuild actually blocked?
   - Partially.
6. Where exactly is it blocked?
   - At support-chain execution closure and complete-readiness gates, not at repo discovery.
7. Which blockers are real blockers?
   - `with_attr_value`, `ads_sc_xl_01_local`, `with_result_confirm_local`, `total_rows_postprocess_local`.
8. Which blockers are just `pending_execution`?
   - Most mapped chains from `dim_date_info_local` through `combined_candidate`.
9. Which blockers require business clarification?
   - slot semantics, `with_result_confirm` override meaning, summary-row generation rules.
10. Which tasks can run in parallel now?
   - Track D dashboard, Track B review/connector prep, Track C refresh, Track A execution planning, Track E maintenance.
11. Which tasks must wait for real SQL execution?
   - any attempt to close P1 chains or open `complete combined_local`.
12. Which tasks require Hermes connector readiness?
   - direct ChatGPT-to-Hermes automation only.

## Final diagnosis

The warehouse rebuild is not “globally stuck.” It is structurally mapped but execution-light. The real bottleneck is that the repo has already converted most uncertainty into explicit blueprints, yet it still lacks enough executed read-only evidence to move P1 support chains from `partial/pending_execution` into closure. That is a narrower and more actionable problem than “the warehouse is unknown.”
