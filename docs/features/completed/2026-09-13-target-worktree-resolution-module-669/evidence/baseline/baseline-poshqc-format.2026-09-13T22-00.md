# Baseline — PoshQC Format Stage

Timestamp: 2026-09-17T07:50:16-04:00 (before-listing) / 2026-09-17T07:50:26-04:00 (after-listing)
Command: git status --porcelain -uall ; mcp__drm-copilot__run_poshqc_format workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c scan_folders=[".claude/lib", "tests/scripts/claude-lib", "scripts/powershell/PoshQC/settings", "extensions/drm-copilot/resources/claude-customizations/.claude/lib", "extensions/drm-copilot/resources/powershell/PoshQC/settings"] ; git status --porcelain -uall
EXIT_CODE: 0
Output Summary: MCP result ok=true. The after-listing equals the before-listing, so the format run rewrote no tracked file in the five scan folders. No path was restored. Pre-existing drift paths: none. Scope-Boundary drift paths: none.

## Before-listing (git status --porcelain -uall)

```text
 M docs/features/active/2026-09-13-target-worktree-resolution-module-669/plan.2026-09-13T20-45.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/baseline-batch-budget-state.2026-09-13T22-00.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/baseline-merge-base.2026-09-13T22-00.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/phase0-instructions-read.md
```

## MCP result object (verbatim)

```json
{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c","summary":"Ran bundled PoshQC format against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c' with 5 selected scan folder(s)."}
```

## After-listing (git status --porcelain -uall)

```text
 M docs/features/active/2026-09-13-target-worktree-resolution-module-669/plan.2026-09-13T20-45.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/baseline-batch-budget-state.2026-09-13T22-00.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/baseline-merge-base.2026-09-13T22-00.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/phase0-instructions-read.md
```

After the (empty) restore, the after-listing equals the before-listing.

## Drift classification

Restored paths: none

Pre-existing drift paths:
none

Scope-Boundary drift paths:
none

## Source-derived, not observed

`PoshQC.Analyzer.psm1:62` emits one `Formatted: ` line per rewritten file and `:64` emits one
`Already formatted: ` line per unchanged file, both to the child process stdout, which the MCP layer
discards. The MCP result above carries only the fixed template summary and the `ok` flag. The
before/after listing is therefore the sole observation of which files were rewritten. The formatter was
run once only.
