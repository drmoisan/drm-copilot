# Phase 0 — Pre-Change Monotonicity Truth Table (both languages)

Timestamp: 2026-08-08T10-42
Task: [P0-T14]

This is the `O_old` reference set. The fail-closed hard constraint is `O_old ⊆ O_new`: no row
below whose pre-change verdict is `True` may become `False` after the Gap 2 correction. Phase 9
recomputes this exact table and diffs against it.

## Commands

Python:
`poetry run python <scratchpad>/truth_table_py.py`
The script resolves `_entries_overlap` from `scripts.dev_tools._blast_radius_glob` when that
module exists and falls back to `scripts.dev_tools._blast_radius_conflicts` otherwise, so the same
script is valid before and after the Phase 1 structural split. For this pre-change run it resolved
`scripts.dev_tools._blast_radius_conflicts`.

PowerShell:
`pwsh -NoProfile -File <scratchpad>/truth_table_ps.ps1`
The script imports `.claude/lib/blast-radius/BlastRadiusGlob.psm1` and calls
`Test-EntryOverlap -EntryA <a> -EntryB <b>`.

EXIT_CODE: 0 (both)

## Pair-set provenance

The fifteen pairs are exactly those named by [P0-T14]:

- Rows 1-7: the seven change-witness pairs at `spec.md` lines 355-361.
- Rows 8-11: the four regression-guard pairs at `spec.md` lines 367-370.
- Row 12: `("scripts/dev_tools", "scripts/**")` at `spec.md` line 372 — already `True` today and
  the single most important non-regression row.
- Rows 13-15: the three additional pairs named by the task.

`spec.md` line 371 (`any glob×glob pair`) names no concrete pair and is represented by row 15,
`("scripts/*/alpha.py", "scripts/*/beta.py")`.

## Output Summary — fifteen rows, pre-change verdicts, both languages

| # | Entry A | Entry B | Python | PowerShell | Agree | Role |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | `scripts/dev_tools` | `scripts/dev_tools/a.py` | False | False | yes | change witness |
| 2 | `scripts/dev_tools/` | `scripts/dev_tools/a.py` | False | False | yes | change witness |
| 3 | `docs` | `docs/features/active/x/spec.md` | False | False | yes | change witness |
| 4 | `scripts/dev_tools` | `scripts/dev_tools/**` | False | False | yes | change witness (issue repro) |
| 5 | `scripts/dev_tools` | `scripts/dev_tools/*.py` | False | False | yes | change witness |
| 6 | `scripts/dev_tools` | `scripts/*/a.py` | False | False | yes | change witness (two-way nest) |
| 7 | `config/blast-radius.json` | `config/*.yml` | False | False | yes | change witness (accepted over-report) |
| 8 | `scripts/dev_tools` | `scripts/dev_toolsX/a.py` | False | False | yes | regression guard |
| 9 | `scripts/dev_tools/a.py` | `scripts/dev_tools/b.py` | False | False | yes | regression guard |
| 10 | `docs/features/active/alpha` | `docs/features/active/beta/**` | False | False | yes | regression guard |
| 11 | `scripts/a.py` | `tests/**` | False | False | yes | regression guard |
| 12 | `scripts/dev_tools` | `scripts/**` | **True** | **True** | yes | must not regress |
| 13 | `scripts/dev_tools/**` | `scripts/dev_tools/compute_blast_radius.py` | **True** | **True** | yes | must not regress |
| 14 | `shared.py` | `shared.py` | **True** | **True** | yes | must not regress (equality) |
| 15 | `scripts/*/alpha.py` | `scripts/*/beta.py` | **True** | **True** | yes | must not regress (glob×glob) |

- Rows agreeing across the two languages: 15 of 15. Zero divergence.
- Pre-change `True` set (`O_old`): rows 12, 13, 14, 15.
- Pre-change `False` set: rows 1-11.
- Expected post-change transitions: rows 1-7 move `False` -> `True` (the strict-superset
  witnesses). Rows 8-11 must stay `False`. Rows 12-15 must stay `True`.

Output Summary: All fifteen pairs were evaluated in both languages. The two implementations agree
on every row, confirming pre-change two-language behavioural equivalence of the contention
relation. Four pairs are `True` before the change (rows 12-15) and constitute `O_old`; eleven are
`False`. A single `True` -> `False` transition in the Phase 9 recomputation is a fail-closed
regression and fails [P9-T3].
