Timestamp: 2026-04-18T21-20
Command: pwsh -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"
EXIT_CODE: 0
Output Summary:
- Tests discovered: 294
- Passed: 287 (+1 vs baseline)
- Failed: 0 (-1 vs baseline; previously failing claude-settings test now passes)
- Skipped: 7 (unchanged)
- Inconclusive: 0
- NotRun: 0
- Coverage: 20.87% / 0% (2,252 analyzed Commands in 26 Files) — identical to baseline; no per-file coverage regression
- Previously failing test now passes: tests/scripts/claude-runtime/claude-settings.Tests.ps1 "claude-settings.requires .claude/settings.json to declare orchestrator routing and canonical worker hook coverage" (both `It` blocks in the file pass)
