# Pester Final Gate (parallel) - remediation cycle 2, issue #1114

Timestamp: 2026-11-07T21-21
Command: sh SCRATCH/issue-1114-pester.sh c2final (PowerShell 7 in the item worktree: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $r = Invoke-PoshQCParallelTest -Root <item worktree>; exit $r.ExitCode); figures read by sh SCRATCH/issue-1114-figures.sh c2final merged
EXIT_CODE: 0
Output Summary:
- Returned ExitCode 0 (8 workers, all 8 shards exit 0). Fully green, so the merged artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml of this run were read.
- Counts: 16067 tests; 16057 passed; 0 failed; 0 errors; 10 skipped. Cycle 1 final gate reference (pester-parallel.2026-11-07T20-33.md): 16066 tests, 16056 passed, 0 failed, 10 skipped. No new failing test (+1 test: the [P1-T1] row, passing).
- Repo-wide PowerShell line coverage: 94.13% (24716 covered, 1542 missed); reference 94.13% (24714 covered, 1542 missed). No drop.
- `.codex/hooks/feature-review-coverage-target.ps1`: 98.73% (78 covered, 1 missed); reference 98.70% (76 covered, 1 missed). At least 85% and not below the cycle 1 figure. The only missed line is the body line of `Invoke-CodexReviewCoverageGitExe`.
- Passing rows: suite `feature-review-coverage-target.Tests.ps1` 42 tests, 0 failures, which includes the [P1-T1] row (failed before the fix in evidence/regression-testing/fail-before.2026-11-07T21-08.md, passes now), the three AUDIT_PATH_TRAVERSAL rows (extractor `returns AUDIT_PATH_TRAVERSAL for a path with a .. segment`, the CR-2 row `returns AUDIT_PATH_TRAVERSAL for a .. path with two segments below the feature folder`, and the Resolve-CodexReviewCoverageTarget row of the same name as the first), and the other existing rows; `legacy-codex-hook-contracts.Tests.ps1` 43 tests, 0 failures; `validate-feature-review-coverage.Coverage.Tests.ps1` (codex-hooks) 40 tests, 0 failures; `hook-dependency-failure.Codex.Tests.ps1` 93 tests, 0 failures; every other tracked suite 0 failures.
