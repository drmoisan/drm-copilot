# QA Gate: Pester (Invoke-PoshQCParallelTest, Remediation Cycle 2, Phase 2 restart)

Timestamp: 2026-11-07T18-26
Command: sh SCRATCH/issue-1096-pester-run.sh c2r (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCParallelTest -Root <item worktree>; the launcher exits with the returned ExitCode, read first)
EXIT_CODE: 0
Output Summary: Phase 2 restart after the orchestrator's conflict-free merge of origin/main (PR #1113, issue #1105); one background run after the restart P2-T1. ExitCode 0 from 8 shard processes in 312.45 s wall-clock. Merged artifacts/pester/pester-junit.xml holds 15994 testcases with 0 failed or erroring (15788 before the merge; the increase is the #1113 suites). The `LI-14`, `PRL-REAL-LEDGER-AGREES`, and `PGW-SWEEP-SURFACES` testcases are present and Passed; the testsuites of `ProcessReductionLedger.Replay.Tests.ps1` (4 tests) and `planning-contract-wording.Tests.ps1` (88 tests) each record 0 failures and 0 errors.

## Failures

GATE-FAILURE: NONE

## Named Testcases (merged JUnit)

- `Invoke-PoshQCLeakScan (issue #1096).LI-14 reports a file read failure as read-error, not parse-error` under `tests/scripts/powershell/PoshQC/PoshQC.LeakAllowlist.Tests.ps1`: Passed
- `Committed ledger.PRL-REAL-LEDGER-AGREES finds the committed README and entries in agreement` under `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`: Passed
- `Parallel gate wording.Class sweep.PGW-SWEEP-SURFACES finds no removed-class token in any surface` under `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`: Passed

## Testsuites (merged JUnit)

| Testsuite | Tests | Failures | Errors | Skipped |
|---|---|---|---|---|
| `tests/scripts/dev-tools/ProcessReductionLedger.Replay.Tests.ps1` | 4 | 0 | 0 | 0 |
| `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1` | 88 | 0 | 0 | 0 |
| `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1` | 15 | 0 | 0 | 0 |
| `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` | 56 | 0 | 0 | 0 |

## Tag Counts (testcases | passed)

- `LS-K`: 38 | 38
- `LS-R`: 31 | 31
- `LA-`: 21 | 21
- `LI-`: 14 | 14
- `VT-`: 6 | 6
- `WF06-LEAK-SCAN-STEP`: 1 | 1

## Decision 3 Titles

- `resolves a relative path against the PowerShell location, not the process directory`, under `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1`: 1 testcase, Passed
- `resolves a relative virtual environment path against the PowerShell location, not the process directory`, under `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1`: 1 testcase, Passed
- the test whose title begins `defaults $Root to $PWD.ProviderPath when -Root is not supplied`, under `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1`: 1 testcase, Passed

## Coverage (merged LINE counters)

- `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1`: 221/225, 98.22%
- `scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1`: 86/90, 95.56%
- `scripts/powershell/PoshQC/PoshQC.psm1`: 54/61, 88.52%
- `scripts/dev-tools/DrmCopilotPromptSupport.ps1`: 35/40, 87.5%

The merged JUnit and coverage files are copied to `SCRATCH/c2r/pester/` for P2-T5. git status --porcelain through -C was empty after the run.
