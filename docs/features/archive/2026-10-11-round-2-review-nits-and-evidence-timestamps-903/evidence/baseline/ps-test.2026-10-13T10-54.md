# PowerShell Test Baseline (P0-T29)

Timestamp: 2026-10-13T10-54
Command: mcp__drm-copilot__run_poshqc_test workspace_root=<worktree> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib", "tests/scripts/claude-runtime", "tests/scripts/workflows"]
EXIT_CODE: 0
BASE: 320cb5ddf

EXIT_CODE is the MCP call disposition only (`"ok":true`). The result carries no Pester output, so no pass/fail count or coverage percentage is asserted from it.

MCP result (verbatim, worktree path redacted):
```
{"ok":true,"tool":"run_poshqc_test","workspace_root":"<worktree>","summary":"Ran bundled PoshQC test against '<worktree>' with 5 selected scan folder(s)."}
```

Output Summary: Call disposition ok:true for Pester over the five scan folders. Numeric PowerShell baseline values (per-test outcomes and per-file coverage) come from the CI baseline in P1-T2 to P1-T4.
