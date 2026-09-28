# Mirror hash parity, pre-remediation (remediation cycle 1)

Timestamp: 2026-08-30T00-49

Task: [P0-T6]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Commands (plan command text, run in the listed order):

```
git hash-object .claude/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1
git hash-object .claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1
```

Both were executed with the working directory set to the absolute worktree path `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`.

EXIT_CODE: 0 (both commands)

## Pair 1 — PowerShell hook and its bundle mirror

Output, verbatim:

```
d4503c778bace2d206bbaa356101ee34481446fa
d4503c778bace2d206bbaa356101ee34481446fa
```

- `.claude/hooks/enforce-powershell-batch-budget.ps1` — `d4503c778bace2d206bbaa356101ee34481446fa`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` — `d4503c778bace2d206bbaa356101ee34481446fa`

**Equality result: the two object ids are equal.** The pair is byte-identical.

## Pair 2 — Python hook and its bundle mirror

Output, verbatim:

```
db025b9d50826c8ade88d38dd9a651afcaef66d4
db025b9d50826c8ade88d38dd9a651afcaef66d4
```

- `.claude/hooks/enforce-python-batch-budget.ps1` — `db025b9d50826c8ade88d38dd9a651afcaef66d4`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1` — `db025b9d50826c8ade88d38dd9a651afcaef66d4`

**Equality result: the two object ids are equal.** The pair is byte-identical.

## All four ids, recorded verbatim

| Path | Object id |
| --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | `d4503c778bace2d206bbaa356101ee34481446fa` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` | `d4503c778bace2d206bbaa356101ee34481446fa` |
| `.claude/hooks/enforce-python-batch-budget.ps1` | `db025b9d50826c8ade88d38dd9a651afcaef66d4` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1` | `db025b9d50826c8ade88d38dd9a651afcaef66d4` |

## Independent cross-check against git object storage

Recorded because a hash written into an evidence artifact can go stale relative to the tree it claims to describe. These ids were computed live from the current working-tree contents by the two commands above, and were then cross-checked two ways:

```
git cat-file -t d4503c778bace2d206bbaa356101ee34481446fa   -> blob
git cat-file -t db025b9d50826c8ade88d38dd9a651afcaef66d4   -> blob
git rev-parse HEAD:.claude/hooks/enforce-powershell-batch-budget.ps1 \
              HEAD:extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 \
              HEAD:.claude/hooks/enforce-python-batch-budget.ps1 \
              HEAD:extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1
```

The `rev-parse` call returned the same four ids in the same order, which establishes that the working-tree contents are identical to the blobs recorded in the HEAD tree at `6ece95a9`. Neither file carries an uncommitted modification at baseline, consistent with the empty scoped diff recorded by [P0-T3].

## Scope note

The two pairs are enumerated here so [P4-T1] re-checks the same set and no selection is left to the executor. Both pairs, and only these two pairs, are in scope. `.claude/hooks/persist-session-id.ps1` and its mirror are explicitly out of scope for this remediation and are not measured here.

## Output Summary

Both `git hash-object` invocations exited 0. Pair 1 (`enforce-powershell-batch-budget.ps1` and its bundle mirror) both hash to `d4503c778bace2d206bbaa356101ee34481446fa`: equal. Pair 2 (`enforce-python-batch-budget.ps1` and its bundle mirror) both hash to `db025b9d50826c8ade88d38dd9a651afcaef66d4`: equal. Both mirrors are byte-identical to their source at baseline. All four ids cross-check against the HEAD tree at `6ece95a9`, so no id recorded here is stale. This is the before-state pair that [P1-T5] and [P2-T5] must move away from and that [P4-T1] re-checks.
