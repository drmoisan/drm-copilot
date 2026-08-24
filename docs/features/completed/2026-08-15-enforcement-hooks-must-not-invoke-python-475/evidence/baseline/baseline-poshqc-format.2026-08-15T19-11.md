# Baseline — PowerShell Formatting (PoshQC / Invoke-Formatter) — Issue #475

Timestamp: 2026-08-15T19-11

Command: `mcp__drm-copilot__run_poshqc_format` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-afc9f4fd25ec235a5` (default scan set from `config/poshqc-scan.json`)

EXIT_CODE: 0

Output Summary: PoshQC format completed successfully (`"ok": true`). Files changed: 0. Verified with `git status --porcelain` immediately after the run: no `.ps1`, `.psm1`, or `.psd1` file appears in the working tree as modified. The only working-tree entries are the pre-existing feature-promotion changes carried into this worktree before Phase 0 began, none of which are PowerShell files:

```
 D docs/features/potential/2026-08-15-enforcement-hooks-must-not-invoke-python.md
?? docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/
?? docs/features/potential/promoted/2026-08-15-enforcement-hooks-must-not-invoke-python.md
```

The clean pre-change tree is therefore format-clean, establishing the baseline that any post-change formatter run must also modify zero files.
