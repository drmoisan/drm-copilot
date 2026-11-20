# R1 Pester Phase 0 Baseline ([P0-T3])

Plan: remediation-plan.2026-11-19T12-09.md
Timestamp: 2026-11-19T12-52
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest over the scan folders of config/poshqc-scan.json, integration and golden lanes excluded); the run was not fully green, so no merged report was written: counts are aggregated from the eight `artifacts/pester/parallel/shard-<i>/pester-junit.xml` files of this run and line coverage from the eight shard `powershell-coverage.xml` files merged in memory with `Merge-PoshQCCoverageReport` (`scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1`), through sh SCRATCH/issue-1032-r1-run.sh issue-1032-r1-pestershards.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: ExitCode 1 (workers 8, wall-clock 672.76s; shard 6 exit 1, shards 1-5, 7, 8 exit 0). 858 test suites, 29026 tests, 29007 passed, 1 failed, 0 errors, 18 skipped. The single failure is `Copilot layer retirement (issue #1032).CLR-PACK-MANIFESTS finds no retired path in any pack manifest`, the expected fail-before state of F1. Repository-wide PowerShell line coverage 96.77% (47184 covered, 1575 missed).

ExitCode: 1

## Failing Tests

- `CLR-PACK-MANIFESTS finds no retired path in any pack manifest` (GUARD-SUITE `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1`): fail-before for F1.

## Named Suites (tests / failures)

- GUARD-SUITE `copilot-layer-retirement.Tests.ps1`: 16 / 1 (the failure above).
- LEDGER-CHAIN-TESTS: `ProcessReductionChain.Ledger.Tests.ps1` 5 / 0; `ProcessReductionLedger.Tests.ps1` 69 / 0 (pass).
- `FileSizePolicy.RepoGate.Tests.ps1`: 5 / 0.
