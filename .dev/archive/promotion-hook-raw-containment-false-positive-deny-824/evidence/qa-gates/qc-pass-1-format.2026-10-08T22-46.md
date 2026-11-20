# QC Pass 1: Format ([P10-T2])

Timestamp: 2026-10-08T22-46

Command: mcp__drm-copilot__run_poshqc_format (workspace_root = <WORKSPACE_ROOT>; scan_folders = .claude/hooks, .codex/hooks, tests/scripts/claude-hooks, tests/scripts/codex-hooks)
MCP_CALL: returned
EXIT_CODE: 0 (MCP result `ok: true`; no output is read from the result, rule 4)

Command: git status --porcelain (after the MCP call)
EXIT_CODE: 0

```
 M docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/plan.2026-10-08T13-53.md
?? docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/qc-pass-1-porcelain-before.2026-10-08T22-46.md
```

Command: git hash-object (re-run) - omitted because [P10-T1] recorded `WRITESET_LISTED: NONE`.

Restore step: no path outside the write set and outside `FEATURE/` appears in the post-call listing, so no `git restore` call was made. Restored paths: none. FORMAT_OUTSIDE_BASELINE: none.

Command: git status --porcelain (after the restore step)
EXIT_CODE: 0

```
 M docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/plan.2026-10-08T13-53.md
?? docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/qc-pass-1-porcelain-before.2026-10-08T22-46.md
```

Comparison: after removing every line under `FEATURE/` from both listings, this listing and the [P10-T1] listing are both empty, so they are equal.

Command: sh <SCRATCHPAD>/s-fmtcheck.sh writeset
EXIT_CODE: 0

Output Summary:
FORMAT_CLEAN for all 60 write-set `.ps1` files (19 production, 19 bundled mirrors, 22 tests; full list below).
FORMAT_DRIFT_COUNT: 0
Rewritten write-set paths: none (no write-set path appeared in either porcelain listing). The loop does not restart on account of this task.

```
FORMAT_CLEAN .claude/hooks/enforce-epic-worktree-removal-gate.ps1
FORMAT_CLEAN .claude/hooks/enforce-parallel-worktree-removal-gate.ps1
FORMAT_CLEAN .claude/hooks/enforce-pr-author-command-allowlist.ps1
FORMAT_CLEAN .claude/hooks/enforce-pr-author-skill-helpers.ps1
FORMAT_CLEAN .claude/hooks/enforce-promotion-mcp-only.ps1
FORMAT_CLEAN .claude/hooks/hook-command-heredoc.ps1
FORMAT_CLEAN .claude/hooks/hook-command-invocation-operands.ps1
FORMAT_CLEAN .claude/hooks/hook-command-invocation.ps1
FORMAT_CLEAN .claude/hooks/hook-command-payload-powershell.ps1
FORMAT_CLEAN .claude/hooks/hook-command-payload.ps1
FORMAT_CLEAN .claude/hooks/hook-command-scanner.ps1
FORMAT_CLEAN .codex/hooks/enforce-epic-worktree-removal-gate.ps1
FORMAT_CLEAN .codex/hooks/enforce-promotion-mcp-only.ps1
FORMAT_CLEAN .codex/hooks/hook-command-heredoc.ps1
FORMAT_CLEAN .codex/hooks/hook-command-invocation-operands.ps1
FORMAT_CLEAN .codex/hooks/hook-command-invocation.ps1
FORMAT_CLEAN .codex/hooks/hook-command-payload-powershell.ps1
FORMAT_CLEAN .codex/hooks/hook-command-payload.ps1
FORMAT_CLEAN .codex/hooks/hook-command-scanner.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-command-allowlist.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-heredoc.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation-operands.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-payload-powershell.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-payload.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-heredoc.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation-operands.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-payload-powershell.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-payload.ps1
FORMAT_CLEAN extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/hook-command-payload.Tests.ps1
FORMAT_CLEAN tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1
FORMAT_CLEAN tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
FORMAT_CLEAN tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
FORMAT_CLEAN tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
FORMAT_CLEAN tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
FORMAT_CLEAN tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
FORMAT_DRIFT_COUNT: 0
```
