# Fail-Before Run (expect-fail) - remediation cycle 1, issue #1114

Timestamp: 2026-11-07T20-23
Command: sh SCRATCH/issue-1114-pester.sh failbefore2 (PowerShell 7 in the item worktree: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $r = Invoke-PoshQCParallelTest -Root <item worktree>; exit $r.ExitCode); figures read from the per-shard JUnit files by sh SCRATCH/issue-1114-figures.sh failbefore2 shards
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Run against the unfixed extractor (production tree unchanged since the pre-cycle reference; only the seven new rows of [P1-T1] added). Returned ExitCode 1: 8 workers, shards 1-7 exit 0, shard 8 exit 6 (the shard holding `feature-review-coverage-target.Tests.ps1`). No merged artifact was written, so counts are read from the 8 shard JUnit files.
- Counts: 16066 tests, 16050 passed, 6 failed, 0 errors, 10 skipped. Pre-cycle reference: 15946 tests, 0 failed (+7 new rows plus 113 tests from the merged-in main).
- The 6 failing rows each fail on an outcome assertion (path list or reason code), not a missing command:
  - `Get-CodexReviewPolicyAuditPath`: `1114: extracts a labelled absolute path whose root contains a space` (expected the absolute path, got $null)
  - `Get-CodexReviewPolicyAuditPath`: `1114: extracts a backticked absolute path whose root contains a space` (expected the absolute path, got $null)
  - `Get-CodexReviewPolicyAuditPath`: `1114: extracts a sentence-final path followed by a period` (expected the relative path, got $null)
  - `Get-CodexReviewPolicyAuditPath`: `1114: extracts a path followed by a colon` (expected the relative path, got $null)
  - `Get-CodexReviewPolicyAuditPath`: `1114: returns AUDIT_PATH_TRAVERSAL for a .. path with two segments below the feature folder` (expected AUDIT_PATH_TRAVERSAL, got $null)
  - `Resolve-CodexReviewCoverageTarget`: `1114: resolves a labelled absolute audit path whose root contains a space` (expected no reason code, got AUDIT_NOT_NAMED)
- `1114: extracts both paths from one labelled line that carries two audits` passes.
- No other test fails: suite `feature-review-coverage-target.Tests.ps1` 41 tests, 6 failures; every other listed suite (legacy-codex-hook-contracts, hook-dependency-failure.Codex, validate-feature-review-coverage.Coverage and its Claude twins, FileSizePolicy.RepoGate, and the rest) 0 failures.
