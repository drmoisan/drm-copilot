# Baseline — PowerShell Formatting (PoshQC / Invoke-Formatter)

Timestamp: 2026-08-08T20-59

Task: [P0-T6]
Feature: 2026-08-07-parallel-drift-detection-446 (issue #446)
Branch: feature/parallel-drift-detection-446
Integration head at execution: c939b5b8

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a16d115637b38dd44`
(no `scan_folders` argument; the scan set is resolved from the repository PoshQC
configuration)

EXIT_CODE: 0

Output Summary: PASS. The MCP tool returned `"ok": true` with the summary
`Ran bundled PoshQC format against '<workspace_root>'`, which corresponds to exit code 0.
**No pre-existing PowerShell format drift exists at baseline.** This was verified
independently of the tool's own report: `git status --short` immediately after the format run
showed no modified `.ps1`, `.psm1`, or `.psd1` file anywhere in the worktree. The only
working-tree entries were this plan's own Phase 0 check-off edits to
`docs/features/active/2026-08-07-parallel-drift-detection-446/plan.2026-08-07T11-11.md` and the
untracked `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/` directory
holding these baseline artifacts. Because the formatter is a rewriting tool, the absence of
any modified PowerShell file is the operative evidence that zero files required reformatting.
Any PowerShell reformatting observed in the Phase 7 final-QC loop is therefore attributable
to code added by this feature.

## Raw Output

```json
{
  "ok": true,
  "tool": "run_poshqc_format",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a16d115637b38dd44",
  "summary": "Ran bundled PoshQC format against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a16d115637b38dd44'."
}
```

## Verification Command and Output

```
$ git status --short
 M docs/features/active/2026-08-07-parallel-drift-detection-446/plan.2026-08-07T11-11.md
?? docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/
```
