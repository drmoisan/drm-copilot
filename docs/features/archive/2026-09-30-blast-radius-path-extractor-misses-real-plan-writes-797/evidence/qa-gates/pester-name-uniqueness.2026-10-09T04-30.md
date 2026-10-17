# Pester Name Uniqueness (P7-T6)

Timestamp: 2026-10-09T04-30
Command: mcp__drm-copilot__run_poshqc_test scan_folders ["tests/scripts/claude-runtime"]; then poetry run python (ElementTree) over artifacts/pester/pester-junit.xml, selecting the testsuite test-name-uniqueness.Tests.ps1
EXIT_CODE: 0
Output Summary: substitute evidence. ok:true (83 tests in the folder, 0 failures). test-name-uniqueness.Tests.ps1: Passed=5 Failed=0. The uniqueness test enumerates every *.Tests.ps1 under tests/, so it covers the new It names in BlastRadiusTokenShape.Tests.ps1 and the renamed It in BlastRadiusExtraction.Path.Tests.ps1.

## Deviation (PowerShell route denied)

The plan's `Invoke-Pester -Path tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` needs the PowerShell tool or inline `pwsh`; inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in evidence/baseline/requirements-source.2026-10-09T02-51.md). The MCP test tool accepts folders only, so it ran the containing folder; the counts above are for the uniqueness file alone, read from the JUnit output.
