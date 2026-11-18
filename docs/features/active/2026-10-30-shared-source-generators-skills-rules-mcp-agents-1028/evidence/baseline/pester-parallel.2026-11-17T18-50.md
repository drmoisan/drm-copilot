# Phase 0 baseline — Pester parallel gate

Timestamp: 2026-11-17T18-50
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one `Invoke-PoshQCParallelTest` run under the machine test-suite lock, integration and golden lanes excluded); counts read from `artifacts/pester/pester-junit.xml`, line coverage from `artifacts/pester/powershell-coverage.xml` (SCRATCH/issue-1028-pesterstats.ps1)
EXIT_CODE: 0
Output Summary: Fully green: 8 shard processes all exited 0, with 793.71 s wall-clock. The JUnit report has 836 test suites, 28127 tests, 28109 passed, 0 failures, 0 errors and 18 skipped. Repo-wide line coverage is 96.69% (45827 covered, 1568 missed) across 465 source files. No pre-existing failure. Context files (child 1 harness modules, not changed by this plan): `scripts/harness/HarnessInventory.psm1` 100.00%, `scripts/harness/HarnessParityMatrix.psm1` 99.25%, `scripts/harness/HarnessSkillContract.psm1` 100.00%. The seven new `scripts/harness-generation/` files have no pre-change run and are judged against the 85% line threshold at the final gate.
