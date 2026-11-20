# Remediation Inputs: #527 round-2 feature review

- Timestamp: 2026-10-17T13-25
- Branch: `bug/poshqc-coverage-denominator-527-r2` at `d16acad8147ec65c8a7928c732b40158b202b343`
- Base: `main`, merge base `18d6d1ccd455a280ca3b7a47ce4976f162e8803e`

Review-Verdict: AWAITING_CI

## Source audit artifacts

- `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/policy-audit.2026-10-17T13-25.md` (0 blocking)
- `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/code-review.2026-10-17T13-25.md` (0 blocking)
- `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/feature-audit.2026-10-17T13-25.md` (1 blocking: FA-B1)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `d16acad8`)

## Remediation-required findings

### FA-B1 - Acceptance criterion 1 CI leg unverified

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: the criterion text requires equality with the CI merged report for the PR head, and no pull request or CI run exists for this branch yet; the local legs already pass.
- File/location: `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md`, criterion `Deterministic derivation`
- Fix (item's own orchestrator run, at S9):
  1. After the PR is open and its full CI run succeeds, read the `Merged PowerShell line coverage` aggregator line of the newest run whose `CI full run` job succeeded.
  2. Compare file count, LINE total, and key set with the run A values in `evidence/qa-gates/ci-leg-pending.2026-10-17T13-03.md` (215 files, LINE total 19095, key hash `08ab3a8d86d003c06f1baa8276fccd32c7d0acc0c11254f90f6c218b118449a5`). Record the comparison under `evidence/qa-gates/`.
  3. On a match, change `- [ ] Deterministic derivation:` to `- [x]` in `spec.md`, push, and re-run the CI gate so `ci_gate.head_sha` equals the final head.
- Verification: the comparison artifact exists and states equality; `spec.md` shows criterion 1 checked.

## Non-blocking items

- Spec header `Technical basis` still names the round-1 research file (code review Info).
- Spec `Status` and `Version` fields were not advanced (code review Info).

## Do not do

- Do not check off criterion 1 before the CI comparison is recorded.
- Do not modify production code, tests, or configuration; none is required.
