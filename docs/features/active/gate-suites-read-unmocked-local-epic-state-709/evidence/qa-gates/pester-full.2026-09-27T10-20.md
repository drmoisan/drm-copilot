# P5-T5 QA Loop Step 4: Full Configured Run (CR-PESTER-FULL), Pass 1

Timestamp: 2026-09-27T10-20
Command: Route C, run in the background: scratchpad cr-pester-full.ps1 = `Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest; exit 0`, run by `pwsh -NoProfile -File` from a scratchpad .sh via `sh` (worktree root as cwd), combined output redirected to a scratchpad log and the process exit code written to a scratchpad file. Settings: scripts/powershell/PoshQC/settings/pester.runsettings.psd1. No run_poshqc_test MCP call was made between this run and CR-COV.
EXIT_CODE: 0
Output Summary:
Tests completed in 176.68s
Tests Passed: 5452, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
Covered 95.28% / 0%. 14,744 analyzed Commands in 114 Files.
BeforeAll \ AfterAll failed lines: none
Container failed lines: none
[-] lines: none
Comparison with the P0-T11 baseline (evidence/baseline/pester-full-baseline.2026-09-27T10-06.md): Passed 5428 -> 5452 (+24, the new regression file), Failed 0 -> 0, Skipped 9 -> 9.
