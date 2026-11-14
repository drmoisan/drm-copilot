# ps-pester

Timestamp: 2026-11-08T14-47
Command: sh SCRATCH/issue-1129-pester.sh (Invoke-PoshQCParallelTest from branch-current PoshQC.psd1)
EXIT_CODE: 0
Output Summary:
ExitCode=0 (Invoke-PoshQCParallelTest: workers=8; wall-clock=932.05s).
artifacts/pester/pester-junit.xml: tests=19623, failures=0, errors=0, disabled/skipped=10 (baseline 19584 tests, 0 failures).
Green suites: EpicWave.Tests.ps1 (25 tests), EpicWave.Parity.Tests.ps1 (9 tests), codex-planning-only-hook.Tests.ps1 (15 tests); ClaudeLibModuleConvention.Tests.ps1 discovers the new module and passes with the whole run.
Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 95.57% (35368/37008); baseline 95.56%.
.claude/lib/epic-wave/EpicWave.psm1: 100.00% (56/56). .claude/lib/epic-wave/Invoke-EpicWave.ps1: 100.00% (5/5).
.codex/hooks/enforce-epic-planning-only.ps1: 95.86% (162/169); baseline 95.86%.
