# P0-T11 Baseline Full Configured Pester Run (CR-PESTER-FULL)

Timestamp: 2026-09-27T10-06
Command: Route C, run in the background: scratchpad cr-pester-full.ps1 = `Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest; exit 0`, run by `pwsh -NoProfile -File` from a scratchpad .sh via `sh` (worktree root as cwd), combined output redirected to a scratchpad log and the process exit code written to a scratchpad file. Settings: scripts/powershell/PoshQC/settings/pester.runsettings.psd1.
EXIT_CODE: 0
Output Summary:
Tests completed in 174.28s
Tests Passed: 5428, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
Covered 95.27% / 0%. 14,744 analyzed Commands in 114 Files.
BeforeAll \ AfterAll failed lines: none
Container failed lines: none
[-] lines: none
Informational line (not a failure): "Coverage file not found; skipping Koverage output: <repo>/tests/scripts/powershell/PoshQC/poshqc-testing-line98-missing-coverage-392.xml" is printed by a PoshQC test that exercises the missing-coverage path.
Pre-existing failures: none.
