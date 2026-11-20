# Pester Parallel Baseline - Issue 1034 Remediation Cycle 4 (P0-T5)

Timestamp: 2026-11-07T14-15
Command: sh SCRATCH/issue-1034-c4-ps.sh issue-1034-c4-pester.ps1 -Label baseline (new PowerShell 7 process in the worktree root; imports scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCParallelTest -Root <worktree root> with the default worker count; the launcher exits with the ExitCode property of the returned object)
EXIT_CODE: 0
Output Summary: PASS, before any edit of cycle 4. ExitCode 0, WorkerCount 8, wall clock 585.2 s, all eight shards exit 0. Shard JUnit totals: 17177 tests, 17167 passed, 0 failed, 0 errors, 10 skipped. Baseline failure set: empty. HOOK line coverage 93.9% (77 covered, 5 missed) from the merged artifacts/pester/powershell-coverage.xml.

## Shards

| Shard | Exit code | Tests | Failures | Errors | Skipped |
|---|---|---|---|---|---|
| 1 | 0 | 442 | 0 | 0 | 0 |
| 2 | 0 | 2184 | 0 | 0 | 0 |
| 3 | 0 | 2614 | 0 | 0 | 1 |
| 4 | 0 | 2370 | 0 | 0 | 7 |
| 5 | 0 | 2285 | 0 | 0 | 2 |
| 6 | 0 | 2491 | 0 | 0 | 0 |
| 7 | 0 | 2658 | 0 | 0 | 0 |
| 8 | 0 | 2133 | 0 | 0 | 0 |
| Total | | 17177 | 0 | 0 | 10 |

Passed: 17167.

## Baseline Failure Set

None. No `testcase` in any shard JUnit file holds a failure or error node.

## Named Suites

| Suite | Shard | Tests | Failures | Errors |
|---|---|---|---|---|
| `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` | 4 | 149 | 0 | 0 |
| `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | 6 | 5 | 0 | 0 |
| `tests/scripts/claude-hooks/enforce-docs-complete-gate-target.Tests.ps1` | 7 | 138 | 0 | 0 |
| `COMPOUND_SUITE` | 8 | 209 | 0 | 0 |

## HOOK Line Coverage

| Source | Covered | Missed | Line coverage |
|---|---|---|---|
| merged `artifacts/pester/powershell-coverage.xml` (ExitCode 0) | 77 | 5 | 93.9% |

## Parallel-Only Waiver

Owner directive (binding): the Pester gate is one `Invoke-PoshQCParallelTest` run, re-run only after a fix. No single-process, seeded-shuffle, reversed-order or ordering-comparison run was performed in this cycle, and any task or check that would require one is waived under that directive. Failures seen only in single-process runs do not block.
