# ADS_SC_XL_13 Track C Governance Overview

## Scope

- Date: `2026-04-26`
- Track C issue: `warehouse-rebuild#10`
- Scope boundary:
  - governance
  - acceptance
  - clarification
  - decision log
  - readiness gate

## Track C goal

Track C does not rebuild SQL and does not advance full `combined_local`.

Track C exists to:

1. consolidate A-line execution receipts
2. consolidate B-line readiness facts that affect coordination wording
3. maintain the business clarification queue
4. maintain the `combined_local` readiness gate
5. provide acceptance and decision records so later closure does not depend on re-reading every issue

## Track split

| Track | Owner scope | Current repository | Allowed outcome |
| --- | --- | --- | --- |
| Track A | ADS_SC_XL_13 warehouse rebuild, inspect/recon SQL, audit artifacts | `maxlee0218-lgtm/warehouse-rebuild` | stage artifacts, local blueprint, acceptance evidence |
| Track B | Hermes Gateway / readonly-tools / coordinator-call contract | `maxlee0218-lgtm/openclaw-v2-infra` | dry-run contract, local stub shape, connector readiness notes |
| Track C | governance / clarification / acceptance / decision log | `maxlee0218-lgtm/warehouse-rebuild` | governance package only, no production SQL |

## Current A-line issue overview

| Issue | Status | Commit / evidence | Current conclusion |
| --- | --- | --- | --- |
| `#1` | `codex-done` | `dc3384587d739db0a568f2a51740babf343beddf` | `dim_date_info` can be rebuilt; `with_attr_value` can only be rebuilt by scene segments; full `combined_local` still forbidden |
| `#2` | `codex-done` | `133836179ab5b8ccdeb5d96590007eb85c7ef8f2` | `dim_date_info_local` reached `pending_execution`; `defined` zero-fill blueprint can proceed |
| `#3` | `codex-done` | `be53f11321f9565596bddad214f2dbff69afd32b` | `process1 -> defined` zero-fill validation blueprint exists; can proceed to `defined_manuf_line_name` |
| `#6` | `codex-done` | `d9a272fde2a61736309df9095dd2e36cf292f2f3` | `with_attr_value` is config/mapping, not fact chain; `attr1` must be treated as scene-local dimension slot |
| `#7` | `codex-done` | `9374438c73dca4f678c31939375913f914e633fc` | warehouse/doc-type scene family is anchored, but slot semantics remain `partial + pending_execution` |
| `#8` | `codex-done` | `84f62aa0e9e2ab5aa26eb10de9035e0c2cc39fe1`, `99aca9922d0e74ab5d739eb765377a6749e6e58c` | `ads_sc_xl_01_local` join skeleton exists, but remains `partial + pending_execution` |
| `#9` | `codex-running` | owner comment only: `Codex automation started.` | record as `in_progress`; do not infer result |

## Current B-line issue / PR overview

| Object | Status | Current conclusion |
| --- | --- | --- |
| `openclaw-v2-infra#13` | `closed`, `codex-done`, `review-needed` | Hermes Command Gateway `v0.2/v0.3` dry-run package completed at receipt level; direct call from current ChatGPT tool space is still not ready without tool/connector registration |
| `openclaw-v2-infra#14` | `open PR` | review of local stub / contract package pending |
| `openclaw-v2-infra#12` | `open PR` | older gateway PR still open; B-line already moved ahead by issue-based stage package |

Track C impact:

- B-line is not a blocker for warehouse SQL lineage work.
- B-line only affects wording around future coordinator-call readiness.
- Current accepted wording remains: `future Shrimp role + future Hermes execution seat interface`.

## ADS_SC_XL_13 readiness summary

| Node | Current status | Evidence source |
| --- | --- | --- |
| `dim_date_info_local` | `pending_execution` | issue `#2` receipt |
| `process1 -> defined` zero-fill | `pending_execution` | issue `#3` receipt |
| `defined -> defined_manuf_line_name` | `pending_execution` | `lineage/ads_sc_xl_13/defined_manuf_line_name_execution_result.md` |
| `with_attr_value attr1/manuf_line_name` | `partial + pending_execution` | issue `#6` receipt |
| `with_attr_value warehouse/doc_type` | `partial + pending_execution` | issue `#7` receipt |
| `ads_sc_xl_01_local` | `partial + pending_execution` | issue `#8` receipt |
| `with_result_confirm_local` | `in_progress` | issue `#9` label/comment state |
| `combined_candidate readiness` | `in_progress` | issue `#9` title/scope |
| `complete combined_local` | `blocked` | multiple P1 gates still open |

## Current largest blockers

1. `with_result_confirm_local` has no completed receipt yet because issue `#9` is still running.
2. `with_attr_value` remains scene-driven and only partially closed; unresolved items must stay in clarification queue instead of being generalized.
3. `ads_sc_xl_01_local` is still only a join skeleton / candidate join package, not an executed closed chain.
4. `attr1='合计'` and `manuf_line_name='总计'` postprocess logic is still not closed.

## Current disallowed actions

- do not modify `lineage/ads_sc_xl_13` main chain files as part of Track C
- do not modify `sql/`
- do not modify `audit/` outputs created by Track A
- do not modify handoff packages
- do not modify `openclaw-v2-infra`
- do not generate production SQL
- do not advance full `combined_local`
- do not infer unclear business semantics

## Current allowed actions

- summarize issue receipts and evidence
- maintain governance and readiness documents
- record unanswered business questions
- mark `combined_local` gates conservatively
- recommend next action without creating new execution logic

## Next decision basis

Use the following rules for the next coordination decision:

1. wait for issue `#9` completion receipt before changing any `with_result_confirm_local`, `combined_candidate`, or `total_rows_postprocess` gate from `in_progress`
2. treat `with_attr_value` as mapping/config evidence only, not as a fact-chain substitute
3. if any scene-local semantic remains unclear, carry it into the clarification queue rather than resolving it in governance text
4. keep `complete combined_local` blocked until all P1 gates are `closed/executed`
