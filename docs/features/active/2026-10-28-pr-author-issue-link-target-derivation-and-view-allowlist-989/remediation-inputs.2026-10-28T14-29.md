# Remediation Inputs: #989 feature re-review (after remediation cycle 1)

- Timestamp: 2026-10-28T14-29
- Branch: `bug/pr-author-issue-link-target-derivation-and-view-allowlist-989` at `540819df84031888d4f297a7bf6be421e4e27be1`
- Base: `main`, merge base `6c6aa4f0e123c25089f6669761d93d426eb4401c`

Review-Verdict: AWAITING_CI

## Source audit artifacts

- `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/policy-audit.2026-10-28T14-29.md` (no blocking finding; PA-B1 resolved)
- `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/code-review.2026-10-28T14-29.md` (no Blocker or Major finding)
- `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/feature-audit.2026-10-28T14-29.md` (2 pending-CI items: FA-B1, FA-B2)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `540819df8`)

## Pending-CI findings

### FA-B1 - AC8 CI leg pending

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: the toolchain leg of AC8 requires CI results on the PR head, and no pull request exists for this branch yet; mirrors, contract tests, the local seven-stage loop, and the canonical coverage artifact already pass.
- File/location: `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/spec.md`, `### Acceptance Criteria` item AC8
- Action (item's own orchestrator run, at S9):
  1. Open the PR through `Agent(pr-author)`; the delegation prompt carries `Author-asserted autoclose issues: #989`.
  2. Wait for CI on the PR head, including the `poshqc / PowerShell QC` shards.
  3. When the CI gate records `success`, change `- [ ] AC8:` to `- [x] AC8:` in `spec.md` from the item worktree, push, and re-run the CI gate so `ci_gate.head_sha` equals the final head.
- Verification: `ci_gate.conclusion` is `success` for the final head; `spec.md` shows AC8 checked.

### FA-B2 - GEN1 Linux environment pending

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: the documented environments include Linux CI, whose hook-suite job runs only on the PR head; the Windows leg passes locally.
- File/location: `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/spec.md`, `## Acceptance Criteria` item "Repro steps now produce the expected behavior in all documented environments."
- Action (item's own orchestrator run, at S9):
  1. Confirm the `poshqc / PowerShell hook suites (Linux)` job succeeds on the PR head.
  2. Check off the item in `spec.md` in the same commit as AC8, push, and re-run the CI gate.
- Verification: the Linux hook-suite job is green on the final head; `spec.md` shows the item checked.

## Resolved since the prior cycle

- PA-B1: `artifacts/pester/powershell-coverage.xml` now reports report-level LINE 17787 of 19185 (92.71%); the four changed hook files are at 97.41%, 95.45%, 100.00%, and 96.43%; `artifacts/pester/pester-junit.xml` records 11448 tests and 0 failures. Verified by direct parse in this review.

## Non-blocking items

- Code review Minor: document in the `GitInvoker` parameter help of `Invoke-PrAuthorCurrentBranchGitExe` that a stand-in invoker must set `$global:LASTEXITCODE`.
- Code review Info: the optional `.agents/skills/pr-author/SKILL.md` AC2 parity sentence was not applied (optional per the spec).

## Do not do

- Do not check off AC8 or the GEN1 item before CI succeeds on the PR head.
- Do not run another coverage-enabled subset Pester invocation in this worktree before the PR is opened; it would overwrite the canonical coverage artifact.
