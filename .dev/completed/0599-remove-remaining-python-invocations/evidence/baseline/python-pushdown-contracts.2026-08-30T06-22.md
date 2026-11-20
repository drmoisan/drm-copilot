# Baseline — Bundle-Mirror Contracts (push-down `.claude` resource parity)

Timestamp: 2026-08-30T06-22
Task: [P0-T8]
Branch: feature/remove-remaining-python-invocations-599-r2

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q -p no:cacheprovider` (run from the worktree root)

EXIT_CODE: 0

Output Summary: All cases passed. Summary line verbatim:

```
11 passed in 0.14s
```

Eleven cases collected, eleven passed, zero failed.

## Acceptance Disposition

The plan admits this result under exactly one of two conditions. The observed result satisfies the
**first** condition — `EXIT_CODE: 0` with all cases passing — so this is a pass. The second
condition, which would accept a non-zero exit only when the sole assertion message names a path
under `.claude/state/`, was not exercised and is not relied upon.

## Why the Issue #510 Failure Mode Did Not Fire Here

The plan anticipates a possible failure caused by open issue #510: `list_scoped_files`
(`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:34-43`) walks the filesystem
with `rglob("*")` and reads no `.gitignore`, so gitignored runtime state under `.claude/state/`
would be seen as a repo file missing from the bundle. That did not occur, and the reason was
verified rather than assumed:

- `.claude/state/` **does not exist in this worktree**. `ls -la .claude/state/` returned
  `No such file or directory`.
- `.claude/state/` is gitignored at `.gitignore:68`, confirming the plan's citation.

**Cause of the absence, and a correction to the plan's stated mechanism.** The plan states that
`.claude/state/` "is written during this run" by `.claude/hooks/persist-session-id.ps1:150` and
`.claude/hooks/enforce-python-batch-budget.ps1:185`. That does not hold for this execution. This
Phase 0 run is being performed **without worktree isolation**: the executing process's working
directory is a different checkout, so the session hooks write their state into that session
checkout rather than into this worktree. The gitignored state directory the plan expects therefore
never materialized here.

This makes the baseline **cleaner than the plan predicted**, but it also means this run does not
demonstrate that the #510 condition is absent in general. A later run of the same suite from a
session whose working directory *is* this worktree could still produce the `.claude/state/`
assertion the plan's second acceptance condition describes. That remains the expected,
plan-sanctioned outcome and would not be a blocking finding.

Consistent with the plan: deleting the state file is not a remedy, because it regenerates when the
next hook fires.

## Bearing on Later Tasks

This baseline records the starting condition only. The durable, environment-independent mirror gate
is the `cmp -s` loop over the seven enumerated mirrored files at P5-T11, whose result does not
depend on whether gitignored runtime state happens to be present.
