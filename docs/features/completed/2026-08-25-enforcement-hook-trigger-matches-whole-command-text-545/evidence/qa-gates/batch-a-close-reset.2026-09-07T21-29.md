# Batch A — PowerShell Batch Budget Reset (close)

Timestamp: 2026-09-07T21-29
Task: [P1-T9]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

Command: ls -1 .claude/state/ ; cat .claude/state/powershell-batch-budget.worktree-agent-ae0df3e53c9c9883f-ed0770f0.json ; rm -f .claude/state/powershell-batch-budget.*.json ; ls -1 .claude/state/
EXIT_CODE: 0

Procedure per `[P1-T1]`: list, record every `powershell-batch-budget.*.json` name and its contents,
delete every such file with `rm -f`, list again.

## Pre-reset listing

```
$ ls -1 .claude/state/
powershell-batch-budget.worktree-agent-ae0df3e53c9c9883f-ed0770f0.json
```

**Exactly one budget file**, which is the expectation this task states. It was absent at `[P1-T1]`
and appeared during batch A.

### Session id, resolved at runtime

The filename carries the session id `worktree-agent-ae0df3e53c9c9883f-ed0770f0`. That value was
resolved by `.claude/hooks/enforce-powershell-batch-budget.ps1` at run time and is worktree-specific,
as standing constraint 7 states. It differs from the cycle-1 value
`worktree-agent-a478b73e41951af31-e3281c7b` recorded in the plan prose, confirming the plan's
instruction not to compose a filename from that value.

### Contents of the observed budget file

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f/.claude/hooks/hook-command-scanner.ps1",
    "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f/.codex/hooks/hook-command-scanner.ps1"
  ],
  "testFiles": [
    "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f/tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1",
    "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f/tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1"
  ]
}
```

| Field | Count | Cap | At or under cap |
|---|---|---|---|
| `prodFiles` | **2** | 3 | yes |
| `testFiles` | **2** | 3 | yes |

Both counts are at most 2, as the acceptance condition requires. The four recorded paths are exactly
the batch-A composition the plan declares: the two canonical scanner copies as production files and
the two scanner suites as test files.

### The bundle mirrors consumed no slot, as predicted

Neither `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1`
nor `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1`
appears in `prodFiles`, even though both were rewritten during `[P1-T6]`. They were written with
`cp`, which does not match the `Write|Edit` PreToolUse matcher and therefore never reached the
budget hook. This is direct confirmation of standing constraint 7's claim rather than an inference
from it.

## Deletion

```
$ rm -f .claude/state/powershell-batch-budget.*.json
EXIT_CODE: 0
```

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

**The post-reset listing contains no `powershell-batch-budget.` file.** Unlike `[P1-T1]`, this
deletion was not a no-op: a file was present before it and absent after it, so the exit code is
corroborated by an observable state change.

Clearing the directory also restores the precondition that
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` requires, since that suite
enumerates `.claude/**` from the filesystem and fails when `.claude/state/` is non-empty (known
issue #510).

## Output Summary

Batch A closed with exactly one budget file present, named
`powershell-batch-budget.worktree-agent-ae0df3e53c9c9883f-ed0770f0.json`, carrying 2 entries in
`prodFiles` and 2 in `testFiles` against caps of 3 and 3. That matches the plan's expectation of
one budget file for batch A's two production and two test PowerShell writes, so the divergence
branch of this task's acceptance was not taken. The file was deleted, the deletion exited 0, and the
post-reset listing of `.claude/state/` is empty.
