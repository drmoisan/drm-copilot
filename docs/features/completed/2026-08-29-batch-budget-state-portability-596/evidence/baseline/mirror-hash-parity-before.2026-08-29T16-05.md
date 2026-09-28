# [P0-T8] Baseline mirror hash parity for the three hook pairs

Timestamp: 2026-08-29T20-37

Command: three commands, run in this order:

1. `git hash-object .claude/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`
2. `git hash-object .claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`
3. `git hash-object .claude/hooks/persist-session-id.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/persist-session-id.ps1`

EXIT_CODE: 0

All three commands exited 0.

Output Summary: All three repository-hook / bundle-mirror pairs are byte-identical at baseline: each
command printed two object ids that are equal to each other. Mirror parity therefore holds before
any edit this plan makes. These six object ids are the reference values that [P6-T3] compares
against; [P6-T3] additionally requires all three pairs to have *changed* from these ids, which is
what proves each pair was actually edited rather than left untouched.

## Pair A — `enforce-powershell-batch-budget.ps1`

Command exit code: 0

```
21945684a99501fe124f9b7f468451be825f6b29
21945684a99501fe124f9b7f468451be825f6b29
```

- `.claude/hooks/enforce-powershell-batch-budget.ps1` = `21945684a99501fe124f9b7f468451be825f6b29`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` = `21945684a99501fe124f9b7f468451be825f6b29`
- Equality result: **equal**.

## Pair B — `enforce-python-batch-budget.ps1`

Command exit code: 0

```
07a265fa22c088c47261a559e6f89991649b2c1f
07a265fa22c088c47261a559e6f89991649b2c1f
```

- `.claude/hooks/enforce-python-batch-budget.ps1` = `07a265fa22c088c47261a559e6f89991649b2c1f`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1` = `07a265fa22c088c47261a559e6f89991649b2c1f`
- Equality result: **equal**.

## Pair C — `persist-session-id.ps1`

Command exit code: 0

```
933b668e48ec4e74bdee472eac009562d3cdec5c
933b668e48ec4e74bdee472eac009562d3cdec5c
```

- `.claude/hooks/persist-session-id.ps1` = `933b668e48ec4e74bdee472eac009562d3cdec5c`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/persist-session-id.ps1` = `933b668e48ec4e74bdee472eac009562d3cdec5c`
- Equality result: **equal**.

## Summary of the three equality results

| Pair | Repository file id | Mirror id | Equal |
| --- | --- | --- | --- |
| A `enforce-powershell-batch-budget.ps1` | `21945684a99501fe124f9b7f468451be825f6b29` | `21945684a99501fe124f9b7f468451be825f6b29` | yes |
| B `enforce-python-batch-budget.ps1` | `07a265fa22c088c47261a559e6f89991649b2c1f` | `07a265fa22c088c47261a559e6f89991649b2c1f` | yes |
| C `persist-session-id.ps1` | `933b668e48ec4e74bdee472eac009562d3cdec5c` | `933b668e48ec4e74bdee472eac009562d3cdec5c` | yes |

Three pairs, three equalities, six object ids recorded verbatim. The ids were computed by
`git hash-object` against the working-tree files in this worktree at the time of the run; they are
not read from any prior artifact.
