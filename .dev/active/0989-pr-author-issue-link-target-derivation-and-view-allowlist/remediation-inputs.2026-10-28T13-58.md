# Remediation Inputs: #989 feature review

- Timestamp: 2026-10-28T13-58
- Branch: `bug/pr-author-issue-link-target-derivation-and-view-allowlist-989` at `bda84fbf45da8c0c27c660e62ebb71d2ca3262d3`
- Base: `main`, merge base `6c6aa4f0e123c25089f6669761d93d426eb4401c`

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

## Source audit artifacts

- `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/policy-audit.2026-10-28T13-58.md` (1 blocking: PA-B1, PowerShell repo-wide coverage artifact)
- `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/code-review.2026-10-28T13-58.md` (no Blocker; one Major evidence finding, same as PA-B1)
- `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/feature-audit.2026-10-28T13-58.md` (2 pending-CI items: FA-B1, FA-B2)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `bda84fbf4`)

## Remediation-required findings

### PA-B1 - PowerShell repo-wide coverage artifact reports 0%

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: the artifact was overwritten by a later subset run that scanned no hook suite; the executor can regenerate it locally with the existing PoshQC runner, and no external system or decision is involved.
- File/location: `artifacts/pester/powershell-coverage.xml` (LINE 0 covered of 19185, 216 files)
- Fix:
  1. In the item worktree, run one fresh PowerShell 7 process: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts` with coverage enabled through `pester.runsettings.psd1`.
  2. Do not run any other coverage-enabled Pester invocation after it; run architecture-guard or contract re-runs before it, or with coverage disabled.
  3. Read the report-level LINE counter and the LINE counters of the four changed hook files from `artifacts/pester/powershell-coverage.xml`, and record them with the command and exit code in a new `evidence/qa-gates/pester-full.<timestamp>.md`.
- Verification: the artifact reports PowerShell repo-wide line coverage at or above 85%, and each of the four changed hook files at or above 85%; the review hook's coverage check passes.

### FA-B1 - AC8 CI leg pending

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: the toolchain leg of AC8 requires CI results on the PR head, and no pull request exists for this branch yet; mirrors, contract tests, and the local seven-stage loop already pass.
- File/location: `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/spec.md`, `### Acceptance Criteria` item AC8
- Fix (item's own orchestrator run, at S9):
  1. Open the PR through `Agent(pr-author)`; the delegation prompt carries `Author-asserted autoclose issues: #989`.
  2. Wait for CI on the PR head, including the `poshqc / PowerShell QC` shards.
  3. When the CI gate records `success`, change `- [ ] AC8:` to `- [x] AC8:` in `spec.md` from the item worktree, push, and re-run the CI gate so `ci_gate.head_sha` equals the final head.
- Verification: `ci_gate.conclusion` is `success` for the final head; `spec.md` shows AC8 checked.

### FA-B2 - GEN1 Linux environment pending

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: the documented environments include Linux CI, whose hook-suite job runs only on the PR head; the Windows leg passes locally.
- File/location: `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/spec.md`, `## Acceptance Criteria` item "Repro steps now produce the expected behavior in all documented environments."
- Fix (item's own orchestrator run, at S9):
  1. Confirm the `poshqc / PowerShell hook suites (Linux)` job succeeds on the PR head.
  2. Check off the item in `spec.md` in the same commit as AC8, push, and re-run the CI gate.
- Verification: the Linux hook-suite job is green on the final head; `spec.md` shows the item checked.

## Non-blocking items

- Code review Minor: document in the `GitInvoker` parameter help of `Invoke-PrAuthorCurrentBranchGitExe` that a stand-in invoker must set `$global:LASTEXITCODE`.
- Code review Info: the optional `.agents/skills/pr-author/SKILL.md` AC2 parity sentence was not applied (optional per the spec).

## Do not do

- Do not check off AC8 or the GEN1 item before CI succeeds on the PR head.
- Do not modify production code, tests, or coverage configuration for any of these findings; none is required.
- Do not add coverage exclusions to raise the figure.
