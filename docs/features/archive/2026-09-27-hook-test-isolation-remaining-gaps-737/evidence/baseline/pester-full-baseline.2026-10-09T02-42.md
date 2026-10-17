# P0-T16 Baseline full configured Pester run

Timestamp: 2026-10-09T02-42
Command: Route C: pwsh -NoProfile -File (scratchpad .ps1: Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest; exit 0); output captured by the shell wrapper
EXIT_CODE: 1
Output Summary:
PROCESS-EXIT-CODE: 1
Tests Passed: 7916, Failed: 1, Skipped: 10, Inconclusive: 0, NotRun: 0
Pre-existing failure, recorded and not fixed here (see DEV-2 in pester-population-baseline.2026-10-09T02-31.md): the single failing row is caused by the local item checkpoint artifacts/orchestration/orchestrator-state.json read by spawned Codex handlers. Skipped 10 are pre-existing.
[-] Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits 21s (21s|0ms)
