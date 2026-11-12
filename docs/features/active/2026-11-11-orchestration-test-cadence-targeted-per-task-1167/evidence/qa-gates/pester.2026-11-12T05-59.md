# Pester Final Gate ([P2-T2], remediation cycle R1)

Timestamp: 2026-11-12T05-59
Command: sh SCRATCH/issue-1167-pester.sh (pwsh 7 from the item worktree root: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree root>; exit with the returned ExitCode; then JUnit and coverage read from artifacts/pester/)
EXIT_CODE: 0
Output Summary:
- One Invoke-PoshQCParallelTest run: ExitCode 0, wall-clock 721.1 s; merged JUnit and coverage written at 05:58 UTC by this run.
- artifacts/pester/pester-junit.xml: tests=21447, failures=0, errors=0, disabled=10 (passed 21437).
- Row prefixes in the JUnit test cases: TCW- 136 cases, 0 failed; PGW- 56 cases, 0 failed; PCW- 114 cases, 0 failed; PRC 81 cases, 0 failed.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 37558 / 39203 = 95.80%. Instruction coverage (information): 63698 / 67240.
- Comparison with the Phase 0 baseline (pester.2026-11-12T03-25.md: 21311 tests, 0 failed, 95.80% lines): no new failing test; line coverage 95.80% equals the baseline and is above 85%. No PowerShell production file changed, so no per-file comparison applies.
