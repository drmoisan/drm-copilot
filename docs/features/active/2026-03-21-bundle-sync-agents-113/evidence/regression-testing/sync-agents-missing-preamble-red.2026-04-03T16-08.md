Timestamp: 2026-04-03T16-08
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -Output Detailed"
EXIT_CODE: 1
Output Summary:
- Focused Pester run failed as expected.
- Failing scenario: `Get-AgentContent throws when .github/copilot-instructions.md is missing`.
- Actual error message was `Instructions file not found: \repo\.github\copilot-instructions.md`.
- Expected message was `Required AGENTS preamble file not found: /repo/.github/copilot-instructions.md`.
