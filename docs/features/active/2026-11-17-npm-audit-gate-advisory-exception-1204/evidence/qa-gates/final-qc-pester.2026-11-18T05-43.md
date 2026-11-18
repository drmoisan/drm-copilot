# Final-QC Pester gate with coverage (P3-T2)

Timestamp: 2026-11-18T05-43
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one launcher gate run on the Phase 2 commit plus the final format/analyze state, repository-wide, coverage written by the self-hosted PoshQC module); counts read from `artifacts/pester/pester-junit.xml`, coverage from `artifacts/pester/powershell-coverage.xml`
EXIT_CODE: 0
Output Summary:
- Gate: `Invoke-PoshQCParallelTest: workers=8; wall-clock=770.94s; exit code=0`.
- Counts: 27605 tests, 0 failures, 0 errors, 18 skipped (27587 passed); Phase 0 baseline: 27494 tests, 0 failures, 18 skipped. The 111 additional tests are the new suites; no new failing test.
- Repo-wide line coverage: 45075/46927 = 96.05% (96.0534%); Phase 0 baseline 44864/46711 = 96.05% (96.0460%). No repo-wide drop (+0.0074 points).
- Per-file comparison against the Phase 0 baseline (all 461 baseline files compared by line percentage): 0 files dropped, 0 files missing, 2 new files. Every existing file under scripts/ci/ is unchanged (CiChangeScope.psm1 93.62%, CiRequiredGate.psm1 100%, FileSizeBaseline.psm1 100%, Invoke-CiChangeScope.ps1 91.15%, Invoke-CiRequiredGate.ps1 90%, New-FileSizeBaseline.ps1 100%, Select-PythonTestShard.ps1 89.86%).
- New files (no pre-change run; judged against the 85% line threshold): scripts/ci/NpmAuditGate.psm1 161/161 = 100% and scripts/ci/Invoke-NpmAuditGate.ps1 50/55 = 90.91% (uncovered: the two-line `Invoke-NpmAuditExe` body that starts the real npm process, and the guarded entry-point lines `exit 0` and `exit 1`). Both are at or above 85%.
- Pester reports line coverage only; there is no PowerShell branch gate.
