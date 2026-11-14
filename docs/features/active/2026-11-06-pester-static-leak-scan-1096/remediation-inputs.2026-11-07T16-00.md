# Remediation Inputs: pester-static-leak-scan (#1096)

Review-Verdict: AWAITING_CI

- Timestamp: 2026-11-07T16-00
- Branch: `feature/pester-static-leak-scan-1096` at `c8e2152088bb5c27cbeb8718b5e04c8f1ff9df9c`
- Base: `main`, merge base `278bb7047db986bbb0a8652ca323656ce85f8a08`

## Source audit artifacts

- `docs/features/active/2026-11-06-pester-static-leak-scan-1096/policy-audit.2026-11-07T16-00.md` (1 blocking: PA-1)
- `docs/features/active/2026-11-06-pester-static-leak-scan-1096/code-review.2026-11-07T16-00.md` (0 blocking)
- `docs/features/active/2026-11-06-pester-static-leak-scan-1096/feature-audit.2026-11-07T16-00.md` (0 blocking; criteria 36 and 37 pending CI)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `c8e215208`)

## Remediation-required findings

### PA-1 - Modified workflow has no green run against the branch head

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: the diff modifies .github/workflows/_poshqc.yml; the awaited workflow is CI (.github/workflows/ci.yml, which calls _poshqc.yml and accepts workflow_dispatch). The head c8e215208 is pushed to origin, and gh run list for the branch and gh pr list for the head returned nothing, so no run exists yet.
- Rule: `modified-workflow-needs-green-run` in `.claude/skills/feature-review-workflow/SKILL.md`.
- File/location: `.github/workflows/_poshqc.yml`, job `poshqc-static`, step `Scan Pester tests for leaked state`.
- Resolution (no code change):
  1. Obtain a run of `CI` against the branch head, either by `gh workflow run ci.yml --ref feature/pester-static-leak-scan-1096` or by the PR run once the PR is open.
  2. Confirm the run's conclusion is success and its head SHA equals the branch head, or satisfies the predecessor-head conditions of the rule (every later commit changes only the feature folder).
  3. Record the run id, head SHA, and conclusion under `evidence/qa-gates/`, then re-run the review.
- Verification: a recorded green `CI` run whose `poshqc / PowerShell QC static` job includes a passing `Scan Pester tests for leaked state` step for the head.

## Pending CI

Criteria 36 and 37 of `spec.md` and `user-story.md` are CI-dependent and stay unchecked. They carry no separate finding block; the S9 gate owns their check-off. The same run that resolves PA-1 also supplies them when it is the PR run on the final head.

## Non-blocking items

- `test_qc_runner.py` is 711 logical lines (advisory Warning).
- `QCRunner.FULL_TEST` keeps `--cov-report` flags with no `--cov` source, as the spec records (Minor).
- `Invoke-PoshQCLeakScan` labels a file read failure as `parse-error` (Minor).
- `origin/main` has advanced; a trial merge reports no conflict. Bring the branch up to date before the PR.

## Do not do

- Do not modify production code, tests, or configuration for PA-1; none is required.
- Do not check off criteria 36 or 37 before CI has run on the PR head.
