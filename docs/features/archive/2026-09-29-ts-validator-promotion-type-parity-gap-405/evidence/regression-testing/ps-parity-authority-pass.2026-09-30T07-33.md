# P1-T16 Pester parity reader against the unchanged PowerShell authority

Timestamp: 2026-09-30T07-33
Command: mcp__drm-copilot__run_poshqc_test with workspace_root = worktree root, scan_folders = ["tests/scripts/claude-lib/orchestrator-state"]
EXIT_CODE: 0
MCP-Status: success
Output Summary:
- MCP result `ok: true`, summary "Ran bundled PoshQC test ... with 1 selected scan folder(s)." The result carries no counts.
- Read from `artifacts/pester/pester-junit.xml`: root `testsuites` `tests="395" errors="0" failures="0"`.
- The `testsuite` for `OrchestratorStatePromotionType.Parity.Tests.ps1` reads `tests="15" errors="0" failures="0"` (three guards plus twelve cases).
- P1-T15 line count: `wc -l tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1` printed 114 (below 500).
- Freshness: this junit layout carries no `timestamp` attribute on `testsuites` or `testsuite` elements. The file modification time (2026-09-30 07:33:59) is later than the run start recorded above (07-33), and the new file's suite appears in it, which a stale file could not contain. Recorded as a deviation from the header's timestamp-attribute check.
- The run scoped to the orchestrator-state folder reported no failures, so the two known pre-existing baseline failures (enforce-pr-author-skill, codex-pretooluse-integration) are outside this scope.
- All twelve fixtures matched the PowerShell authority on first run; no fixture correction was needed.
