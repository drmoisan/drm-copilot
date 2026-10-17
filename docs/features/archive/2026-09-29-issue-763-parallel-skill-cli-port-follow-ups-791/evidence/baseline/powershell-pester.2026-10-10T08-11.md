# Baseline — Pester and Hook Coverage (PoshQC MCP test)

Timestamp: 2026-10-10T08-11
Task: [P0-T15]
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = agent worktree root; scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/claude-runtime"])
EXIT_CODE: 0
CI-DEFERRED: yes

Output Summary:
- MCP result: `{"ok":true,"tool":"run_poshqc_test", ... "summary":"Ran bundled PoshQC test against '<worktree root>' with 2 selected scan folder(s)."}`
- Call disposition: ok = true. The MCP result carries no Pester output.
- The two scan folders contain the three planned test files: `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1`, `tests/scripts/claude-runtime/claude-settings.Tests.ps1` (existence confirmed with `ls`).
- `Tests Passed:` summary line: not available from the MCP result.
- `Covered` line and percentage for `.claude/hooks/enforce-parallel-abandon-gate.ps1` and `.claude/hooks/hook-command-scanner.ps1`: not printed by the MCP result. Per the operator constraint, the numeric Pester and coverage baseline will be taken from the CI PowerShell job log on the pull request; the plan clause that leaves this task incomplete when no `Covered` line is printed is superseded by that constraint.
- `git status --porcelain` after the run: unchanged (no tracked file written).
- Deviation recorded in `evidence/other/execution-deviations.2026-10-10T08-02.md`.
