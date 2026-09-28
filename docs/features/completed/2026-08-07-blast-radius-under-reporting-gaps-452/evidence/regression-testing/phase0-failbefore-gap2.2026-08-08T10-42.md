# Phase 0 — Gap 2 Fail-Before Reproduction (both languages)

Timestamp: 2026-08-08T10-42
Task: [P0-T11] [expect-fail]

A failing result is the expected and required outcome of this task. Both languages must exhibit
the asymmetry before any Gap 2 fix lands.

## Command (Python)

```
poetry run python -c "
from scripts.dev_tools._blast_radius_conflicts import _entries_overlap
from scripts.dev_tools._blast_radius_extraction import is_path_subsumed
print('entries_overlap dt/dt**:', _entries_overlap('scripts/dev_tools', 'scripts/dev_tools/**'))
print('is_path_subsumed:', is_path_subsumed('scripts/dev_tools/x.py', ['scripts/dev_tools']))
"
```

EXIT_CODE: 0 (the interpreter ran successfully; the DEFECT is in the returned values)

```
entries_overlap dt/dt**: False
is_path_subsumed: True
```

## Command (PowerShell)

```
pwsh -NoProfile -File <scratchpad>/repro-ps-baseline.ps1
```

importing `.claude/lib/blast-radius/BlastRadiusGlob.psm1`.

EXIT_CODE: 0

```
Test-EntryOverlap dt vs dt/** = False
Test-PathSubsumed = True
```

The PowerShell parameter name is `-CoveringPath`, so the exact invocation is
`Test-PathSubsumed -Path 'scripts/dev_tools/x.py' -CoveringPath @('scripts/dev_tools')`.

## The asymmetry, stated precisely

| Relation | Input | Result |
| --- | --- | --- |
| Python `_entries_overlap` | `("scripts/dev_tools", "scripts/dev_tools/**")` | `False` |
| PowerShell `Test-EntryOverlap` | `-EntryA 'scripts/dev_tools' -EntryB 'scripts/dev_tools/**'` | `$false` |
| Python `is_path_subsumed` | `("scripts/dev_tools/x.py", ["scripts/dev_tools"])` | `True` |
| PowerShell `Test-PathSubsumed` | `-Path 'scripts/dev_tools/x.py' -CoveringPath @('scripts/dev_tools')` | `$true` |

`is_path_subsumed` / `Test-PathSubsumed` treat a wildcard-free entry as a possible listed
directory and apply the anchored prefix rule `entry.rstrip("/") + "/"`. `_entries_overlap` /
`Test-EntryOverlap` apply no directory semantics at all: a wildcard-free entry participates only
in string equality (concrete branch) or as an `fnmatch` candidate (glob branch). Two relations
that must agree therefore disagree, which is the defect.

Root cause locations confirmed by source reading:
- `scripts/dev_tools/_blast_radius_conflicts.py:198-228`.
- `.claude/lib/blast-radius/BlastRadiusGlob.psm1:271-322`.

Output Summary: Gap 2 reproduces identically in both languages.
`_entries_overlap("scripts/dev_tools", "scripts/dev_tools/**")` returns `False` and
`Test-EntryOverlap -EntryA 'scripts/dev_tools' -EntryB 'scripts/dev_tools/**'` returns `$false`,
while `is_path_subsumed("scripts/dev_tools/x.py", ["scripts/dev_tools"])` returns `True` and
`Test-PathSubsumed` returns `$true` for the analogous inputs. The two relations that must agree
disagree in both languages. Expected post-fix results are `True` / `$true` for the overlap pair
with the subsumption results unchanged, recorded at [P7-T9].
