# [P0-T7] Before-state search for `(Get-Location).Path`

Timestamp: 2026-08-29T20-36

Command: `git grep -c -F "(Get-Location).Path" -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`

EXIT_CODE: 0

Output Summary: The search matched in all four in-scope files and produced exactly four output
lines, one per pathspec, each reporting a count of `1`. This is the before-state half of the
acceptance criterion at `spec.md:725` and is what makes the [P6-T2] after-state search falsifiable:
the literal is present once per file today, so a later exit of 1 with no output records the removal
rather than an absence that was always true.

## Verbatim output

```
.claude/hooks/enforce-powershell-batch-budget.ps1:1
.claude/hooks/enforce-python-batch-budget.ps1:1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1:1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1:1
```

## Per-pathspec counts

| Pathspec | Count |
| --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 1 |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` | 1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1` | 1 |

Four lines, each reporting `1`, matching the acceptance condition exactly. The single occurrence per
file is the `$Root` parameter default on the hook entry function.

## Scope note

Only the first of the three literals that [P6-T2] searches is measured here.
[P6-T2] additionally searches `Resolve-Path` and `[System.IO.Path]::GetFullPath`, which the plan
records as already absent at baseline; those two are guards against an introduction rather than
proofs of a removal and have no before-state count in this artifact.
