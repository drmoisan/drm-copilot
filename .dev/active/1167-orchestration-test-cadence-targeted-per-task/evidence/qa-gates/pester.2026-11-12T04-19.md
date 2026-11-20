# Pester Final Gate ([P2-T3])

Timestamp: 2026-11-12T04-19
Command: sh SCRATCH/issue-1167-pester.sh (pwsh 7 from the item worktree root: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree root>; exit with the returned ExitCode)
EXIT_CODE: 0
Output Summary:
- One Invoke-PoshQCParallelTest run: workers=8, wall-clock=570.06s, every shard exit 0, ExitCode 0 (fully green); merged JUnit and coverage written.
- artifacts/pester/pester-junit.xml: tests=21446, failures=0, errors=0, skipped=10; passed=21436, failed=0 (Phase 0: 21311 tests, 0 failed; +135 from test-cadence-wording.Tests.ps1).
- Row prefixes (testcase names): TCW- 135 cases, 0 failed; PGW- 56 cases, 0 failed; PCW- 114 cases, 0 failed; PRC- 58 cases, 0 failed.
- Repo-wide LINE coverage (artifacts/pester/powershell-coverage.xml): 37558 / 39203 = 95.80% (Phase 0 baseline: 37558 / 39203 = 95.80%); not below Phase 0 and at least 85%.
- Instruction coverage (information only): 94.73% (Phase 0: 94.73%).
- Per-file production coverage: not applicable; no PowerShell production file changed (the only new PowerShell file is a test file, excluded from the coverage denominator by policy).
