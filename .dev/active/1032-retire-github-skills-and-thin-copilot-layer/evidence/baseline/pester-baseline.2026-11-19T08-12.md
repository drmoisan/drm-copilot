# Pester Phase 0 Baseline ([P0-T9])

Timestamp: 2026-11-19T08-12
Plan: plan.2026-10-30T18-39.md
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest over the scan folders of config/poshqc-scan.json, integration and golden lanes excluded); counts read from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml through sh SCRATCH/issue-1032-ps.sh issue-1032-pester-summary.ps1
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 670.46s, every shard exited 0). Merged JUnit: 857 test suites, 29212 tests, 29194 passed, 0 failed, 0 errors, 18 skipped. Repository-wide PowerShell line coverage 96.77% (47184 covered, 1575 missed); command coverage 95.58% (information only). LEDGER-CHAIN-TESTS: `ProcessReductionChain.Ledger.Tests.ps1` 5 tests, 0 failed; `ProcessReductionLedger.Tests.ps1` 72 tests, 0 failed. Parity-matrix gate `HarnessParityMatrix.RepoGate.Tests.ps1`: 7 tests, 0 failed. no in-scope production PowerShell file.

ExitCode: 0
