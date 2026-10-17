# PowerShell Test Baseline (P0-T17)

Timestamp: 2026-10-07T21-54
Task: [P0-T17]
Command: mcp__drm-copilot__run_poshqc_test(workspace_root=<worktree root>, no scan_folders); then read artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary:
- MCP result `ok: true`.
- `artifacts/pester/pester-junit.xml` last-write time: 2026-10-07 22:01:50 -0400 (later than the task Timestamp 2026-10-07T21-54; `artifacts/pester/` did not exist before the call).
- Root `<testsuites>` attributes: tests=6529, failures=0, errors=0 (disabled=10).
- Counts read from the XML, not from the MCP summary.
- The three issue #645 test names are not yet present (0 matches each), as expected before Phase 1.
