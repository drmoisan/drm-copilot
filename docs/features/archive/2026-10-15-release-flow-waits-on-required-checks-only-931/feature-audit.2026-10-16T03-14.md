# Feature Audit: Release flow waits on every check (#931)

---

**Audit Date:** 2026-10-16
**Feature Folder:** `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931`
**Base Branch:** `main`
**Head Branch:** `bug/release-flow-waits-on-required-checks-only-931`
**Work Mode:** `minor-audit`
**Audit Type:** Re-audit at remediation cycle 1 exit

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `97559c3e0dcfceb807ae330d3c9e6ae4c5d67964`)
- **Head branch/commit:** `bug/release-flow-waits-on-required-checks-only-931` (commit `a0ddc4d570edd2421ca079e1e8579695444c4e3a`, pushed, working tree clean)
- **Merge base:** `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-16 03:11 UTC for head `a0ddc4d5`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/evidence/**` (67 artifacts, 24 from cycle 1)
  - Additional evidence: `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` (local PoshQC run written 03:06 UTC after commit `92ff4d632`); CI run 38730332356 artifact `poshqc-test-results` and job 116406243603 log (main baseline); reviewer reruns of Black, Ruff, Pyright, pytest, and the evidence-location validator.
- **Feature folder used:** `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931`
- **Requirements source:** `issue.md` only
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: minor-audit`. The AC source is the single `## Acceptance Criteria` section of `issue.md`.
- **Scope note:** the audit scope is the full branch diff `adb9aa5f..a0ddc4d5`, not only the cycle 1 delta. PR context was current for the head SHA and was not regenerated. `origin/main` has advanced 23 commits past the merge base; none of them changes a file this branch changes. No PR or branch CI run exists yet.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md`: only source (`## Acceptance Criteria`, checkbox-based)

### Acceptance criteria

1. AC1: `Wait-ForPullRequestChecks` in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` polls `gh pr checks <PrNumber> --json bucket` without the `--required` flag, so every check on the pull request head is queried, required or not.
2. AC2: `Wait-ForPullRequestChecks` returns 0 only by positive assertion: at least one check is reported and every reported bucket is `pass` or `skipping`.
3. AC3: A `fail` or `cancel` bucket on any check, including a check that branch protection does not mark as required, makes `Wait-ForPullRequestChecks` return 1; a `pending` bucket continues polling within the existing completion bounds.
4. AC4: An empty reported check set, or a bucket value outside `pass`, `skipping`, `pending`, `fail`, and `cancel`, never makes `Wait-ForPullRequestChecks` return 0.
5. AC5: The comment-based help of `Wait-ForPullRequestChecks` and its stderr messages describe all checks on the pull request head rather than required checks, and no other in-repository reference describes the release flow as waiting on required checks only.
6. AC6: The Pester suites under `tests/scripts/dev-tools/` for `Invoke-FullReleaseFlow.ps1` assert the new `gh` argument list and cover a failing non-required check, an empty check set, an unrecognized bucket, and an all-pass-or-skipping set; PoshQC format, analyze, and test pass, and line coverage of `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` does not regress from the Phase 0 baseline.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1: poll without `--required` | PASS | Script line 301 `$ghArgs = @('pr', 'checks', $PrNumber, '--json', 'bucket')`. Test `polls gh pr checks without the required flag` asserts the joined args and `Should -Not -Contain '--required'`. | `git grep -n -i -E "required check\|--required" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (exit 1, no match); `poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py -q` (35 passed) | Reviewer reran both at `a0ddc4d5`. |
| 2 | AC2: 0 only by positive assertion | PASS | `return 0` exists only under `Verdict -ceq 'pass'`. `Get-CheckSetVerdict` returns `pass` only after the empty, fail, unknown, and pending gates. Tests: `returns success when buckets are a mix of pass and skipping`, `returns success when every bucket is skipping`, `reports empty for an empty check set`, two `reports pass ...` tests. | Code inspection of the branch diff; reviewer parse of `artifacts/pester/pester-junit.xml` | All cited tests passed locally (655 tests, 0 failures). |
| 3 | AC3: fail/cancel returns 1; pending keeps polling within bounds | PASS | Verdict `fail` covers any `fail`/`cancel` bucket and returns 1. Tests `returns failure when a non-required check fails`, `returns failure when a check is cancelled`, `reports fail ahead of pending and unknown buckets`. Pending is bounded by `CompletionMaxAttempts`. | Reviewer JUnit parse: Wait-ForPullRequestChecks 19/19, Get-CheckSetVerdict 11/11 | Defaults unchanged (120 x 10 s). |
| 4 | AC4: empty set or unrecognized bucket never returns 0 | PASS | Empty yields `empty` and is re-polled to timeout; unknown, absent, or blank buckets yield `unknown` and return 1. Cycle 1 added `reports unknown for a blank bucket value` (Passed). A `$null` element cannot reach `Get-CheckSetVerdict`: the binder rejects it and `ConvertFrom-CheckPollOutput` rejects it first (`reports failure for a null element`). | Reviewer JUnit parse; `evidence/baseline/cycle1-binder-probe.2026-10-16T02-49.md`; code inspection lines 187-191 and 211-218 | The prior Minor test gap is resolved. |
| 5 | AC5: help, stderr, and in-repo references describe all checks | PASS | Help SYNOPSIS, DESCRIPTION, and OUTPUTS describe every check; stderr messages contain no "required" wording; no case-insensitive `required check` match in the script. | `git grep` above; `evidence/qa-gates/reference-search.2026-10-16T01-51.md` | The dated 2026-07-09 research snapshot is a historical record, left unedited with a recorded disposition. |
| 6 | AC6: Pester assertions; PoshQC pass; coverage no-regression | PARTIAL | Test-content clause met (argument list, failing non-required check, empty set, unrecognized bucket, all-pass-or-skipping set). Local PoshQC format, analyze, and test `ok:true` after cycle 1. Local JUnit: 655 tests, 0 failures. Local per-file coverage 95.63% (153/160) against the Phase 0 baseline of 94.26% (115/122). | `evidence/qa-gates/cycle1-ps-format.2026-10-16T03-05.md`, `cycle1-ps-analyze.2026-10-16T03-05.md`, `cycle1-ps-test.2026-10-16T03-06.md`, `cycle1-local-results-final.2026-10-16T03-06.md`; reviewer JaCoCo parse | Pending CI (`awaiting_ci`). The record is the PR CI `poshqc-test-results` artifact; no PR or CI run exists yet. S9 procedure: `evidence/qa-gates/ac-verification.2026-10-16T01-51.md`, expecting 18 CheckClassification tests per `cycle1-verification.2026-10-16T03-08.md`. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION (pending CI only; no code change required)

**Criteria summary:**
- **PASS:** 5 criteria
- **PARTIAL:** 1 criterion (AC6, pending CI)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC6: the PoshQC result of record and the per-file coverage comparison on the PR head await the PR CI run (`awaiting_ci`).
2. Policy audit PA-2: the Python post-change coverage report for the changed Python test module awaits the PR CI quality-checks job (`awaiting_ci`). This is not an acceptance criterion; it is listed because it gates readiness.

**Cycle 1 outcome:** finding F1 from `remediation-inputs.2026-10-16T02-11.md` is resolved. The blank-bucket test was added, and the null-element alternative is unreachable through both the binder and the caller. No autonomous finding remains.

**Recommended follow-up verification steps:**

1. Open the PR against `main`. When CI concludes `success`, run S9 steps 1-6 in `evidence/qa-gates/ac-verification.2026-10-16T01-51.md`: download `poshqc-test-results`, confirm the per-file LINE percentage for `Invoke-FullReleaseFlow.ps1` is at least 94.26%, and confirm ChecksWait 19/19 and CheckClassification 18/18 in `pester-junit.xml`. Then check off AC6, push, and re-run the S9 gate on the new head.
2. Record the `Enforce Python coverage thresholds` step result and the pytest `TOTAL` line from `quality-checks7 / Code Quality & Tests (3.13)` on the PR run.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

AC1 to AC5 were already checked off by the executor, and this review confirms each as PASS. No checkbox was changed by this review. AC6 is PARTIAL (pending CI) and stays unchecked. It is a CI-dependent criterion, so the item's own orchestrator run checks it off at S9.

### AC Status Summary

- Source: `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md`
- Total AC items: 6
- Checked off (delivered): 5
- Remaining (unchecked): 1
- Items remaining: AC6 (Pester assertions present; PoshQC pass and line-coverage no-regression of `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` against the Phase 0 baseline, pending PR CI)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md` | 6 | 5 | 1 | Checkbox-backed; AC6 is CI-dependent and pending CI |
