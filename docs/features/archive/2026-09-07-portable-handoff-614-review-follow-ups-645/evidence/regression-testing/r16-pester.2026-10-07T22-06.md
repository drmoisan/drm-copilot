# R16 Pester Regression Run (P1-T6)

Timestamp: 2026-10-07T22-06
Task: [P1-T6]
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders = ["tests/scripts/codex-hooks"]); then read artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: MCP ok=true. XML last-write 2026-10-07 22:07:49 -0400 (later than task Timestamp 2026-10-07T22-06). Root testsuites tests="1234" errors="0" failures="0" disabled="0". Each of the three issue #645 testcases is present exactly once with status Passed and no failure, error, or skipped child.

## MCP Result

`{"ok":true,"tool":"run_poshqc_test", ...,"summary":"Ran bundled PoshQC test against '<worktree root>' with 1 selected scan folder(s)."}`

## XML Observations

- File: `artifacts/pester/pester-junit.xml`
- Last-write time: 2026-10-07 22:07:49.948 -0400
- Root: `<testsuites ... name="Pester" tests="1234" errors="0" failures="0" disabled="0" time="97.284">`

| Full testcase name | Matches | Status | Child elements |
|---|---|---|---|
| `enforce-epic-planning-only.ps1 loads the semantic MCP registry lazily (issue #697).Get-EpicPlanningRegisteredMcpTool rejection messages (issue #645).throws the exact missing-registry message` | 1 | Passed | none |
| `enforce-epic-planning-only.ps1 loads the semantic MCP registry lazily (issue #697).Get-EpicPlanningRegisteredMcpTool rejection messages (issue #645).throws the exact invalid-operation message` | 1 | Passed | none |
| `enforce-epic-planning-only.ps1 loads the semantic MCP registry lazily (issue #697).Get-EpicPlanningRegisteredMcpTool rejection messages (issue #645).throws the exact invalid-transport-alias message` | 1 | Passed | none |

Result: PASS
