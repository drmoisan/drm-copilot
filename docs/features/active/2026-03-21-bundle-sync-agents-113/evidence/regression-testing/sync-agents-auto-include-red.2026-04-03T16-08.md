Timestamp: 2026-04-03T16-08
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -Output Detailed"
EXIT_CODE: 1
Output Summary:
- Focused Pester run failed as expected.
- Newly added failing scenario: `Get-AgentContent includes a newly added .instructions.md file without a section allowlist update`.
- Current generated content did not include `new-surface.instructions.md`, confirming the existing implementation still depends on a fixed section list.
