# Remediation Inputs (Issue #931)

Review-Verdict: AWAITING_CI

**Entry timestamp:** 2026-10-16T02-01
**Feature folder:** `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931`
**Base branch:** `main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
**Head:** `bug/release-flow-waits-on-required-checks-only-931` @ `f73457642c3e47a29f64c6e08b63a529a1570716`
**Work mode:** `minor-audit`; AC source is `issue.md` `## Acceptance Criteria` only
**Blocking finding count:** 2 (autonomous: 0; awaiting_ci: 2; other classes: 0)
**Remediation plan target:** none. No finding is autonomous, so no remediation plan or atomic-planner handoff is created.

## Audit Artifacts

- `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/policy-audit.2026-10-16T02-01.md` (Section 8, PA-1 and PA-2)
- `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/code-review.2026-10-16T02-01.md` (Findings Table, two Major rows classified awaiting_ci)
- `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/feature-audit.2026-10-16T02-01.md` (5 PASS, 1 PARTIAL pending CI, 0 FAIL)

## Trigger Justification

Under `.claude/skills/feature-review-workflow/SKILL.md` step 8, two conditions apply: "required acceptance criteria are FAIL or PARTIAL" (AC6 is PARTIAL pending CI), and "coverage artifact absent for any language that has changed files" (Python). Both are resolved by the PR CI run on the final head, with no branch change. Every locally runnable toolchain stage passes, PowerShell coverage meets every threshold, and no criterion is FAIL.

## Findings

### R1 — AC6 CI-of-record clause pending (PoshQC pass and per-file coverage no-regression)

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: AC6 and plan task P2-T12 name the PR CI artifact poshqc-test-results from job "poshqc / PowerShell QC" (windows-latest) as the record; gh pr list for the branch returned an empty list and gh run list for the branch returned no runs, so the record cannot exist until the PR is opened and CI completes.

**Expected state.** On the PR `CI` run for the final head SHA, `poshqc / PowerShell QC` concludes `success`. In its `poshqc-test-results` artifact, the class-level LINE counter for `Invoke-FullReleaseFlow.ps1` gives a percentage of at least 94.26% (Phase 0 baseline 115/122, run 38730332356). `pester-junit.xml` shows ChecksWait 19/19 and CheckClassification 17/17 passed.

**Local supplementary evidence (not the record).** `artifacts/pester/powershell-coverage.xml` gives 153/160 = 95.62% for the script, and `artifacts/pester/pester-junit.xml` shows 654 tests with 0 failures.

**Clearing procedure.** Follow S9 steps 1-6 in `evidence/qa-gates/ac-verification.2026-10-16T01-51.md`. Then change `- [ ] AC6:` to `- [x] AC6:` in `issue.md`, commit, push, and re-run the S9 gate against the new head SHA.

### R2 — Python post-change coverage report absent for a language with a changed file

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: The only Python change is tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py, a test module excluded from coverage measurement, so the measured value cannot differ from the merge-base value (93.72% line, run 38730332356 job 116406243603, branch gate passed); the PR CI job "quality-checks7 / Code Quality & Tests (3.13)" runs pytest --cov --cov-branch and the step "Enforce Python coverage thresholds" (--min-line 85 --min-branch 75) on the PR head, which supplies the report.

**Expected state.** On the PR `CI` run for the final head SHA, the step `Enforce Python coverage thresholds` in `quality-checks7 / Code Quality & Tests (3.13)` concludes `success`. Its pytest `TOTAL` line shows line coverage of at least 85% and branch coverage of at least 75%.

**Clearing procedure.** Record the job id, the step conclusion, and the `TOTAL` line in `evidence/qa-gates/` (for example `py-coverage-pr-ci.<ts>.md`) when the S9 gate runs.

## Do Not Do

- Do not change production or test code to address R1 or R2; neither requires a code change.
- Do not mark AC6 checked before the PR CI artifact has been inspected.
- Do not substitute the local scoped PoshQC run for the CI record.
- Do not lower or reinterpret coverage thresholds.

## Related findings that do not block the merge

- CR Minor (related to this item): `Get-CheckSetVerdict` has no dedicated tests for a `$null` element (script line 213) or a blank or whitespace `bucket` value (line 214). Suggested tests: `reports unknown for a null check element` and `reports unknown for a blank bucket value`, each asserting `Verdict` `unknown` and `Detail` `(missing)`. Suitable for an in-item fix before merge.
- CR Minor: `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` is at 499 of 500 permitted lines. Extract the two helpers before the next functional edit.
- CR Info (unrelated, from plan Notes): `Invoke-GitExe`/`Invoke-GhExe` declare an `[OutputType([hashtable])]` that does not match what they return, and Phase A treats an auth or network failure as "not yet registered". Record these for separate filing.
- CR Info: removing `--required` makes path-filtered, non-required workflows gate release merges. This is intended by #931 and is the same late-registration race accepted for S9 (#899).
