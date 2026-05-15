# ADS_SC_XL_13 Decision Log

## D-001

- Date: `2026-04-26`
- Decision: do not advance full `combined_local`
- Reason:
  - `with_attr_value` gates remain `partial`
  - `ads_sc_xl_01_local` remains `partial`
  - `with_result_confirm_local` is still `in_progress`
  - `合计/总计` postprocess is still `in_progress`
- Evidence:
  - issue `#6`
  - issue `#7`
  - issue `#8`
  - issue `#9`
  - `lineage/ads_sc_xl_13/05_missing_links.md`
- Impact: `complete combined_local execution readiness` stays `blocked`

## D-002

- Date: `2026-04-26`
- Decision: `with_attr_value` must not be treated as a fact chain
- Reason:
  - coordinator / domain-owner clarification explicitly defines it as configuration and mapping
  - repository evidence shows multi-scene semantic usage rather than a single upstream production chain
- Evidence:
  - issue `#6` owner clarification
  - `lineage/ads_sc_xl_13/02_supporting_chains.md`
  - `lineage/ads_sc_xl_13/supporting/with_attr_value_scene_matrix.md`
- Impact: readiness documents may reference scene coverage and mapping risk, but may not claim fact lineage closure

## D-003

- Date: `2026-04-26`
- Decision: `attr*` must not be fixed across scenes
- Reason:
  - domain-owner clarification says `attr*` fields are generic dimension slots
  - meaning must be derived from usage scene and join/match field
- Evidence:
  - issue `#6` owner clarification
  - issue `#10` confirmed semantics section
- Impact: any unresolved slot semantics go into the clarification queue instead of governance conclusions

## D-004

- Date: `2026-04-26`
- Decision: issue `#9` is allowed to function as a stage package, but only at its own receipt boundary
- Reason:
  - its scope is explicitly limited to `with_result_confirm_local`, `combined_candidate readiness`, and `合计/总计` postprocess
  - this lets Track A reduce blocking surface before full `combined_local`
  - its result is still unavailable while the issue is `codex-running`
- Evidence:
  - issue `#9` title and current label state
  - `lineage/ads_sc_xl_13/06_next_rebuild_order.md`
- Impact: governance records `#9` as `in_progress` and waits for its receipt before changing the dependent gates

## D-005

- Date: `2026-04-26`
- Decision: Track C must not modify SQL or lineage main-body files
- Reason:
  - Track C exists to avoid file-family collision with Track A
  - SQL and lineage-main edits would violate the issue boundary and weaken acceptance independence
- Evidence:
  - issue `#10` strict boundaries
  - `docs/08_automation_registry.md`
  - `docs/09_execution_wip_policy.md`
- Impact: Track C writes only governance, review, clarification, and decision-log artifacts

## D-006

- Date: `2026-04-26`
- Decision: governance work is limited to acceptance and clarification
- Reason:
  - the stated Track C purpose is to collect evidence, blockers, and decisions so later closure is fast
  - pushing execution logic from Track C would duplicate or collide with Track A
- Evidence:
  - issue `#10` Track C definition
  - `docs/10_executor_no_midpoint_prompt_policy.md`
- Impact: Track C may recommend a next node, but may not generate production SQL or execute warehouse rebuild steps

## D-007

- Date: `2026-04-26`
- Decision: `combined_candidate_blueprint` may be discussed only under conservative prerequisites
- Reason:
  - date spine and zero-fill blueprints exist
  - `defined_manuf_line_name` validation package exists
  - `with_attr_value` and `ads_sc_xl_01_local` have only partial closure
  - therefore candidate discussion is allowed, but not candidate acceptance as full closure
- Evidence:
  - issue `#2`
  - issue `#3`
  - issue `#6`
  - issue `#7`
  - issue `#8`
  - `lineage/ads_sc_xl_13/defined_manuf_line_name_execution_result.md`
- Impact: `combined_candidate` remains a gated assessment node, not a full execution approval

## D-008

- Date: `2026-04-26`
- Decision: full `combined_local` needs both gate closure and clarification closure
- Conditions:
  1. all P1 readiness gates are `closed/executed`
  2. issue `#9` has a completion receipt
  3. no blocking clarification remains open for `with_result_confirm`, warehouse/doc-type slot semantics, or `合计/总计` postprocess semantics
  4. support-chain artifacts are accepted as more than blueprint-only evidence
- Evidence:
  - issue `#10` readiness rule
  - `governance/ads_sc_xl_13/combined_local_readiness_gate.md`
- Impact: until these conditions are met, Track C keeps `complete combined_local execution readiness` at `blocked`
