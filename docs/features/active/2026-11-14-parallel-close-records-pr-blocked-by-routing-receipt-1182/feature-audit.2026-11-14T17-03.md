# Feature Audit: Parallel Run Closing records PR blocked by the routing receipt (#1182), cycle 1 exit re-audit

---

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt-1182`
**Base Branch:** `main`
**Head Branch:** `bug/parallel-close-records-pr-routing-receipt`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit, remediation cycle 1 exit, concurrent mode (PR #1183 open; PR CI on the head completed green during the review)

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` after `git fetch`; merge base `d7ef763637319b2aa2f886ecdab7a11be0044491`)
- **Head branch/commit:** `bug/parallel-close-records-pr-routing-receipt` (commit `0f18cbd8e132e0a60d766f28632ca2b5f08528fc`)
- **Merge base:** `d7ef763637319b2aa2f886ecdab7a11be0044491`
- **Evidence sources:**
  - Primary: the direct `git diff origin/main...HEAD` (89 files). `artifacts/pr_context.summary.txt` names the earlier head `06cc8b03d`; it was not regenerated because the caller limited writes to the three review artifacts.
  - Secondary: the prior review set `*.2026-11-14T15-19.md`, `remediation-inputs.2026-11-14T15-31.md`, `remediation-plan.2026-11-14T15-31.md`
  - Feature evidence: `docs/features/active/2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt-1182/evidence/**`
  - Reviewer evidence: direct parse of `artifacts/pester/powershell-coverage.xml` and `artifacts/python/lcov.info`, SHA-256 and `cmp` mirror checks, the per-path numstat comparison across the old and new bases, the evidence-location scan, and `gh pr checks 1183`, all recorded in the policy audit
- **Feature folder used:** `docs/features/active/2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt-1182`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** full branch diff from the merge base to the head. No branch production file changed after the cycle 1 final Pester run (16:36Z to 16:50Z); the later commits are evidence, records, and the main merge, which changed none of the branch's own lines. After the coverage Stop hook flagged the executor coverage file as older than the merge commit, the reviewer ran one parallel Pester gate through the test-execution launcher at the head (26522 tests, 0 failures; branch hooks at the same per-file coverage); no other suite was run.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt-1182/spec.md`: 25 checkbox items under `## Acceptance Criteria` (AC-1 to AC-25)

### Acceptance criteria

The criteria are the checkbox items AC-1 to AC-25 under `## Acceptance Criteria` in `spec.md`. The Impact / Severity checkboxes in `## Context` are not acceptance criteria.

---

## Acceptance Criteria Evaluation

"Final gate" is `evidence/qa-gates/final-qc-pester.2026-11-14T16-50.md` (one `Invoke-PoshQCParallelTest` run, 25399 tests, 0 failures); "pytest gate" is `evidence/qa-gates/phase-gate.P2.2026-11-14T16-29.md` (one `pytest -n auto` run, 16824 passed) with `final-qc-pytest.2026-11-14T16-51.md` for the bundle contracts.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-1 | Model-routing allow for pr-author on a closed parallel run with a valid receipt | PASS | AC-1 row; model-routing leg unchanged in cycle 1 | final gate; diff inspection | |
| AC-2 | `PARALLEL_RECORDS_SLUG_MISMATCH` rows | PASS | AC-2 rows | final gate | |
| AC-3 | `PARALLEL_RECORDS_RUN_NOT_CLOSED` rows; withdrawn allowed | PASS | AC-3 rows | final gate | |
| AC-4 | `PARALLEL_RECORDS_RECEIPT_MISSING` rows | PASS | AC-4 rows | final gate | |
| AC-5 | `PARALLEL_RECORDS_RECEIPT_INVALID` rows | PASS | AC-5 rows | final gate | |
| AC-6 | `PARALLEL_RECORDS_CHECKPOINT_UNREADABLE` rows | PASS | AC-6 rows | final gate | |
| AC-7 | Model-routing unchanged behavior (a) to (h) | PASS | AC-7 rows with `Should -BeExactly` | final gate | |
| AC-8 | Never-throw row for the model-routing leg | PASS | AC-8 row | final gate | |
| AC-9 | Preimplementation allow for the receipt Write, relative and absolute | PASS | Both AC-9 rows pass after the prefilter (the receipt name satisfies it) | final gate | |
| AC-10 | One deny row per sub-code with the ordered suffixes | PASS | AC-10 rows | final gate | |
| AC-11 | Preimplementation unchanged behavior | PASS | AC-11 rows plus cycle 1 row `(h)` (no listing for a non-receipt absolute path; gate text exact) | final gate | CR-2 resolved |
| AC-12 | Never-throw rows for the preimplementation leg | PASS | Listing-throw row now asserts the exact `TARGET_WORKTREE_NOT_DERIVABLE` deny text with `Should -BeExactly` | final gate; run 43615945680 | CR-1 resolved |
| AC-13 | Shared helper functions, sub-code rows, slug table, AST rows, purity | PASS | Helper unchanged in cycle 1 | final gate | |
| AC-14 | Line limits, structural suites pass, no literal, header disclosure | PASS | Logical lines 425 and 491; new files 203, 93, 136 | reviewer line count; final gate | |
| AC-15 | End-to-end four-gate allow chain | PASS | E2E suite passed | final gate | |
| AC-16 | Non-goal diff check | PASS | Reviewer re-ran `git diff --name-only origin/main...HEAD` at `0f18cbd8e` after the merge: no excluded path, no `.codex/` path, only `.py` path under `tests/` | `git diff --name-only origin/main...HEAD` | Recorded artifact `non-goal-diff-check.2026-11-14T14-39.md` |
| AC-17 | Validator fixture with both keys | PASS | Pytest gate passed | pytest gate | |
| AC-18 | Fail-before evidence, written once | PASS | `fail-before.2026-11-14T12-42.md` untouched since its commit; cycle 1 wrote a separate `fail-before.2026-11-14T16-07.md` | `git log` | |
| AC-19 | Skill Run Closing substeps and field list | PASS | Skill unchanged in cycle 1 and by the merge | diff inspection | |
| AC-20 | Agent Run Closing substeps | PASS | Agent unchanged | diff inspection | |
| AC-21 | Rule tolerated keys; enum table unchanged | PASS | Rule unchanged | diff inspection | |
| AC-22 | Brief bullet in all byte-identical copies | PASS | Six copies share one SHA-256 value after the main merge; #1182 bullet present | SHA-256; pytest gate | |
| AC-23 | Bundle mirrors, `core.json` entries, push-down tests | PASS | Nine pairs equal by `cmp`; merged `core.json` parses and lists the three hooks | `cmp`; `final-qc-pytest.2026-11-14T16-51.md` | |
| AC-24 | Line coverage at least 85% for the five hook files | PASS | Reviewer parse: 100% (57/57), 100% (21/21), 100% (35/35), 96.36%, 96.53% | XML parse | |
| AC-25 | PowerShell toolchain single loop and CI on the PR head passes | PENDING-CI | Local loop clean (`final-qc-static-powershell.2026-11-14T16-35.md`, final gate); run 43615945680 green on code head `bd1b2856d`; PR #1183 run 43618612246 on `0f18cbd8e` completed with conclusion success at 17:30 UTC (23 of 23 jobs, including `poshqc / PowerShell hook suites (Linux)`, the three shards, and `CI Required Gate`) | `gh pr checks 1183` | CI-dependent; CI is green on the head, so the condition is met; the check-off belongs to the orchestrator at S9; not a blocking finding |

---

## Summary

**Overall Feature Readiness:** READY (AC-25 CI green; S9 check-off pending)

**Criteria summary:**
- **PASS:** 24 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria
- **PENDING-CI:** 1 criterion (AC-25)

**Top gaps preventing PASS:**

None blocking. PR CI on `0f18cbd8e` is green; AC-25 awaits only its S9 check-off by the orchestrator. CR-1 and CR-2 of the prior review are resolved.

**Recommended follow-up verification steps:**

1. Check off AC-25 at S9 against the green PR run 43618612246 on `0f18cbd8e`, provided the head has not moved.
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
- Items remaining: AC-25 (PowerShell toolchain single loop and CI on the PR head, including the Linux hook-suite job); CI is green on the head and the S9 check-off is pending.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 25 | 24 | 1 | AC-1 to AC-24 were already checked and each was re-verified above; AC-25 stays unchecked as pending-CI |

No source-file checkbox change was made by this review.
