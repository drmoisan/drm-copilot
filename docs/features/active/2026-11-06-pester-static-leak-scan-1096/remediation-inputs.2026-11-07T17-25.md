# Remediation Inputs: pester-static-leak-scan (#1096)

Review-Verdict: AWAITING_CI

- Timestamp: 2026-11-07T17-25
- Review: re-audit after remediation cycle 1
- Branch: `feature/pester-static-leak-scan-1096` at `36372b6c69c6b75f486da0253c54d17279246634`
- Base: `main`, merge base `a2e338950e64f21f23a7f5ab7a15cdeae7169de2` (equal to `origin/main`)

## Source audit artifacts

- `docs/features/active/2026-11-06-pester-static-leak-scan-1096/policy-audit.2026-11-07T17-25.md` (1 blocking: PA-1)
- `docs/features/active/2026-11-06-pester-static-leak-scan-1096/code-review.2026-11-07T17-25.md` (0 blocking)
- `docs/features/active/2026-11-06-pester-static-leak-scan-1096/feature-audit.2026-11-07T17-25.md` (0 blocking; criteria 36 and 37 pending CI)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `36372b6c6`)

## Cycle 1 inputs

MC-1, NB-1, NB-2, and NB-3 of `remediation-inputs.2026-11-07T16-07.md` are closed; the evidence for each is in the code review findings table.

## Remediation-required findings

### PA-1 - Modified workflow has no green run against the branch head

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: the diff modifies .github/workflows/_poshqc.yml; the awaited workflow is CI (.github/workflows/ci.yml, which calls _poshqc.yml and accepts workflow_dispatch). The head 36372b6c6 is pushed to origin, and gh run list for the branch and gh pr list for the head with state all returned nothing, so no run exists yet.
- Finding-Scope: contained
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

- `test_prompt_builder.py` is 769 logical lines (advisory Warning; 768 at the merge base, on `main` before this branch).
- R3 does not pair a restore inside a nested block (Info; conservative, as the spec defines).

## Do not do

- Do not modify production code, tests, or configuration for PA-1; none is required.
- Do not check off criteria 36 or 37 before CI has run on the PR head.
