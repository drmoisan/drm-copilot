# H3 Pester Phase 0 Baseline ([P0-T5], GATE-RUN)

Timestamp: 2026-11-19T15-09
Plan: plan-h3-sync-writer-retirement.md
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest over the scan folders of config/poshqc-scan.json; integration and golden lanes excluded by the launcher); summary by sh SCRATCH/issue-1032-r1-run.sh issue-1032-h3-pestersum.ps1 over artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml (merged at 2026-11-19T15:07Z by this run)
EXIT_CODE: 0
Output Summary: ExitCode 0 (8 workers, wall-clock 1020.91s). 858 test suites; 29026 tests: 29008 passed, 0 failed, 0 errors, 18 skipped.
  Repository-wide line coverage: 96.77% (47184 covered, 1575 missed).
  scripts/dev-tools/sync-agents-from-instructions.ps1: in the coverage population (root `scripts` of config/poshqc-coverage.json); line coverage 72.09% (93/129) — pre-deletion record.
  tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 (pre-deletion record): 20 tests, 0 failures.
  GUARD-SUITE copilot-layer-retirement.Tests.ps1: 16/0; ProcessReductionChain.Ledger.Tests.ps1: 5/0; ProcessReductionLedger.Tests.ps1: 69/0; PoshQC.ShardWeights.Tests.ps1: 7/0 (tests/failures).
