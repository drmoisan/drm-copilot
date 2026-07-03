Timestamp: 2026-04-18T21-20
Command: pwsh -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"
EXIT_CODE: 0 (process), 1 failing test reported in result object
Output Summary:
- Tests discovered: 294
- Passed: 286
- Failed: 1
- Skipped: 7
- Inconclusive: 0
- NotRun: 0
- Coverage: 20.87% / 0% (2,252 analyzed Commands in 26 Files)
- Failing test: "claude-settings.requires .claude/settings.json to declare orchestrator routing and canonical worker hook coverage"
  - File: tests/scripts/claude-runtime/claude-settings.Tests.ps1
  - Line: 12
  - Assertion: $settings.agent | Should -Be 'orchestrator'
  - Actual: $null (no `agent` property on top level of .claude/settings.json)
