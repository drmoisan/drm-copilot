# Phase 0 — Formatting Baseline ([P0-T4])

Timestamp: 2026-09-07T19-32
Task: [P0-T4]
Command: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` = `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31`, no `scan_folders`
EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context; the runtime guard refuses them. The PowerShell formatter is therefore invoked through the
`mcp__drm-copilot__run_poshqc_format` MCP function rather than through a `pwsh Invoke-Formatter`
call. This is a route substitution, not a skipped stage.

Tool result value: `{"ok":true,"tool":"run_poshqc_format", ... ,"summary":"Ran bundled PoshQC format
against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31'."}`

## Why the exit code alone is not the acceptance

This formatter exits 0 whether or not it rewrote a file, so its exit code is identical on a clean run
and on a repairing one. The acceptance is the tree observation below: a porcelain set difference of
zero and four unchanged SHA-256 values.

## `git status --porcelain` before the run

```
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T17-44.md
```

Before-set path count: **2**

## `git status --porcelain` after the run

```
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T17-44.md
```

After-set path count: **2**

Set-difference count (paths present after and absent before): **0**

## SHA-256 before and after

| File | Before | After | Changed |
|---|---|---|---|
| `.claude/hooks/validate-bash.ps1` | `bd0c2ffe8f1e490c417d21717393878d05f5f15038899da09928e91ba22d3146` | `bd0c2ffe8f1e490c417d21717393878d05f5f15038899da09928e91ba22d3146` | no |
| `.codex/hooks/validate-bash.ps1` | `609c1af789e1f091d4710f77e1ece15c56b0183870cc0d09ba74b2f9fe989ba6` | `609c1af789e1f091d4710f77e1ece15c56b0183870cc0d09ba74b2f9fe989ba6` | no |
| `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | `a5d95e1d4ea03b0dbe0a9883fbd9f790719e49d3a5128f2befdd137dcd42f5b7` | `a5d95e1d4ea03b0dbe0a9883fbd9f790719e49d3a5128f2befdd137dcd42f5b7` | no |
| `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` | `3b20a5cce3874f611cabb02ca4590727669d519c937ff2f912da1a50b9847442` | `3b20a5cce3874f611cabb02ca4590727669d519c937ff2f912da1a50b9847442` | no |

All four SHA-256 values are identical before and after. No pre-existing formatting drift was
repaired by this run, so this baseline absorbs no drift and no re-run was required.

Output Summary: PoshQC format run at workspace root exited 0 with `ok: true`. Porcelain before-count
2, after-count 2, set-difference 0. All four in-scope SHA-256 values unchanged. Clean run, not a
repairing run; no mirror re-copy and no re-run needed.
