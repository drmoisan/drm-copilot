# Batch A — PowerShell Batch Budget Reset (open)

Timestamp: 2026-09-07T21-10
Task: [P1-T1]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

Command: ls -1 .claude/state/ ; rm -f .claude/state/powershell-batch-budget.*.json ; ls -1 .claude/state/
EXIT_CODE: 0

## Session-id note

The session id is resolved at runtime, not composed from the plan.
`.claude/hooks/enforce-powershell-batch-budget.ps1` derives it from `CLAUDE_SESSION_ID`, then from
`<root>/.claude/state/current-session-id`, then from its fallback, so the budget filename is
worktree-specific. The cycle-1 value `worktree-agent-a478b73e41951af31-e3281c7b` recorded in the
plan prose does **not** apply to this relaunch. This task therefore enumerates the directory and
deletes by glob rather than by a composed filename.

## Pre-reset listing

```
$ ls -1 .claude/state/
(no output)
```

The directory exists and is empty. **Zero `powershell-batch-budget.*.json` files were observed**, so
there are no filenames to record and no file contents to record. That is a valid observation, not a
gap: `.claude/state/` held no budget file at the time this plan was authored, and no PowerShell file
has yet been written through the PreToolUse hook in this session — Phase 0 wrote only Markdown
evidence artifacts and the plan check-offs.

## Deletion

```
$ rm -f .claude/state/powershell-batch-budget.*.json
EXIT_CODE: 0
```

Exit 0 alone does not satisfy this task, because `rm -f` on an absent path also exits 0. The
satisfying evidence is the pair of listings: the pre-reset listing shows no budget file to delete,
and the post-reset listing below confirms none is present.

## Post-reset listing

```
$ ls -1 .claude/state/
(no output)
```

Independent count of entries whose name begins `powershell-batch-budget.`:

```
$ ls -1 .claude/state/ | grep -c '^powershell-batch-budget\.'
0
```

**The post-reset listing contains no file whose name begins `powershell-batch-budget.`.**

## Batch A composition (for reference at close)

| Slot | Files |
|---|---|
| Production (canonical) | `.claude/hooks/hook-command-scanner.ps1`, `.codex/hooks/hook-command-scanner.ps1` |
| Test | `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1`, `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1` |

Two production and two test files, within the per-batch cap of 3 and 3. The two bundle mirrors are
written with `cp`, which does not pass through the PreToolUse hook and therefore consumes no slot.

## Output Summary

`.claude/state/` was empty before the reset and is empty after it. Zero
`powershell-batch-budget.*.json` files were observed at either point, so no filename or file content
was available to record. The deletion command exited 0. Batch A opens with a clean budget and four
slots to consume: two production and two test PowerShell files.
