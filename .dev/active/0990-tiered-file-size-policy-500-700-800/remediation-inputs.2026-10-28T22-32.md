# Remediation Inputs: #990 feature review (initial)

- Timestamp: 2026-10-28T22-32
- Branch: `feature/tiered-file-size-policy-500-700-800-990` at `d60b776c3112301cf56ceeb8c4caca352d392b18`
- Base: `main`, merge base `a7a928d59fd52610c1a627448c8fffac106b23c5`

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

## Source audit artifacts

- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/policy-audit.2026-10-28T22-32.md` (1 finding: PA-B1)
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/code-review.2026-10-28T22-32.md` (CR-1 Major, the same defect as PA-B1; Minor and Info rows are non-blocking)
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/feature-audit.2026-10-28T22-32.md` (1 pending-CI item: FA-B1)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `d60b776c3`)

## Remediation-required findings

### PA-B1 - Baseline generator diverges from the spec line-counting convention

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: the defect is local to one line of `scripts/ci/New-FileSizeBaseline.ps1` and its unit suite; the fix and test need no external decision, credential, or CI result.
- File/location: `scripts/ci/New-FileSizeBaseline.ps1` lines 139-140 (`$count = Get-FileSizeLogicalLineCount -Content ($blobLines -join "`n")`); test gap in `tests/scripts/ci/New-FileSizeBaseline.Tests.ps1` lines 20-51.
- Problem: PowerShell returns a final empty element for a blob whose last line is empty (`...\n\n`). Joining the elements with LF yields text that ends in LF, and `Get-FileSizeLogicalLineCount` subtracts it as a trailing terminator, so the count is one short. Reviewer evidence: 17 of 2142 covered tracked files at HEAD undercount by one (for example `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` 401 vs 402, `scripts/__init__.py` 0 vs 1). In each case the native element count equals the on-disk count.
- Action:
  1. In `New-FileSizeBaseline`, compute the count from the native element array (`$count = @($blobLines).Count`), or rebuild the content so that every element carries its own terminator. Keep the module as the single counting rule, and add a comment explaining why the join form is not used.
  2. In `tests/scripts/ci/New-FileSizeBaseline.Tests.ps1`, add rows for a blob whose last element is `''` (for example 800 text lines plus `''`, expected 801 and baselined), a blob that is a single `''` (expected 1), and an empty blob (expected 0).
  3. Re-run `scripts/ci/New-FileSizeBaseline.ps1 -Ref a7a928d59fd52610c1a627448c8fffac106b23c5 -OutputPath <scratch path>` and confirm the SHA256 still equals `8ed473b7fda2623b51c3b5fa41a5e134398d4e49f1b93ad6649cd5f1ddc6f4ea`. Record the result under `<FEATURE>/evidence/baseline/`.
  4. Run the PowerShell toolchain loop on the touched files (format, analyze, then one full coverage-enabled `Invoke-PoshQCTest -ScanFolders tests/scripts`). Record the evidence under `<FEATURE>/evidence/qa-gates/`, and confirm `New-FileSizeBaseline.ps1` is still at or above 85% line coverage.
- Verification: the new test rows pass; the generator output hash is unchanged; the full Pester run shows 0 failures; `artifacts/pester/powershell-coverage.xml` shows repo-wide line coverage at or above 85%.

## Pending-CI findings

### FA-B1 - AC7 CI leg pending

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: the CI leg of AC7 needs CI results on the PR head, and no pull request exists for this branch yet; the local contract tests and toolchain already pass.
- File/location: `spec.md` and `user-story.md`, `## Acceptance Criteria` item AC7.
- Action (item's own orchestrator run, at S9):
  1. Open the PR through `Agent(pr-author)` with `Author-asserted autoclose issues: #990`.
  2. Wait for CI on the PR head, including the PoshQC shards (which run `FileSizePolicy.RepoGate.Tests.ps1`) and the Linux hook-suite job.
  3. When the CI gate records `success`, change `- [ ] AC7:` to `- [x] AC7:` in both `spec.md` and `user-story.md` from the item worktree, push, and re-run the CI gate so `ci_gate.head_sha` equals the final head.
- Verification: `ci_gate.conclusion` is `success` for the final head; both files show AC7 checked.

## Non-blocking items

- Code review Minor: the excluded directory-name list is duplicated in `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` lines 30-32 and `FileSizePolicy.psm1` lines 202-204. Expose it from the module, or assert that the two copies are equal. This is related to the item and can be fixed in the same remediation cycle.
- Code review Info: directory-name exclusions apply at any depth. No tracked covered file is affected today.
- Code review Info: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` is 501 logical lines (guidance tier, no Warning).

## Do not do

- Do not check off AC7 before CI succeeds on the PR head.
- Do not run a coverage-enabled subset Pester invocation as the final coverage evidence; it overwrites the canonical `artifacts/pester/powershell-coverage.xml` with a partial population.
- Do not hand-edit `config/file-size-baseline.json`; regenerate it only if the hash check in PA-B1 step 3 differs, and explain any difference in evidence.
