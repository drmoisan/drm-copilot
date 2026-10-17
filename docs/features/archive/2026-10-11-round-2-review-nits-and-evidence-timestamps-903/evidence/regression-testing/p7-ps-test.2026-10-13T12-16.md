# Phase 7 PowerShell Test (P7-T13)

Timestamp: 2026-10-13T12-16
Command: mcp__drm-copilot__run_poshqc_test workspace_root=<worktree> scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib"]
EXIT_CODE: 12
Output Summary: Call disposition `"ok":false` with `Command exited with code 12.` This is recorded as the call disposition only. The fail-first rows for #732 CR-2, CR-4, CR-6, CR-9 and #737 F-1, F-2 are expected to fail until Phases 8 and 10 land, so a non-zero disposition is the anticipated state. The value 12 equals the P6-T16 disposition (34) less the 22 Windows fail-first rows that Phase 7 targets (O-4 x3, M8fe/M8fp x4, S06/S06c x14, kelvin-sign-extension x1), which is consistent with those rows now passing; this is an observation, not an asserted count. Per-row outcomes come from CI (P12-T23).

## MCP result (verbatim, worktree path redacted)

```
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "<worktree>",
  "summary": "Command exited with code 12."
}
```
