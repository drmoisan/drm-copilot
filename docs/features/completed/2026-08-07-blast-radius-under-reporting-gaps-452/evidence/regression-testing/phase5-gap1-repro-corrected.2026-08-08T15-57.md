# [P5-T8] Gap 1 reproduction — corrected in both languages

Timestamp: 2026-08-08T15-57
Task: [P5-T8]

Reproduction 1 from `spec.md` `## Repro & Evidence`, re-run against the corrected implementation
and contrasted against the [P0-T10] fail-before capture
(`phase0-failbefore-gap1.2026-08-08T10-42.md`).

Plan text used in both languages, byte-identical:

```
- [ ] [P1-T1] Touch `poetry.lock`.
```

## Python

Command:

```
poetry run python -c "from scripts.dev_tools._blast_radius_extraction import extract_plan_paths; p='- [ ] [P1-T1] Touch \`poetry.lock\`.'; print('after =', repr(extract_plan_paths(p, root_surfaces=('poetry.lock',)))); print('before=', repr(extract_plan_paths(p)))"
```

EXIT_CODE: 0

```
plan  = '- [ ] [P1-T1] Touch `poetry.lock`.'
after = ('poetry.lock',)
before= ()
```

## PowerShell

Command:

```
pwsh -NoProfile -File <scratch>/p5t8.ps1
```

where the script imports
`<worktree>/.claude/lib/blast-radius/BlastRadiusExtraction.psm1` and calls `Get-PlanPaths` twice
against the same plan text, once with `-RootSurface @('poetry.lock')` and once without.

EXIT_CODE: 0

```
plan   = - [ ] [P1-T1] Touch `poetry.lock`.
before = count=0 entries=[]
after  = count=1 entries=[poetry.lock]
```

## Output Summary

| Language | Call | [P0-T10] fail-before | This run | Verdict |
| --- | --- | --- | --- | --- |
| Python | `extract_plan_paths(plan, root_surfaces=("poetry.lock",))` | `()` | `('poetry.lock',)` | corrected |
| PowerShell | `Get-PlanPaths -PlanText $plan -RootSurface @('poetry.lock')` | no entry | count 1, entry `poetry.lock` | corrected |
| Python | `extract_plan_paths(plan)` (parameter omitted) | `()` | `()` | backward compatible |
| PowerShell | `Get-PlanPaths -PlanText $plan` (parameter omitted) | no entry | count 0 | backward compatible |

Reproduction 1 is corrected in both languages. With the configured root-surface set supplied,
Python returns a tuple containing `"poetry.lock"` and PowerShell returns the same single entry
`poetry.lock`, against the empty results recorded at [P0-T10]. With the parameter omitted both
languages still return nothing, so the pre-existing contract is unchanged for callers that do not
supply a configured surface set.
