# Cycle-3 Baseline Reference ([P0-T1])

Timestamp: 2026-11-20T05-37
Plan: remediation-plan.2026-11-20T05-28.md
Command: Read of evidence/regression-testing/c2-pester-final.2026-11-20T04-55.md; Read of tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1; grep -c "^ *It '" on that file; wc -l on that file; git rev-parse HEAD
EXIT_CODE: 0
BaseHead: 777ce1bae2a7de9c9a5c167f30a68085ae89ee08
SuiteLogicalLines: 417
CasesPresent: no
Output Summary: Source record c2-pester-final.2026-11-20T04-55.md (BASELINE-REF): ExitCode 0; 29141 tests: 29123 passed, 0 failed, 0 errors, 18 skipped; copilot-layer-retirement.Tests.ps1 row 22 tests, 0 failures; repository-wide line coverage 96.84% (47273 covered, 1541 missed). Confirmed in SUITE: Test-ClrBriefCount holds the retired-path branch (violation text "names the retired path"); Test-ClrCollisionControl holds the workspace value comparison of the three location keys and chat.useClaudeMdFile; neither CASE-A (CLR-BRIEF-COUNT-REJECTS a brief copy that names the retired path) nor CASE-B (CLR-COLLISION-CONTROLS-REJECTS a complete workspace case with a wrong value) exists; SUITE holds 22 It blocks. No gate run (OD-4, cost-benefit).
