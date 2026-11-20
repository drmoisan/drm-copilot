# Remediation Inputs: #990 feature review (remediation cycle 2 re-audit)

- Timestamp: 2026-10-29T00-20
- Branch: `feature/tiered-file-size-policy-500-700-800-990` at `b5fe10469d22b54cc6b178e38a0a3dddd30110df`
- Base: `main`, merge base `a7a928d59fd52610c1a627448c8fffac106b23c5`
- Prior inputs: `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/remediation-inputs.2026-10-28T23-26.md`

Review-Verdict: AWAITING_CI

## Source audit artifacts

- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/policy-audit.2026-10-29T00-20.md` (CR-M1 closed; no open policy finding)
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/code-review.2026-10-29T00-20.md` (CR-M1 resolved; Info rows only)
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/feature-audit.2026-10-29T00-20.md` (1 pending-CI item: FA-B1)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `b5fe10469`)

## Resolved since the prior review

- CR-M1: resolved in `b5fe10469`. `Get-FileSizeExcludedSegment` in `.claude/lib/file-size-policy/FileSizePolicy.psm1` is the single source of the excluded directory names; `Test-FileSizeCoveredPath` and the repository gate traversal both read it; the Codex twin and both bundle copies match (SHA256 re-verified). Fail-before 44 new tests failing; pass-after 260 / 260; full Pester 11861 tests, 0 failed, 92.88% line coverage; reviewer run 288 / 288 with 0 analyzer findings.

## Pending-CI findings

### FA-B1 - AC7 CI leg pending

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: AC7 needs CI results on the PR head; no pull request exists for this branch yet, and every local leg of AC7 has passing evidence after cycle 2.
- File/location: `spec.md` and `user-story.md`, `## Acceptance Criteria` item AC7.
- Action (item's own orchestrator run, at S9):
  1. Open the PR through `Agent(pr-author)` with `Author-asserted autoclose issues: #990`.
  2. Wait for CI on the PR head, including the PoshQC shards (which run `FileSizePolicy.RepoGate.Tests.ps1`) and the Linux hook-suite job.
  3. When the CI gate records `success`, change `- [ ] AC7:` to `- [x] AC7:` in both `spec.md` and `user-story.md` from the item worktree, push, and re-run the CI gate so that `ci_gate.head_sha` equals the final head.
- Verification: `ci_gate.conclusion` is `success` for the final head, and both files show AC7 checked.

## Advisory items (no verdict effect)

- Code review Info: the new gate row `discovers no covered file below an excluded directory name` largely restates the covered-path rule already asserted in the module suite, and adds a path once per matching segment. Optional `break` for a cleaner message.
- Code review Info: the edited `.DESCRIPTION` line in `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` (line 11) is longer than the surrounding wrap width.
- Code review Info: `Test-FileSizeCoveredPath` allocates the excluded-name array per call; negligible cost.
- Code review Info (carried): directory-name exclusions apply at any depth; the hook treats non-`Edit` tools without `content` as 0 lines; `legacy-codex-hook-contracts.Tests.ps1` is at 501 lines (guidance tier).

## Do not do

- Do not check off AC7 before CI succeeds on the PR head.
- Do not hand-edit `config/file-size-baseline.json`.
- Do not run a subset Pester run with coverage enabled as the final coverage evidence.
