# Phase 0 PowerShell Formatter Baseline — Issue #673 ([P0-T5])

Timestamp: 2026-09-17T10-30

Command: mcp__drm-copilot__run_poshqc_format with workspace_root = <WORKTREE_ROOT> (no scan_folders; whole PowerShell surface), followed by `git -C <WORKTREE_ROOT> status --porcelain`

EXIT_CODE: 0 (this value reflects the MCP call outcome, which returned without error, not a child-process exit status; the porcelain command also exited 0)

Output Summary: The MCP call returned `{"ok":true,"tool":"run_poshqc_format",...,"summary":"Ran bundled PoshQC format against '<WORKTREE_ROOT>'."}`.
The MCP result carries no child-process output, so the result signal for this gate is the Tree Delta
section below. The formatter rewrote no tracked file.

Tree Delta:
```
 M docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-13T20-48.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/
```
Statement: the post-run `git status --porcelain` output is identical to the output recorded in [P0-T4]
(`phase0-worktree-status.md`); there is no difference.

Reverted Paths: none (no rewrite occurred).
