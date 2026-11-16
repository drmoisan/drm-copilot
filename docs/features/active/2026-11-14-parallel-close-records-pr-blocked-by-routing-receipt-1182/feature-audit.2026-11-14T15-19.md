# Feature Audit: Parallel Run Closing records PR blocked by the routing receipt (#1182)

---

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt-1182`
**Base Branch:** `main`
**Head Branch:** `bug/parallel-close-records-pr-routing-receipt`
**Work Mode:** `full-bug`
**Audit Type:** Initial review in concurrent mode (PR #1183 open, PR CI running)

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main`; merge base `add7d747886ce893356b63de2941435f2895b345`)
- **Head branch/commit:** `bug/parallel-close-records-pr-routing-receipt` (commit `06cc8b03d215460418d7d5e881e007c1b18c8d0d`)
- **Merge base:** `add7d747886ce893356b63de2941435f2895b345`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-14 15:14:12 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and the direct `git diff origin/main...HEAD`
  - Feature evidence: `docs/features/active/2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt-1182/evidence/**`
  - Reviewer evidence: direct parse of `artifacts/pester/powershell-coverage.xml` and `artifacts/python/lcov.info`, `cmp` mirror checks, the evidence-location scan, and `gh pr checks 1183`, all recorded in the policy audit
- **Feature folder used:** `docs/features/active/2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt-1182`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** full branch diff from the merge base to the head (70 files). The commits after `f009036fa` add evidence only, so the final gates describe the reviewed code. The reviewer ran no test suite (caller standing rule).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt-1182/spec.md` — 25 checkbox items under `## Acceptance Criteria` (AC-1 to AC-25)

### Acceptance criteria

The criteria are the checkbox items AC-1 to AC-25 under `## Acceptance Criteria` in `spec.md`. The Impact / Severity checkboxes in `## Context` are not acceptance criteria.

---

## Acceptance Criteria Evaluation

"Final gate" is `evidence/qa-gates/final-qc-pester.2026-11-14T14-36.md` (one `Invoke-PoshQCParallelTest` run, 25398 tests, 0 failures); "pytest gate" is `evidence/qa-gates/final-qc-pytest.2026-11-14T14-38.md`.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-1 | Model-routing allow for pr-author on a closed parallel run with a valid receipt | PASS | Row "AC-1 allows Agent(pr-author)..." in `enforce-model-routing-receipt.ParallelRecords.Tests.ps1`; code P1 to P3 match each listed condition | final gate; diff inspection | Fail-before shows the generic deny on the unfixed hook |
| AC-2 | `PARALLEL_RECORDS_SLUG_MISMATCH` for slug and route_id, one row per field | PASS | AC-2 `-ForEach` rows; base-text prefix asserted | final gate | |
| AC-3 | `PARALLEL_RECORDS_RUN_NOT_CLOSED` for pr_open, ci_green, absent status, empty list; withdrawn not_started allowed | PASS | AC-3 rows including the withdrawn-item allow row | final gate | |
| AC-4 | `PARALLEL_RECORDS_RECEIPT_MISSING` for absent key and no pr-author entry | PASS | AC-4 rows assert the remedy text | final gate | |
| AC-5 | `PARALLEL_RECORDS_RECEIPT_INVALID` for wrong model, out-of-range band, not a list; first validator error carried | PASS | AC-5 rows | final gate | |
| AC-6 | `PARALLEL_RECORDS_CHECKPOINT_UNREADABLE` for null, blank, invalid JSON, JSON array | PASS | AC-6 rows; `-NoEnumerate` plus object check in the helper | final gate | |
| AC-7 | Unchanged behavior (a) to (h) with exact texts | PASS | AC-7 rows use `Should -BeExactly` and zero parallel-seam calls; (h) docs suffix placed last | final gate | Additional `--head` disagreement row |
| AC-8 | Never-throw row for the model-routing leg | PASS | AC-8 row: leg `Allowed` false, empty suffix, gate text exact | final gate | |
| AC-9 | Preimplementation allow for the receipt Write, relative and absolute | PASS | Two AC-9 rows | final gate | Fail-before shows `PREIMPLEMENTATION_GATE_BLOCKED` on the unfixed gate |
| AC-10 | One deny row per sub-code with the suffix after cleanup, bookkeeping, and docs suffixes | PASS | AC-10 `-ForEach` rows assert the exact prefix including empty earlier suffixes | final gate | |
| AC-11 | Unchanged behavior (a) to (g) | PASS | AC-11 rows with `Should -BeExactly` and zero parallel-seam calls; (g) body Write allowed without reaching the leg | final gate | Extra rows for an absolute non-receipt path and an unlisted root |
| AC-12 | Never-throw rows for the preimplementation leg | PASS | Three seam rows (HEAD branch, checkpoint text, listing) plus null input and empty path | final gate; code reading of `Resolve-OrchestrationGateTarget` | Executor deviation in [P2-T4] adjudicated in code review CR-1: the listing-throw row asserts deny with no parallel suffix because the gate's target resolution denies with its NoTarget code before the deny tail, which is today's behavior; intent met, non-blocking |
| AC-13 | Shared helper functions, every sub-code row, slug table, AST rows, purity | PASS | `hook-parallel-records-context.Tests.ps1` rows; AST rows for both sibling files; helper has no file, process, or clock call | final gate; diff inspection | |
| AC-14 | Line limits, four structural suites pass, no literal, header disclosure | PASS | 425 and 491 logical lines; new files 203, 93, 130; suites passed in the final gate; grep finds no `orchestrator-state.json` in the new files; headers carry the disclosure | final gate; reviewer line count and grep | |
| AC-15 | End-to-end four-gate allow chain | PASS | `parallel-records-workflow.EndToEnd.Tests.ps1` passed | final gate | |
| AC-16 | Non-goal diff check recorded | PASS | `evidence/qa-gates/non-goal-diff-check.2026-11-14T14-39.md`; reviewer re-ran `git diff --name-only origin/main...HEAD` at the head: no excluded path, only `.py` file under `tests/` | `git diff --name-only origin/main...HEAD` | |
| AC-17 | Validator fixture with both keys validates plain and complete | PASS | Appended test passed in the pytest gate; no Python production file changed | pytest gate | |
| AC-18 | Fail-before evidence, written once | PASS | `evidence/regression-testing/fail-before.2026-11-14T12-42.md`; stamped 12:42Z from the P1 gate run (started 12:18Z) before the first leg task check (P2-T2, 12:44Z); committed once, with the fix commit `5824a69c4`, and touched by no later commit | `git log` | |
| AC-19 | Skill Run Closing substeps 3 and 5 and checkpoint field list | PASS | Skill diff carries every listed instruction; `parallel-orchestrate-run-closing.Tests.ps1` passed | final gate; diff inspection | |
| AC-20 | Agent Run Closing substeps 3 and 5 shortened form | PASS | Agent diff | diff inspection | |
| AC-21 | Rule declares the two optional tolerated keys; enum table unchanged | PASS | New paragraph in `## Scope and Backward Compatibility`; `## Enum Ownership` untouched | diff inspection | |
| AC-22 | Brief bullet in all byte-identical copies; contract test passes | PASS | Six copies equal by `cmp`; contract test passed in the pytest gate | `cmp`; pytest gate | |
| AC-23 | Bundle mirrors, `core.json` entries, four push-down tests pass | PASS | Nine pairs equal by `cmp`; three manifest entries; tests passed in the pytest gate | `cmp`; pytest gate | |
| AC-24 | Line coverage at least 85% for the five hook files, recorded | PASS | Reviewer parse: 100%, 100%, 100%, 96.36%, 96.53%; `evidence/qa-gates/coverage-comparison.2026-11-14T14-36.md` | XML parse | |
| AC-25 | PowerShell toolchain single loop and CI on the PR head passes | PENDING-CI | Local loop clean (`final-qc-static-powershell.2026-11-14T14-14.md`, final gate); branch dispatch run 43606114877 green on `58ea02d60`; PR #1183 CI on `06cc8b03d` running at 15:27 UTC (shards, Linux hook suites, quality-checks7 3.13 pending) | `gh pr checks 1183` | CI-dependent; owned by the orchestrator at S9; not a blocking finding |

---

## Summary

**Overall Feature Readiness:** READY (pending PR CI for AC-25)

**Criteria summary:**
- **PASS:** 24 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria
- **PENDING-CI:** 1 criterion (AC-25)

**Top gaps preventing PASS:**

None blocking. AC-25 awaits PR CI completion on the head. Two non-blocking Minor findings are recorded in the code review.

**Recommended follow-up verification steps:**

1. Confirm PR #1183 CI on `06cc8b03d` completes green, including `poshqc / PowerShell hook suites (Linux)`, the three `poshqc` shards, and `CI Required Gate`; then check off AC-25 at S9.
2. After merge, perform the spec's `## Post-Merge Verification` for run harness-learnings-2026-11-09.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt-1182/spec.md`
- Total AC items: 25
- Checked off (delivered): 24
- Remaining (unchecked): 1
- Items remaining: AC-25 (PowerShell toolchain single loop and CI on the PR head, including the Linux hook-suite job) — pending PR CI.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 25 | 24 | 1 | AC-1 to AC-24 were already checked and each was re-verified above; AC-25 stays unchecked as pending-CI |

No source-file checkbox change was made by this review.
