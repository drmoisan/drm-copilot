# Phase 0 — Gap 1 Fail-Before Reproduction (both languages)

Timestamp: 2026-08-08T10-42
Task: [P0-T10] [expect-fail]

A failing result is the expected and required outcome of this task. Both languages must exhibit
the defect before any Gap 1 fix lands.

## Command (Python)

```
poetry run python -c "
from scripts.dev_tools._blast_radius_extraction import extract_plan_paths, classify_path_token
plan = '- [ ] [P1-T1] Touch `poetry.lock`.'
print('extract_plan_paths:', repr(extract_plan_paths(plan)))
print('classify poetry.lock:', repr(classify_path_token('poetry.lock')))
print('classify package-lock.json:', repr(classify_path_token('package-lock.json')))
print('classify quality-tiers.yml:', repr(classify_path_token('quality-tiers.yml')))
"
```

EXIT_CODE: 0 (the interpreter ran successfully; the DEFECT is in the returned values, not in an
exception)

```
extract_plan_paths: ()
classify poetry.lock: None
classify package-lock.json: None
classify quality-tiers.yml: None
```

## Command (PowerShell)

```
pwsh -NoProfile -File <scratchpad>/repro-ps-baseline.ps1
```

with the script importing `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` and
`.claude/lib/blast-radius/BlastRadiusGlob.psm1` and calling `Get-PlanPaths -PlanText` on the same
plan text.

EXIT_CODE: 0

```
Get-PlanPaths count=0 value=[]
Get-PathTokenKind poetry.lock = $null
Get-PathTokenKind package-lock.json = $null
Get-PathTokenKind quality-tiers.yml = $null
```

## Root cause confirmed by source reading

- Python `scripts/dev_tools/_blast_radius_extraction.py:243` —
  `if "/" not in token or token.startswith("/"): return None`.
- PowerShell `.claude/lib/blast-radius/BlastRadiusExtraction.psm1:290-293` —
  `if ($separatorIndex -lt 0 -or $separatorIndex -eq 0) { return $null }`.

Each rejects a separator-free token before any other acceptance rule runs, so all three
configured separator-free `shared_surfaces` entries are unreachable from plan or spec text.

Output Summary: Gap 1 reproduces identically in both languages. Python `extract_plan_paths` on
the plan task line ``- [ ] [P1-T1] Touch `poetry.lock`.`` returns the empty tuple `()`, and
`classify_path_token` returns `None` for each of `poetry.lock`, `package-lock.json`, and
`quality-tiers.yml`. PowerShell `Get-PlanPaths` returns zero entries for the same plan text, and
`Get-PathTokenKind` returns `$null` for all three tokens. Expected post-fix results are a tuple
containing `"poetry.lock"` and the single PowerShell entry `poetry.lock`, recorded at [P5-T7].
