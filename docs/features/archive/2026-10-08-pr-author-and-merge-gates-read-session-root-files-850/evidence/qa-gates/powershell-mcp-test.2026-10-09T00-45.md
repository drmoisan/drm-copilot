# P8-T3 Policy-mandated MCP test step

Timestamp: 2026-10-09T00-45
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root; no scan_folders, so the scan set comes from config/poshqc-scan.json)
EXIT_CODE: 1
Output Summary:
  The MCP call returned an error result: {"ok": false, "summary": "Command exited with code 1."}.
  P8-T3 acceptance ("the call returns without raising") is NOT met; P8-T3 stays unchecked and is reported as a deviation.
  Attribution (read-only inspection of the JUnit file the runner wrote to the gitignored artifacts/pester/pester-junit.xml, using a scratch reader): tests=7653, failures=1, errors=0.
  The single failed case is "Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits" (tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1), which is the only member of the P0-T24 baseline failure set (evidence/baseline/pester-codex-hooks.2026-10-08T23-45.md). It is denied by enforce-epic-wave-barrier.ps1 reading this worktree's local epic-mode checkpoint, which LH-5 forbids changing; it is not caused by this change.
  The stderr excerpt the tool returned (publish verification for tag 'mcp-server-v0.0.2' returning NO_RUN, STEP_SKIPPED, UNRESOLVED) is diagnostic text printed by passing publish-verifier tests, not a failure.
  Counts and coverage for this plan come from P8-T4 through P8-T13, because the MCP result carries no test output.
