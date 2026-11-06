# Isolation: Concurrent-Shard Pester Run (Issue #1080, P2-T9)

Timestamp: 2026-11-05T23-13
Command: sh SCRATCH/issue-1080-parallel.sh (imports scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCParallelTest with default settings from the worktree root), then sh SCRATCH/issue-1080-junit.sh (reads artifacts/pester/pester-junit.xml and the shard-<i>/shard.log summaries)
EXIT_CODE: 0

## Host

Windows 11 host, PowerShell 7.6.9. The P0-T4 reference ran on the Linux Codespace.

## Run

- Worker count: 8 (default worker count for this host)
- Wall clock: 327.31 s
- Invoke-PoshQCParallelTest exit code: 0
- The merged JUnit file `artifacts/pester/pester-junit.xml` was written and parsed in full (not truncated), so the per-shard fallback was not needed.

| Shard | Exit code | Passed | Failed | Skipped |
|---|---|---|---|---|
| 1 | 0 | 439 | 0 | 0 |
| 2 | 0 | 1548 | 0 | 0 |
| 3 | 0 | 2536 | 0 | 1 |
| 4 | 0 | 1740 | 0 | 7 |
| 5 | 0 | 2130 | 0 | 0 |
| 6 | 0 | 1936 | 0 | 0 |
| 7 | 0 | 2324 | 0 | 2 |
| 8 | 0 | 1724 | 0 | 0 |

## Merged JUnit

JUNIT suites=509 tests=14387 failures=0 errors=0 skipped=10

- tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1: tests=60 failures=0 errors=0
- tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1: tests=29 failures=0 errors=0
- tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1: tests=5 failures=0 errors=0
- Failing suites: none.

## Comparison with P0-T4

P0-T4 had no failing container. This run also has none, so no container has more failures than in P0-T4. The merged totals (14387 tests, 10 skipped, 509 suites) match the P2-T8 single-process run. No host-specific failure was observed. Only gitignored files under `artifacts/pester/` were written; `git status --porcelain` printed nothing after the run.

Output Summary: Invoke-PoshQCParallelTest with 8 workers, every shard exit code 0; merged JUnit 509 suites, 14387 tests, 0 failures, 0 errors, 10 skipped; both new suites have zero failures; no failing container.
