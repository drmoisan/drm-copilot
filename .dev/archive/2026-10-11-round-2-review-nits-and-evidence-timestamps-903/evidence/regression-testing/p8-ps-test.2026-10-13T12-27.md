# Phase 8 PowerShell Test (P8-T11)

Timestamp: 2026-10-13T12-27
Command: mcp__drm-copilot__run_poshqc_test workspace_root=<worktree> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]
EXIT_CODE: 4
Output Summary: Call disposition `"ok":false` with `Command exited with code 4.` This is recorded as the call disposition only. The #737 F-1 non-compliant rows and the F-2 row are expected to fail until Phase 10 lands, so a non-zero disposition is the anticipated state. The value 4 equals the P7-T13 disposition (12) less the 8 fail-first rows Phase 8 targets (U11b x4, U24 x2, the 120-character parity row, the CR-9 contract row), and equals the count of the four Phase 10 rows; this is an observation, not an asserted count. Per-row outcomes come from CI (P12-T23).

## MCP result (verbatim, worktree path redacted)

```
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "<worktree>",
  "summary": "Command exited with code 4."
}
```
