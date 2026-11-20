# Fail-Before Pester Gate (expect-fail) - remediation cycle 2, issue #1114

Timestamp: 2026-11-07T21-08
Command: sh SCRATCH/issue-1114-pester.sh c2fb (PowerShell 7 in the item worktree: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $r = Invoke-PoshQCParallelTest -Root <item worktree>; exit $r.ExitCode); figures read from the per-shard JUnit files by sh SCRATCH/issue-1114-figures.sh c2fb shards
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Run against the unfixed extractor (Get-CodexReviewPolicyAuditPath as committed in cycle 1) with the [P1-T1] row added. Returned ExitCode 1 (8 workers; shards 1 to 7 exit 0, shard 8 exit 1). No merged artifact was written, so counts were read from the 8 per-shard JUnit files.
- Counts: 16067 tests; 16056 passed; 1 failed; 0 errors; 10 skipped.
- Exactly one failing test: `1114: ignores a non-audit path with a .. segment cited beside a valid policy audit` (suite feature-review-coverage-target.Tests.ps1: 42 tests, 1 failure). It fails on an outcome assertion, not a missing command: `Expected 'docs/features/active/2026-11-07-item-a-1114/policy-audit.2026-11-07T20-00.md', but got $null.` for the `Paths` check, meaning the extractor returned an empty path list because the unfixed code reports AUDIT_PATH_TRAVERSAL for the non-audit path.
- The three existing AUDIT_PATH_TRAVERSAL rows pass (extractor `returns AUDIT_PATH_TRAVERSAL for a path with a .. segment`, the CR-2 row `returns AUDIT_PATH_TRAVERSAL for a .. path with two segments below the feature folder`, and the Resolve-CodexReviewCoverageTarget `returns AUDIT_PATH_TRAVERSAL for a path with a .. segment`); the other 41 rows of the suite pass.
