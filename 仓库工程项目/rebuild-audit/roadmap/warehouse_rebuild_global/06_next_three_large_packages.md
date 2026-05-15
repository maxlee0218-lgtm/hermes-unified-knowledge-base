# Next Three Large Packages

## Package 1: Support-Chain Execution Validation Bundle

- Goal:
  - turn the existing P1 support-chain blueprints into executed read-only evidence
- Input basis:
  - issue receipts `#2`, `#3`, `#6`, `#7`, `#8`, `#9`, `#12`
  - existing inspect/recon SQL already archived in repo
- Output files:
  - new `audit/ads_sc_xl_13/runs/<run_id>/...`
  - updated execution-result lineage docs
  - refreshed handoff package
- Do not do:
  - no production writes
  - no full `combined_local`
  - no guessed business semantics
- Dependency conditions:
  - read-only execution environment
  - willingness to leave unresolved semantics as clarification items
- Risks:
  - executed evidence may reveal more scene-local variance than the current blueprints assume
- Acceptance standard:
  - every P1 chain produces either executed evidence or a precise blocked receipt
- Suggested Track:
  - Track A

## Package 2: Candidate Assembly And Postprocess Validation Bundle

- Goal:
  - validate `combined_candidate` inputs and `合计/总计` postprocess behavior after Package 1 evidence exists
- Input basis:
  - `combined_candidate_readiness.md`
  - `combined_candidate_blueprint.md`
  - `total_rows_postprocess_impact.md`
  - `total_rows_postprocess_local_plan.md`
  - executed support-chain evidence from Package 1
- Output files:
  - candidate input validation audit
  - postprocess validation audit
  - refreshed readiness notes
- Do not do:
  - no claim that candidate readiness equals complete readiness
  - no production SQL
  - no closure of unresolved clarification items by inference
- Dependency conditions:
  - Package 1 complete enough to produce real source/baseline observations
- Risks:
  - summary-row logic and manual-confirm overrides may still expose clarification gaps
- Acceptance standard:
  - candidate-level key/metric coverage and postprocess behavior are observed, not just designed
- Suggested Track:
  - Track A, with Track C ready to refresh governance afterward

## Package 3: Complete Combined Local Go/No-Go Gate Bundle

- Goal:
  - make the first evidence-based decision on whether `complete combined_local` may open at all
- Input basis:
  - Packages 1 and 2
  - clarification queue state
  - governance readiness gate state
- Output files:
  - refreshed readiness gate
  - go/no-go decision package
  - next-issue recommendation for either full combined work or continued blocker handling
- Do not do:
  - no silent transition from `partial/pending_execution` to `closed`
  - no opening of full combined work if any P1 gate remains open
- Dependency conditions:
  - all P1 chains must be executed or explicitly answered
- Risks:
  - one unresolved business clarification can still keep the final gate closed
- Acceptance standard:
  - explicit `Yes/No` decision with evidence for each hard gate
- Suggested Track:
  - Track C for the gate package; Track A only if the gate returns `Yes`

## Why these three packages

1. The repo already has enough blueprint material; more blueprint-only work has diminishing returns.
2. The next bottleneck is execution evidence, not structural discovery.
3. Full `combined_local` should only be opened after support-chain evidence and summary-row behavior are both observed.
