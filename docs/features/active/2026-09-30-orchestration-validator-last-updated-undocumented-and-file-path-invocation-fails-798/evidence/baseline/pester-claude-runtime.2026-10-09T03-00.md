# P0-T14 Baseline PESTER-SET

Timestamp: 2026-10-09T03-00
Command: mcp__drm-copilot__run_poshqc_test workspace_root=<worktree root> scan_folders=["tests/scripts/claude-runtime"]
EXIT_CODE: 0
Output Summary:
- OPERATOR_OVERRIDE: Pester run through the MCP tool `mcp__drm-copilot__run_poshqc_test` with scan_folders ["tests/scripts/claude-runtime"] instead of the plan's scratchpad runner script (operator override 3). The MCP result carries no counts (`ok: true`); EXIT_CODE records that disposition.
- Counts read from artifacts/pester/pester-junit.xml (mtime 2026-10-09 03:00:37, after the call; not stale).
- testsuites: tests=83 failures=0 errors=0 (whole claude-runtime folder, 8 files).
- checkpoint-hygiene-skill-contract.Tests.ps1: tests=11 failures=0 errors=0 (testcases present)
- claude-runtime-structure.Tests.ps1: tests=6 failures=0 errors=0 (testcases present)
- PESTER-SET: Passed=17 Failed=0
- BASELINE_PESTER_PASSED = 17
- PowerShell coverage: N/A - no PowerShell file changes
- Result: PASS
