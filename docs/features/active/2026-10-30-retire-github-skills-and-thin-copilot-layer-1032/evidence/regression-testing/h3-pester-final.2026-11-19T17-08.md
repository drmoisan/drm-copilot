# H3 Final Pester Gate ([P2-T2], GATE-RUN)

Timestamp: 2026-11-19T17-08
Plan: plan-h3-sync-writer-retirement.md
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest over the scan folders of config/poshqc-scan.json); summary by sh SCRATCH/issue-1032-r1-run.sh issue-1032-h3-pestersum.ps1 over artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml (merged at 2026-11-19T17:08Z by this run)
EXIT_CODE: 0
Output Summary: ExitCode 0 (8 workers, wall-clock 795.07s). 857 suites; 29012 tests: 28994 passed, 0 failed, 0 errors, 18 skipped (Phase 0: 29026 tests in 858 suites; minus the 20 tests of the deleted suite, plus 6 new GUARD-SUITE tests).
  Repository-wide line coverage: 96.84% (47091 covered, 1539 missed); Phase 0: 96.77% (the deleted writer at 72.09% left the denominator).
  GUARD-SUITE copilot-layer-retirement.Tests.ps1: 22/0; LEDGER-CHAIN-TESTS ProcessReductionChain.Ledger.Tests.ps1 5/0 and ProcessReductionLedger.Tests.ps1 69/0; FileSizePolicy.RepoGate.Tests.ps1 5/0; HarnessInstructions.Tests.ps1 15/0; PoshQC.ShardWeights.Tests.ps1 7/0 (tests/failures).
  The deleted suite sync-agents-from-instructions.Tests.ps1 did not run (not found in the merged JUnit).
  scripts/harness-generation/HarnessInstructions.psm1: line coverage 100.00% (64/64).
