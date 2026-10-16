# Local Pester fail-before (P1-T11) [expect-fail]

Timestamp: 2026-10-16T01-56
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = WORKTREE, scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"])
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: ok=false, as expected against the unfixed targets file with the new regression rows added. The latest poshqc-test-baseline.*.md (poshqc-test-baseline.2026-10-16T00-58.md) records LocalOkBaseline: true, so the local flag discriminates: it changed from true at baseline to false here. No pass or failure count is asserted from MCP output; per-test fail-before evidence is captured from CI in P1-T13.

MCP summary (verbatim): "Command exited with code 42."
