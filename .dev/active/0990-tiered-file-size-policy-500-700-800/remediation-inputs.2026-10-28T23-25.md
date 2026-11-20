# Remediation Inputs: #990 feature review (remediation cycle 1 re-audit)

- Timestamp: 2026-10-28T23-25
- Branch: `feature/tiered-file-size-policy-500-700-800-990` at `abb51cc69b4096ab367cc4fe708ff6cabf6dea03`
- Base: `main`, merge base `a7a928d59fd52610c1a627448c8fffac106b23c5`
- Prior inputs: `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/remediation-inputs.2026-10-28T22-32.md`

Review-Verdict: AWAITING_CI

## Source audit artifacts

- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/policy-audit.2026-10-28T23-25.md` (PA-B1 closed; no open policy finding)
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/code-review.2026-10-28T23-25.md` (CR-1 resolved; one non-blocking Minor and Info rows only)
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/feature-audit.2026-10-28T23-25.md` (1 pending-CI item: FA-B1)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `abb51cc69`)

## Resolved since the prior review

- PA-B1 / CR-1: resolved in `abb51cc69`. The generator counts `@($blobLines).Count`. The fail-before result was 14 of 15, the pass-after result was 15 of 15, the merge-base output hash is unchanged (`8ed473b7fda2623b51c3b5fa41a5e134398d4e49f1b93ad6649cd5f1ddc6f4ea`), and the full Pester run shows 11816 tests with 0 failed and 92.88% line coverage.

## Pending-CI findings

### FA-B1 - AC7 CI leg pending

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: AC7 needs CI results on the PR head; no pull request exists for this branch yet, and every local leg of AC7 has passing evidence after cycle 1.
- File/location: `spec.md` and `user-story.md`, `## Acceptance Criteria` item AC7.
- Action (item's own orchestrator run, at S9):
  1. Open the PR through `Agent(pr-author)` with `Author-asserted autoclose issues: #990`.
  2. Wait for CI on the PR head, including the PoshQC shards (which run `FileSizePolicy.RepoGate.Tests.ps1`) and the Linux hook-suite job.
  3. When the CI gate records `success`, change `- [ ] AC7:` to `- [x] AC7:` in both `spec.md` and `user-story.md` from the item worktree, push, and re-run the CI gate so that `ci_gate.head_sha` equals the final head.
- Verification: `ci_gate.conclusion` is `success` for the final head, and both files show AC7 checked.

## Non-blocking items

- Code review Minor: the excluded directory-name list is duplicated between `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` lines 30-32 and `.claude/lib/file-size-policy/FileSizePolicy.psm1` lines 202-204. Fix it by exposing the list from the module or by asserting that the two copies are equal. The finding is related to this item and can be fixed before merge. It does not affect the verdict.
- Code review Info: the generator test's two sub-limit rows do not observe the generator's own count. The row that affects output (800 lines plus an empty line, which counts as 801) is asserted directly.
- Code review Info: directory-name exclusions apply at any depth. The hook treats non-`Edit` tools without `content` as 0 lines. `legacy-codex-hook-contracts.Tests.ps1` is at 501 lines, which falls in the guidance tier.

## Do not do

- Do not check off AC7 before CI succeeds on the PR head.
- Do not hand-edit `config/file-size-baseline.json`.
- Do not run a subset Pester run with coverage enabled as the final coverage evidence.
