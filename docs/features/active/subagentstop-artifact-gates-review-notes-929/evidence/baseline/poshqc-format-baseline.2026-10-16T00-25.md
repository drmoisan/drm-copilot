# PoshQC Format Baseline (P0-T20)

Timestamp: 2026-10-16T00-25

Command: git status --porcelain -- . ":(exclude)SCRATCH"   (before)
EXIT_CODE: 0
Output (before):
```
 M docs/features/active/subagentstop-artifact-gates-review-notes-929/plan.2026-10-15T15-44.md
?? docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/
```

Command: mcp__drm-copilot__run_poshqc_format workspace_root=WORKTREE_ROOT scan_folders=[".claude/hooks","extensions/drm-copilot/resources/claude-customizations/.claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]
EXIT_CODE: 0
MCP result: `ok: true`; summary "Ran bundled PoshQC format against 'WORKTREE_ROOT' with 4 selected scan folder(s)." (call disposition only; the MCP result carries no per-file output).

Command: git status --porcelain -- . ":(exclude)SCRATCH"   (after)
EXIT_CODE: 0
Output (after):
```
 M docs/features/active/subagentstop-artifact-gates-review-notes-929/plan.2026-10-15T15-44.md
?? docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/
```

Output Summary: the before and after porcelain outputs are identical (the two entries are this plan's checkbox updates and the new evidence folder, both written by the executor before the formatter call). PRE-EXISTING-DRIFT: NONE
