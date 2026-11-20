# Feature Audit: Release flow waits on every check (#931)

---

**Audit Date:** 2026-10-16
**Feature Folder:** `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931`
**Base Branch:** `main`
**Head Branch:** `bug/release-flow-waits-on-required-checks-only-931`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
- **Head branch/commit:** `bug/release-flow-waits-on-required-checks-only-931` (commit `f73457642c3e47a29f64c6e08b63a529a1570716`, pushed, working tree clean)
- **Merge base:** `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-16 01:56 UTC for head `f7345764`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/evidence/**` (40 artifacts)
  - Additional evidence: `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` (local PoshQC run after commit `3fdbc47ca`); CI run 38730332356 artifact `poshqc-test-results` and job 116406243603 log (main baseline); reviewer reruns of Black, Ruff, Pyright, and pytest on the changed Python module.
- **Feature folder used:** `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931`
- **Requirements source:** `issue.md` only
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: minor-audit`. `spec.md` and `user-story.md` are not tracked (`evidence/baseline/minor-audit-gate.2026-10-16T00-11.md`). The AC source is the single `## Acceptance Criteria` section of `issue.md`.
- **Scope note:** the audit scope is the full branch diff `adb9aa5f..f7345764`. PR context was current for the head SHA and was not regenerated. No PR exists yet, so no PR CI run exists for the branch.

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
| 1 | AC1: poll without `--required` | PASS | Script line 301 `$ghArgs = @('pr', 'checks', $PrNumber, '--json', 'bucket')`. Test `polls gh pr checks without the required flag` asserts the joined args `pr checks 291 --json bucket` and `Should -Not -Contain '--required'`. The Python pin failed before and passed after. | `git grep -n -i -E "required check\|--required" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (no match); `poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py -q` (35 passed) | Reviewer reran both. Local JUnit: test passed. |
| 2 | AC2: 0 only by positive assertion | PASS | `return 0` exists only under `Verdict -ceq 'pass'` (lines 334-336). `Get-CheckSetVerdict` returns `pass` only after the empty, fail, unknown, and pending gates (lines 207-234). Tests: `returns success when buckets are a mix of pass and skipping`, `returns success when every bucket is skipping`, `reports empty for an empty check set`, `reports pass ...` (2). | Code inspection of `git diff adb9aa5f..HEAD -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; `artifacts/pester/pester-junit.xml` suite counts | All cited tests passed locally (0 failures). |
| 3 | AC3: fail/cancel returns 1; pending keeps polling within bounds | PASS | Lines 325-328 return 1 on verdict `fail`, which covers any `fail`/`cancel` bucket (lines 220-222). Tests `returns failure when a non-required check fails` (1 gh call, 0 sleeps), `returns failure when a check is cancelled`, `reports fail ahead of pending and unknown buckets`. Pending is bounded by `CompletionMaxAttempts` (lines 338-341); existing tests `waits through pending checks then completes` and `returns failure on completion timeout` are retained. | `artifacts/pester/pester-junit.xml` (ChecksWait 19/19, CheckClassification 17/17) | Defaults unchanged (120 x 10 s). |
| 4 | AC4: empty set or unrecognized bucket never returns 0 | PASS | Empty yields verdict `empty` and is re-polled to timeout; unknown or absent buckets yield `unknown` and return 1. Unparsable first poll returns 1; a failed or unparsable re-poll becomes an empty set. Tests: `keeps polling and times out on an empty check set`, `returns failure on an unrecognized bucket`, `returns failure on a check with no bucket property`, `returns failure without throwing on unparsable check output`, `continues after a non-zero completion poll`, `continues after an unparsable completion poll`, `times out when completion polls keep failing`, `reports unknown for a bucket that differs only in case`. | `artifacts/pester/pester-junit.xml`; code inspection lines 315-355 | Minor gap (code-review): null element and blank bucket alternatives have no dedicated test. The implementation handles both (lines 213-215), so the criterion is met. |
| 5 | AC5: help, stderr, and in-repo references describe all checks | PASS | Help SYNOPSIS, DESCRIPTION, and OUTPUTS rewritten; stderr messages `A check failed for PR #`, `A check reported an unrecognized bucket for PR #`, `Could not parse the check results for PR #`; no case-insensitive `required check` match in the script. `A required check failed` is absent outside `docs/features`. `.vscode/tasks.json` says "waits for gh checks". | `git grep -n -i -E "required check\|--required" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; `evidence/qa-gates/reference-search.2026-10-16T01-51.md` | The only remaining match outside feature records is the dated historical audit `docs/research/2026-07-09-active-features-delivery-status-audit.md` line 31. It is a 2026-07-09 snapshot, not a current description, and was left unedited with a recorded disposition. Other matches are in prior items' feature records. |
| 6 | AC6: Pester assertions; PoshQC pass; coverage no-regression | PARTIAL | Test-content clause met: new argument-list assertion; failing non-required check; empty set; unrecognized bucket; all-pass-or-skipping set. Local PoshQC format, analyze, and test returned `ok:true`. Local JUnit: 0 failures. Local per-file coverage is 95.62% (153/160) against the Phase 0 baseline of 94.26% (115/122). | `evidence/qa-gates/ps-format.2026-10-16T01-45.md`, `ps-analyze.2026-10-16T01-48.md`, `ps-test.2026-10-16T01-50.md`, `evidence/baseline/ps-coverage-main.2026-10-16T01-23.md`; reviewer JaCoCo parse of `artifacts/pester/powershell-coverage.xml` | Pending CI. The plan designates the PR CI `poshqc-test-results` artifact as the record for the PoshQC and coverage clauses. No PR or CI run exists yet. Classified `awaiting_ci`; the S9 procedure is in `evidence/qa-gates/ac-verification.2026-10-16T01-51.md`. Local evidence indicates the clause is expected to pass. |

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
2. Policy audit PA-2: the Python post-change coverage report for the changed Python test module awaits the PR CI quality-checks job (`awaiting_ci`). This is not an acceptance criterion; it is listed here because it gates readiness.

**Recommended follow-up verification steps:**

1. Open the PR against `main`. When CI concludes `success`, run S9 steps 1-6 in `evidence/qa-gates/ac-verification.2026-10-16T01-51.md`: download `poshqc-test-results`, derive the per-file LINE counter for `Invoke-FullReleaseFlow.ps1`, confirm it is at least 94.26%, confirm ChecksWait 19/19 and CheckClassification 17/17 in `pester-junit.xml`, then check off AC6, push, and re-run the S9 gate on the new head.
2. Record the `Enforce Python coverage thresholds` step result and the pytest `TOTAL` line from `quality-checks7 / Code Quality & Tests (3.13)` on the PR run.
3. Optional, related to this item: add the two `Get-CheckSetVerdict` tests named in the code review (null element, blank bucket).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

AC1 to AC5 were already checked off by the executor (P2-T13 to P2-T17), and this review confirms each as PASS. No checkbox was changed by this review. AC6 is PARTIAL (pending CI) and stays unchecked. It is a CI-dependent criterion, so the item's own orchestrator run checks it off at S9.

### AC Status Summary

- Source: `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md`
- Total AC items: 6
- Checked off (delivered): 5
- Remaining (unchecked): 1
- Items remaining: AC6 (Pester assertions present; PoshQC pass and line-coverage no-regression of `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` against the Phase 0 baseline, pending PR CI)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md` | 6 | 5 | 1 | Checkbox-backed; AC6 is CI-dependent and pending CI |
