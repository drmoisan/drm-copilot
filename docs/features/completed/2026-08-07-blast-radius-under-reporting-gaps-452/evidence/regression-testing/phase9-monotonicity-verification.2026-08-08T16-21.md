# [P9-T3] Monotonicity verification — post-change truth table against the [P0-T14] baseline

Timestamp: 2026-08-08T16-21
Task: [P9-T3]

The fail-closed hard constraint is `O_old ⊆ O_new`: no pair the pre-change relation reported as
overlapping may now be reported as disjoint. A single `True` -> `False` transition fails this task.

## Commands

Python:

```
PYTHONPATH=<worktree> poetry run python <scratchpad>/truth_table_py.py
```

The script imports `_entries_overlap` from `scripts.dev_tools._blast_radius_glob`, its post-split
home. `PYTHONPATH` is pinned to the worktree so the run cannot resolve the parent checkout.

PowerShell:

```
pwsh -NoProfile -File <scratchpad>/truth_table_ps.ps1
```

The script imports `<worktree>/.claude/lib/blast-radius/BlastRadiusGlob.psm1` and calls
`Test-EntryOverlap -EntryA <a> -EntryB <b>`.

EXIT_CODE: 0 (both)

## Output Summary — fifteen rows, pre-change against post-change, both languages

| # | Entry A | Entry B | Pre ([P0-T14]) | Post (Python) | Post (PowerShell) | Transition |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | `scripts/dev_tools` | `scripts/dev_tools/a.py` | False | True | True | False -> True |
| 2 | `scripts/dev_tools/` | `scripts/dev_tools/a.py` | False | True | True | False -> True |
| 3 | `docs` | `docs/features/active/x/spec.md` | False | True | True | False -> True |
| 4 | `scripts/dev_tools` | `scripts/dev_tools/**` | False | True | True | False -> True |
| 5 | `scripts/dev_tools` | `scripts/dev_tools/*.py` | False | True | True | False -> True |
| 6 | `scripts/dev_tools` | `scripts/*/a.py` | False | True | True | False -> True |
| 7 | `config/blast-radius.json` | `config/*.yml` | False | True | True | False -> True |
| 8 | `scripts/dev_tools` | `scripts/dev_toolsX/a.py` | False | False | False | unchanged |
| 9 | `scripts/dev_tools/a.py` | `scripts/dev_tools/b.py` | False | False | False | unchanged |
| 10 | `docs/features/active/alpha` | `docs/features/active/beta/**` | False | False | False | unchanged |
| 11 | `scripts/a.py` | `tests/**` | False | False | False | unchanged |
| 12 | `scripts/dev_tools` | `scripts/**` | True | True | True | unchanged |
| 13 | `scripts/dev_tools/**` | `scripts/dev_tools/compute_blast_radius.py` | True | True | True | unchanged |
| 14 | `shared.py` | `shared.py` | True | True | True | unchanged |
| 15 | `scripts/*/alpha.py` | `scripts/*/beta.py` | True | True | True | unchanged |

## Verdict

- Rows evaluated: 15 of 15, in both languages.
- Two-language agreement: 15 of 15. Zero divergence.
- `True` -> `False` transitions: **0**. The monotonicity constraint holds.
- `False` -> `True` transitions: 7 (rows 1-7), exactly the strict-superset witnesses at
  `spec.md` lines 355-361.
- `O_old` = {12, 13, 14, 15}; `O_new` = {1, 2, 3, 4, 5, 6, 7, 12, 13, 14, 15}.
  `O_old ⊆ O_new` holds, and `O_old ⊊ O_new` is witnessed by all seven of rows 1-7, so the
  corrected relation is a strict superset rather than merely equal.
- Rows 8-11, the regression guards, are unchanged at `False` in both languages.
- Row 15 represents the `any glob×glob pair` class at `spec.md` line 371 and is unchanged,
  consistent with the byte-identity findings at [P6-T6] and [P7-T5].

Output Summary: the fifteen-row table was recomputed in both languages against the corrected
relation. No pair moved from `True` to `False` in either language, so the fail-closed monotonicity
constraint `O_old ⊆ O_new` is satisfied. Seven pairs moved from `False` to `True`, making the new
overlap set a strict superset of the old one. The two languages agree on all fifteen rows.
