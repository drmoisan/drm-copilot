# PoshQC Test Baseline (issue #937)

Timestamp: 2026-10-16T00-58
Task: P0-T8
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]
EXIT_CODE: 0
Output Summary: ok=true. Summary (verbatim; the host worktree path is replaced by the token WORKTREE): "Ran bundled PoshQC test against 'WORKTREE' with 2 selected scan folder(s)."
LocalOkBaseline: true

Note: the MCP result carries only the `ok` flag and the summary sentence; no pass count or coverage percentage is asserted. Per-test results come from the CI JUnit artifact (P0-T12).
