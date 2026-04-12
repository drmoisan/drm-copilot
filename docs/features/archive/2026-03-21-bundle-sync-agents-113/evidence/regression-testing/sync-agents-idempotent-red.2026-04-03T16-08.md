Timestamp: 2026-04-03T16-08
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -Output Detailed"
EXIT_CODE: 1
Output Summary:
- Focused Pester run failed as expected.
- Newly added failing scenario: `Invoke-SyncAgentInstruction produces identical content on repeated runs when inputs are unchanged`.
- Repeated writes were identical, but the generated content still omitted `new-surface.instructions.md`, so the discovery-based idempotence scenario is not yet satisfied.
