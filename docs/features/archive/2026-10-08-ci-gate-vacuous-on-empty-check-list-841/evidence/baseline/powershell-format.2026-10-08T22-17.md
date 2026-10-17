# PowerShell Format Baseline (#841, P0-T10)

Timestamp: 2026-10-10T09-12
Command: mcp__drm-copilot__run_poshqc_format workspace_root=<worktree> scan_folders=[".claude/lib/ci-gate","tests/scripts/claude-lib/ci-gate"]; bracketed by git status --porcelain (before and after) and git diff --stat (after)
EXIT_CODE: 0
Output Summary: FORMAT-SUMMARY ChangedCount=0. PS_FMT_0=0. MCP call returned normally (ok=true). No tracked file changed; no restore was needed, so the baseline stayed read-only.

ROUTE_SUBSTITUTION: scratch scripts A1-A8 prohibited by operator constraint; substitutes below. The plan command `sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 <3 files>` was replaced by the A6 substitute: the MCP format call over the two scan folders (which contain the three plan-named files), with a before/after tree observation.

## Tree observation

- `git status --porcelain` before: `?? docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/`
- MCP result: `{"ok":true,"tool":"run_poshqc_format",...,"summary":"Ran bundled PoshQC format against '<worktree>' with 2 selected scan folder(s)."}`
- `git status --porcelain` after: `?? docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/` (identical)
- `git diff --stat` after: empty

ChangedCount=0
PS_FMT_0=0
