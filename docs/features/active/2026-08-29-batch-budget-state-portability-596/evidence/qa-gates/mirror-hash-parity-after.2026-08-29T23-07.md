# Mirror hash parity, post-remediation (remediation cycle 1)

Timestamp: 2026-08-30T01-27

Task: [P4-T1]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Commands (plan command text, the same two pair commands [P0-T6] enumerates, run in the listed
order):

```
git hash-object .claude/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1
git hash-object .claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1
```

Both were executed with the working directory set to the absolute worktree path
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`.

EXIT_CODE: 0 (both commands)

Output Summary: Both invocations exited 0. Pair 1 both hash to
`bbbf70a648a68689939548d45ddbd8909ec98198`: equal within the pair, and different from the
[P0-T6] baseline id `d4503c778bace2d206bbaa356101ee34481446fa`. Pair 2 both hash to
`858bfb116dbd42f3748d930e1fb88bf39f1368de`: equal within the pair, and different from the
[P0-T6] baseline id `db025b9d50826c8ade88d38dd9a651afcaef66d4`. Both halves of the gate hold:
each mirror is byte-identical to its source, and each pair actually moved rather than being
left untouched.

## Pair 1 — PowerShell hook and its bundle mirror

Output, verbatim:

```
bbbf70a648a68689939548d45ddbd8909ec98198
bbbf70a648a68689939548d45ddbd8909ec98198
```

- `.claude/hooks/enforce-powershell-batch-budget.ps1` — `bbbf70a648a68689939548d45ddbd8909ec98198`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` — `bbbf70a648a68689939548d45ddbd8909ec98198`

**Equality result: the two object ids are equal.** The pair is byte-identical.

**Changed-from-baseline result: `bbbf70a6…` differs from the [P0-T6] baseline `d4503c77…`.**
The pair was actually edited by [P1-T4] and [P1-T5].

## Pair 2 — Python hook and its bundle mirror

Output, verbatim:

```
858bfb116dbd42f3748d930e1fb88bf39f1368de
858bfb116dbd42f3748d930e1fb88bf39f1368de
```

- `.claude/hooks/enforce-python-batch-budget.ps1` — `858bfb116dbd42f3748d930e1fb88bf39f1368de`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1` — `858bfb116dbd42f3748d930e1fb88bf39f1368de`

**Equality result: the two object ids are equal.** The pair is byte-identical.

**Changed-from-baseline result: `858bfb11…` differs from the [P0-T6] baseline `db025b9d…`.**
The pair was actually edited by [P2-T4] and [P2-T5].

## All four ids, recorded verbatim, beside their baseline counterparts

| Path | [P0-T6] baseline id | [P4-T1] observed id | Changed |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | `d4503c778bace2d206bbaa356101ee34481446fa` | `bbbf70a648a68689939548d45ddbd8909ec98198` | yes |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` | `d4503c778bace2d206bbaa356101ee34481446fa` | `bbbf70a648a68689939548d45ddbd8909ec98198` | yes |
| `.claude/hooks/enforce-python-batch-budget.ps1` | `db025b9d50826c8ade88d38dd9a651afcaef66d4` | `858bfb116dbd42f3748d930e1fb88bf39f1368de` | yes |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1` | `db025b9d50826c8ade88d38dd9a651afcaef66d4` | `858bfb116dbd42f3748d930e1fb88bf39f1368de` | yes |

## Independent cross-check against git object storage

Recorded because a hash written into an evidence artifact can go stale relative to the tree it
claims to describe. The four ids above were computed live from the current working-tree
contents. They were then cross-checked two ways:

```
git rev-parse HEAD:.claude/hooks/enforce-powershell-batch-budget.ps1 \
              HEAD:extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 \
              HEAD:.claude/hooks/enforce-python-batch-budget.ps1 \
              HEAD:extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1
git cat-file -t bbbf70a648a68689939548d45ddbd8909ec98198   -> blob
git cat-file -t 858bfb116dbd42f3748d930e1fb88bf39f1368de   -> blob
```

The `rev-parse` call returned:

```
bbbf70a648a68689939548d45ddbd8909ec98198
bbbf70a648a68689939548d45ddbd8909ec98198
858bfb116dbd42f3748d930e1fb88bf39f1368de
858bfb116dbd42f3748d930e1fb88bf39f1368de
```

That is the same four ids in the same order, which establishes that the working-tree contents
are identical to the blobs recorded in the HEAD tree at `4ae6656b`. Neither hook nor either
mirror carries an uncommitted modification at this point, so no id recorded here is stale.

## Scope note

The two pairs are exactly the ones [P0-T6] enumerates, so a third party re-running this check
obtains the same set and no selection is left to the executor.
`.claude/hooks/persist-session-id.ps1` and its mirror remain out of scope and are not measured.

## Tree-state independence

This check does not read `.claude/state/` and does not depend on whether that directory is
present, so its result is unaffected by the removal [P4-T4] performs.
