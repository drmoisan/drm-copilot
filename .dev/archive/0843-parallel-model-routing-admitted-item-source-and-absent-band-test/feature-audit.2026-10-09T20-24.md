# Feature Audit: parallel model routing admitted-item source and absent-band test (#843)

**Audit Date:** 2026-10-09
**Feature Folder:** `docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843`
**Base Branch:** `origin/main`
**Head Branch:** `bug/parallel-model-routing-admitted-item-source-and-absent-band-test-843`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review (reduced artifact set)
**Blocking findings:** 0

---

## Scope and Baseline

- **Base branch:** `origin/main` (`git diff origin/main...HEAD`)
- **Head commit:** `755537bc3d9cfa5a4efcb085a9bc4ed0afc529b1`
- **Evidence sources:**
  - Feature evidence: `docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/evidence/**` (paths below are relative to that `evidence/` folder)
  - Additional evidence: direct `git diff` inspection and `cmp` re-run of the three source/mirror pairs
- **Feature folder used:** `docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843`
- **Requirements source:** `issue.md` (`## Acceptance Criteria`, AC-1 to AC-8)
- **Work mode resolution note:** `minor-audit`; `spec.md` and `user-story.md` are not used.
- **Operator decision:** Option A (orchestrator-checkpoint `complexity_band` with spawn-time resolution) accepted. The issue Assumptions line "The operator was not consulted on this choice" is superseded by that decision; it is a stale record, not a defect.
- **Scope note:** Full branch diff against `origin/main`; no scope narrowing.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/issue.md` - only source

### Acceptance criteria

1. AC-1: `parallel-orchestrate/SKILL.md` names the orchestrator checkpoint as the band source for `/parallel-add` items, with resolution and failure behavior, in the band/receipt source text and in `## Model Selection`.
2. AC-2: `parallel-orchestrator.md` `## Delegation Model` states the same rule.
3. AC-3: `parallel-add/SKILL.md` step 2 records `complexity_band` and no `model_routing_receipt`, without adding an `items[]` field.
4. AC-4: Source and bundled mirror files are byte-identical and bundle parity holds.
5. AC-5: Contract tests assert the new text on all three surfaces.
6. AC-6: Both routing validator test files pin a band-only deletion with exact ordered equality.
7. AC-7: Both routing validator test files pin a receipt-band-only deletion by inclusion.
8. AC-8: The AC-8 pytest suite, the full Jest suite with coverage, and the permission-contract test pass with coverage at or above floors and no regression.

(The AC wording above is summarized from the `issue.md` items; the verbatim text lives in `issue.md`.)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 orchestrate skill admitted-item band source | PASS | Diff of `.claude/skills/parallel-orchestrate/SKILL.md` adds an identical paragraph after the `**Band and receipt source.**` text and after the `## Model Selection` band/receipt text. It names the orchestrator checkpoint path, `/parallel-add`, no `model_routing_receipt`, `complexity_to_model` in `config/orchestration-routing.json`, the `fable` clamp to `opus` under `fable_policy: disabled`, the `Resolve-DelegationModel` equivalence with the `preferred_overlay.agents` reason, explicit `model` on the spawn, and stop-when-absent. | `git diff origin/main...HEAD -- .claude/skills/parallel-orchestrate/SKILL.md` | Existing text retained, no heading added (additions-only diff), no backticked lowercase-led command (permission test PASSED) |
| 2 | AC-2 orchestrator agent delegation rule | PASS | Diff of `.claude/agents/parallel-orchestrator.md` `## Delegation Model` `model` bullet adds the same rule (band source, no receipt, `complexity_to_model` resolution with clamp, explicit `model`, stop-when-absent). | `git diff origin/main...HEAD -- .claude/agents/parallel-orchestrator.md` | Existing text retained; no heading |
| 3 | AC-3 parallel-add step 2 | PASS | `.claude/skills/parallel-add/SKILL.md` diff is two lines inside step 2 only: "records `complexity_band` and no `model_routing_receipt`; the parent resolves ... per `parallel-orchestrate` `## Model Selection`." | `git diff origin/main...HEAD -- .claude/skills/parallel-add/SKILL.md` | No `items[]` field added; `## Constraints` not in the diff |
| 4 | AC-4 mirror parity | PASS | `cmp` re-run in this audit: all three source/mirror pairs identical. `qa-gates/final-mirror-parity.2026-10-09T20-20.md` EXIT_CODE 0. `qa-gates/final-pytest-related.2026-10-09T20-20.md`: 97 passed, bundle-parity node PASSED (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`). | `cmp` on each source/mirror pair (run by reviewer) | |
| 5 | AC-5 contract tests for new text | PASS | `test_parallel_complexity_routing_contracts.py` adds four tests asserting the tokens `artifacts/orchestration/parallel-orchestrator-state.json`, `/parallel-add`, `complexity_to_model` (plus extras) in the kickoff paragraph, `## Model Selection`, and agent `## Delegation Model`, and `parallel-orchestrate` / `## Model Selection` (plus `model_routing_receipt`) in `parallel-add` step 2. Passing run in `regression-testing/contract-pass-after.2026-10-09T20-22.md`; fail-before 4 failed / 7 passed in `regression-testing/contract-fail-before.2026-10-09T20-18.md`. | `pytest tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py` (recorded) | Diff is additions-only, so existing assertions are unmodified and pass |
| 6 | AC-6 band-only deletion pinned | PASS | Both test files add a case that builds the valid routing fields, deletes only `complexity_band`, and asserts exact ordered equality with `[BAND_ABSENT, ASSESSMENT_BAND_VS_ABSENT, RECEIPT_BAND_VS_ABSENT]`. Literals match the AC text and are identical module constants in both files. Python: 31 passed (29 + 2); Jest routing file: 24 passed (22 + 2) with both titles shown (`qa-gates/final-jest-routing-file.2026-10-09T20-20.md`). | Python routing suite and Jest routing file (recorded) | A genuine fail-before run is impossible because no production code changed; `regression-testing/fail-before-exception.2026-10-09T20-17.md` documents this with alternative proof |
| 7 | AC-7 receipt-band-only deletion pinned | PASS | Both files add a case that deletes only the receipt's `complexity_band` and asserts inclusion of `RECEIPT_BAND_ABSENT_ENUM` and `RECEIPT_BAND_ABSENT_VS_ITEM`; literals match the AC and are identical in both files. Same pass counts as AC-6. | Python routing suite and Jest routing file (recorded) | Inclusion assertion follows the issue's stated assumption (CR-3) |
| 8 | AC-8 suites, coverage, permission contract | PASS | AC-8 pytest suite: 109 passed (103 + 6), no failing nodes. Jest full suite with the prescribed flags: 256 suites, 3919 tests passed (baseline 3917 + 2), no threshold message. Python `_parallel_planner_state_routing.py`: line 100.0 / branch 100.0 (baseline 100.0 / 100.0; 50 stmts, 16 branches, none missed). TS `parallel-planner-state-routing.ts`: line 100 / branch 100 (27/27) from `coverage-summary.json` (baseline 100 / 92.59). Floors 85/75 met, no regression (`qa-gates/coverage-comparison.2026-10-09T20-22.md`, `Verdict: PASS`). Permission-contract test PASSED. | AC-8 commands as recorded in `qa-gates/final-pytest-ac8-suite.2026-10-09T20-20.md` and `qa-gates/final-jest-coverage.2026-10-09T20-20.md` | |

### Behavior vs Baseline

- Gap 1 (admitted-item band source): before, `parallel-orchestrate` named only the planner checkpoint and kickoff `## Item Summary`; after, both sections and the agent bullet name the orchestrator checkpoint as the source for `/parallel-add` items, with resolution and failure behavior stated. Verified by text diff and contract tests.
- Gap 2 (absent-band test): before, the absent-band test deleted all three routing fields together; after, a band-only deletion is pinned in both runtimes, raising TS branch coverage from 25/27 to 27/27.

### Scope and Residual Items

- Scope boundary verified: no change under `scripts/`, `extensions/drm-copilot/src/`, `config/`, `.github/` (`qa-gates/scope-boundary.2026-10-09T20-22.md` and the diff stat).
- Non-blocking N-3: the live integration scenario (admit an item in a running parallel run and observe the spawn `model`) is not an acceptance criterion per the issue Assumptions and remains manual. It is not verified by execution; no automated harness exists.
- Non-blocking N-4: `issue.md` Assumptions still states the operator was not consulted on Option A; the operator has since accepted Option A. Documentation-only staleness; no change made by this audit (reviewers do not edit issue text).
- Non-blocking N-1/N-2: timestamp labels on four Phase 1 artifacts (each disclosed by `TimestampNote:`) and the supplementary `--reporters=default` Jest run (disclosed, planned command retained) are judged acceptable.
- Non-blocking N-5: the equivalence claim with `Resolve-DelegationModel` and the `preferred_overlay.agents` exclusion of `orchestrator` rest on research reading, not on a test that executes the resolver for an admitted item.

---

## Summary

**Overall Feature Readiness:** PASS. All eight acceptance criteria are satisfied; no remediation inputs file is produced.

**Criteria summary:**
- **PASS:** 8 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing full PASS:** None. Non-blocking observations N-1 through N-5 are recorded above.

**Recommended follow-up verification steps:**

1. Optionally update the `issue.md` Assumptions line to record the Option A acceptance (N-4).
2. Optionally perform the manual live-spawn check described in N-3 after merge.

Blocking findings: 0.

---

## Acceptance Criteria Check-off

- All eight AC items in `issue.md` are already `[x]`; the evidence inspected supports each, so no change was needed.
- Newly checked off by this review: none (all PASS items were already checked).
- No source-file edit was made by this review.

### AC Status Summary

- Source: `docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/issue.md`
- Total AC items: 8
- Checked off (delivered): 8
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `issue.md` | 8 | 8 | 0 | Checkbox-backed |
