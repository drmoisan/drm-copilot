# [P9-T4] Regression guards remain disjoint in both languages

Timestamp: 2026-08-08T16-21
Task: [P9-T4]

Widening the contention relation carries a specific risk: over-widening would make unrelated work
items contend and over-serialize the parallel schedule. These four pairs are the named guards at
`spec.md` lines 367-370 and `spec.md` line 650. Each must still return `False` / `$false`.

## Commands

Python:

```
PYTHONPATH=<worktree> poetry run python <scratchpad>/truth_table_py.py
```

PowerShell:

```
pwsh -NoProfile -File <scratchpad>/truth_table_ps.ps1
```

EXIT_CODE: 0 (both)

Both runs also execute as tests: `test_unrelated_entries_do_not_overlap` and
`test_the_entry_relation_is_symmetric_for_disjoint_pairs` in
`tests/scripts/dev_tools/test_blast_radius_conflicts.py` ([P6-T2]), and
`It 'reports no overlap for <EntryA> against <EntryB>'` in
`tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1` ([P7-T2]). Both test forms
assert each pair in both argument orders.

## Output Summary

| Pair | Python `_entries_overlap` | PowerShell `Test-EntryOverlap` | Disjoint | Why it must stay disjoint |
| --- | --- | --- | --- | --- |
| `("scripts/dev_tools", "scripts/dev_toolsX/a.py")` | `False` | `$false` | yes | anchoring on the trailing `/` stops a sibling whose name shares a character prefix |
| `("scripts/dev_tools/a.py", "scripts/dev_tools/b.py")` | `False` | `$false` | yes | neither peer file is a directory prefix of the other |
| `("docs/features/active/alpha", "docs/features/active/beta/**")` | `False` | `$false` | yes | the literal prefixes diverge below a common ancestor |
| `("scripts/a.py", "tests/**")` | `False` | `$false` | yes | the roots diverge |

All four pairs are disjoint in both languages, in both argument orders. Zero divergence between
the two implementations.

The first row is the load-bearing one: it is the guard that the anchored `entry.rstrip("/") + "/"`
rule (Python) and `$Entry.TrimEnd('/') + '/'` rule (PowerShell) exist to satisfy. Without the
anchor, `scripts/dev_tools` would appear to contain `scripts/dev_toolsX/a.py` by plain string
prefix. The dedicated parity fixture `conflict-sibling-prefix-disjoint.json` ([P8-T5]) pins the
same case at the corpus level in both languages.

Output Summary: all four named regression guards return `False` in Python and `$false` in
PowerShell, in both argument orders. The Gap 2 widening did not reach any of them.
