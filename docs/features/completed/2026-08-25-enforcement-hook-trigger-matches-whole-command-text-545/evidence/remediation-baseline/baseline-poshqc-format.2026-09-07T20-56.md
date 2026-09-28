# Baseline — PoshQC Format (cycle 2)

Timestamp: 2026-09-07T20-56
Task: [P0-T4]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

Command: git rev-parse --show-toplevel; git status --porcelain (before); mcp__drm-copilot__run_poshqc_format workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f (no scan_folders); git status --porcelain (after)
EXIT_CODE: 0

## TOOLCHAIN_SUBSTITUTION

`pwsh`, `powershell`, and `cmd` are not invocable in this session; the runtime guard refuses them.
`Invoke-Formatter` was therefore reached through the MCP route
`mcp__drm-copilot__run_poshqc_format`, which is the repository-designated PowerShell format command
per `.claude/rules/powershell.md`. No stage was skipped.

## Worktree confirmation (standing constraint 8, discharged here)

This is the first MCP call of the run.

```
$ git rev-parse --show-toplevel
C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f
```

The observed toplevel resolves to
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`, which is exactly
the `workspace_root` value every MCP call in this plan passes. The `BLOCKED` branch of this task was
not taken. The check is not ceremonial: a different worktree at
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` still exists on
disk from cycle 1, so a stale `workspace_root` would have run silently against another checkout.

## `git status --porcelain` — before

```
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T20-45.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/baseline-git-state.2026-09-07T20-55.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/phase0-instructions-read.2026-09-07T20-52.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/phase0-remediation-documents-read.2026-09-07T20-54.md
```

## Formatter result

```json
{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f","summary":"Ran bundled PoshQC format against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f'."}
```

## `git status --porcelain` — after

```
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T20-45.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/baseline-git-state.2026-09-07T20-55.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/phase0-instructions-read.2026-09-07T20-52.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/phase0-remediation-documents-read.2026-09-07T20-54.md
```

## Set-difference count

Computed with `comm -13 <sorted-before> <sorted-after>` — paths present after and absent before:

```
(no output)
```

**Set-difference count: 0.**

This is the observation the acceptance condition requires beyond the exit code. The formatter exits
0 whether or not it rewrote a file, so its exit code alone gates nothing; a count of 0 is direct
evidence that the formatter rewrote no tracked file and created no untracked one. The two porcelain
captures are byte-identical.

## Output Summary

`ok: true`, exit 0. Worktree confirmed as
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`. The porcelain
capture is unchanged across the formatter run and the set-difference count is 0, so the tree carried
no pre-existing PowerShell formatting drift and the formatter repaired nothing. The baseline is a
clean format state.
