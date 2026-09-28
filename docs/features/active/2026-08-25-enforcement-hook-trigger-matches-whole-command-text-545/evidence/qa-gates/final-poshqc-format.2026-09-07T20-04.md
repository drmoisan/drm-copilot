# Final QA — Formatting Stage ([P4-T2])

Timestamp: 2026-09-07T20-04
Task: [P4-T2]
Command: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` = `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31`, no `scan_folders`
EXIT_CODE: 0
Result value: `ok: true`

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context. The formatter is invoked through the `mcp__drm-copilot__run_poshqc_format` MCP function
rather than a `pwsh Invoke-Formatter` call. Route substitution, not a skipped stage.

The exit code alone is not the acceptance: this formatter exits 0 after rewriting, so its exit code
is identical on a clean run and on a repairing one. The tree observations below are the acceptance.

## Porcelain path counts

Before-set path count: **22**
After-set path count: **22**
**Set-difference count (paths present after and absent before): 0**

Both captures are byte-identical. The full post-run listing is:

```
 M .claude/hooks/validate-bash.ps1
 M .codex/hooks/validate-bash.ps1
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1
 M tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
 M tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-a-budget-reset.2026-09-07T19-38.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-a-pair-parity.2026-09-07T19-43.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-a-toolchain.2026-09-07T19-47.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b-budget-reset.2026-09-07T19-48.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b-pair-parity.2026-09-07T19-52.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b-toolchain.2026-09-07T19-59.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-c-budget-reset.2026-09-07T20-03.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/r2-no-code-change.2026-09-07T20-02.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-r1-claude.2026-09-07T19-41.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-r1-codex.2026-09-07T19-51.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-r1-claude.2026-09-07T19-44.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-r1-codex.2026-09-07T19-55.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T17-44.md
```

## SHA-256 before and after, all four `validate-bash.ps1` copies and both changed test suites

| # | File | Before | After | Changed |
|---|---|---|---|---|
| 1 | `.claude/hooks/validate-bash.ps1` | `6dfcadff76c36737fce9490917d757cd54fed56f8c0e0493ada67684eab0ff78` | `6dfcadff76c36737fce9490917d757cd54fed56f8c0e0493ada67684eab0ff78` | no |
| 2 | `.codex/hooks/validate-bash.ps1` | `9aed5b36a2284f3aa78fdd56e2dd2513bb1d96e34c4d95e3281a5a302ee43012` | `9aed5b36a2284f3aa78fdd56e2dd2513bb1d96e34c4d95e3281a5a302ee43012` | no |
| 3 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | `6dfcadff76c36737fce9490917d757cd54fed56f8c0e0493ada67684eab0ff78` | `6dfcadff76c36737fce9490917d757cd54fed56f8c0e0493ada67684eab0ff78` | no |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | `9aed5b36a2284f3aa78fdd56e2dd2513bb1d96e34c4d95e3281a5a302ee43012` | `9aed5b36a2284f3aa78fdd56e2dd2513bb1d96e34c4d95e3281a5a302ee43012` | no |
| 5 | `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | `c453b877f32dc07ff18a6c3f18f6793aeadd93fb4af2e9dcae6ba3647ce8aecf` | `c453b877f32dc07ff18a6c3f18f6793aeadd93fb4af2e9dcae6ba3647ce8aecf` | no |
| 6 | `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` | `380b44d065b833377a916f804ec874a2ee23217950aaa9fb5c5202dc2bab6956` | `380b44d065b833377a916f804ec874a2ee23217950aaa9fb5c5202dc2bab6956` | no |

All six SHA-256 values are identical before and after. No mirror command needed re-running and
Phase 4 did not restart at this task.

The two canonical hooks and their bundle copies also remain equal to each other across the pair:
rows 1 and 3 carry the same value, and rows 2 and 4 carry the same value.

Output Summary: Final format stage EXIT_CODE 0 with `ok: true`. Porcelain before-count 22,
after-count 22, set-difference 0. All six SHA-256 values unchanged. Clean run, not a repairing run;
no restart.
