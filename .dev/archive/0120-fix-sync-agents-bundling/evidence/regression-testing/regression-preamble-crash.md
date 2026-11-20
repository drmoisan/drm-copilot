# Regression Test — Preamble Crash Evidence

- Timestamp: 2026-04-05T10:35:00Z
- Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
- EXIT_CODE: 1 (non-zero, expected)
- Output Summary: Test "Get-AgentContent succeeds when copilot-instructions.md is absent" failed as expected. Exception: "Instructions file not found: \repo\.github\copilot-instructions.md" thrown from Get-InstructionsBody at line 102. Tests Passed: 232, Failed: 1, Skipped: 7.
