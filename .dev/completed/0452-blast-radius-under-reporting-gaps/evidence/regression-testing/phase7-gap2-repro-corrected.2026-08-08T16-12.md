# [P7-T9] Gap 2 reproduction — corrected in both languages

Timestamp: 2026-08-08T16-12
Task: [P7-T9]

Reproduction 2 from `spec.md` `## Repro & Evidence`, re-run against the corrected relation and
contrasted against the [P0-T11] fail-before capture
(`phase0-failbefore-gap2.2026-08-08T10-42.md`).

## Python

Command:

```
poetry run python -c "from scripts.dev_tools._blast_radius_glob import _entries_overlap, is_path_subsumed; print(_entries_overlap('scripts/dev_tools','scripts/dev_tools/**')); print(is_path_subsumed('scripts/dev_tools/x.py',['scripts/dev_tools']))"
```

EXIT_CODE: 0

```
_entries_overlap("scripts/dev_tools", "scripts/dev_tools/**") = True
is_path_subsumed("scripts/dev_tools/x.py", ["scripts/dev_tools"]) = True
```

`_entries_overlap` is imported from `scripts.dev_tools._blast_radius_glob`, its post-split home
established at [P1-T3]; the spec cites its pre-split location in
`scripts/dev_tools/_blast_radius_conflicts.py`.

## PowerShell

Command:

```
pwsh -NoProfile -Command "Import-Module ./.claude/lib/blast-radius/BlastRadiusGlob.psm1 -Force; Test-EntryOverlap -EntryA 'scripts/dev_tools' -EntryB 'scripts/dev_tools/**'; Test-PathSubsumed -Path 'scripts/dev_tools/x.py' -CoveringPath @('scripts/dev_tools')"
```

EXIT_CODE: 0

```
Test-EntryOverlap scripts/dev_tools ~ scripts/dev_tools/** = True
Test-PathSubsumed = True
```

## Output Summary

| Call | [P0-T11] fail-before | This run | Verdict |
| --- | --- | --- | --- |
| Python `_entries_overlap("scripts/dev_tools", "scripts/dev_tools/**")` | `False` | `True` | corrected |
| PowerShell `Test-EntryOverlap -EntryA 'scripts/dev_tools' -EntryB 'scripts/dev_tools/**'` | `$false` | `$true` | corrected |
| Python `is_path_subsumed("scripts/dev_tools/x.py", ["scripts/dev_tools"])` | `True` | `True` | unchanged, as required |
| PowerShell `Test-PathSubsumed` for the analogous inputs | `$true` | `$true` | unchanged, as required |

Reproduction 2 is corrected in both languages. The divergence the issue reported — the contention
relation calling a listed directory and a glob beneath it disjoint while the subsumption helper
called a file under that directory covered — is closed: both predicates now agree, and the
subsumption helper is unmodified apart from its relocation ([P6-T7], [P7-T5]).
