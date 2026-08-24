# [P1-T2] Behavior-Preserving Compaction of `parallel_mutation_protocol.py`

Timestamp: 2026-08-17T00-20

Command:
```
grep -c '' scripts/dev_tools/parallel_mutation_protocol.py
poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_recolor.py -q
poetry run black --check .
poetry run ruff check .
poetry run pyright
```

EXIT_CODE: 0 (all five)

## Output Summary

- Line count before: **499**. Line count after: **479** (target was `<= 480`). Twenty lines removed.
- `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_recolor.py -q` -> `13 passed in 0.05s`, with **zero test-file edits** (`git diff --stat -- tests/` reported nothing).
- `poetry run black --check .` -> `415 files would be left unchanged` (exit 0).
- `poetry run ruff check .` -> `All checks passed!` (exit 0).
- `poetry run pyright` -> `0 errors, 0 warnings, 0 informations` (exit 0).

## What was condensed (prose only; no function, class, or mandated docstring section removed)

All twenty lines came from narrative prose inside `recolor_unstarted`'s docstring and body
comments. No signature, no statement, no `Args:`/`Returns:`/`Raises:` section, and no
parameter entry was deleted; each retained section was tightened in wording only.

| Region | Before | After | Saved |
|---|---|---|---|
| "pinning guarantee has two parts" narrative | 12 | 5 | 7 |
| "Coloring is DELEGATED IN FULL" paragraph | 5 | 4 | 1 |
| Injectivity paragraph | 7 | 5 | 2 |
| `conflict_edges` + `pinned` `Args:` entries | 7 | 5 | 2 |
| `current_cohort` `Args:` entry (the global-barrier justification region, `:253-262`) | 10 | 8 | 2 |
| `Returns:` section | 9 | 7 | 2 |
| `Raises:` section | 7 | 6 | 1 |
| Negative-index body comment | 4 | 3 | 1 |
| "Decide the pinned barrier BEFORE" body comment | 3 | 3 | 0 |
| Induced-subgraph body comment | 5 | 3 | 2 |
| Pinned-offset body comment (`:321-323` region) | 6 | 4 | 2 |

## Dry accounting of [P1-T4]'s additions (required by the task acceptance)

`[P1-T4]` adds, at minimum:

1. One signature line: `    highest_pinned_cohort: int,` -> **+1**
2. One mandated `Args:` entry for `highest_pinned_cohort`
   (`.claude/rules/self-explanatory-code-commenting.md` requires every parameter to be
   documented with meaning and constraints) -> **+6** (estimated; a 6-line entry matching the
   density of the neighbouring `current_cohort` entry)
3. Rewritten offset comment above `cohort_offset` -> **+1** (net, from 4 to 5 lines)
4. Offset expression `:327` — one-line swap, `cohort_offset = highest_pinned_cohort + 1 if crosses_pinned else current_cohort` fits under the 88-character limit at 4-space indent -> **+0**
5. Summary-docstring and `Returns:` wording updates replacing `current_cohort + 1` /
   "strictly above `current_cohort`" with the `highest_pinned_cohort` formulation -> **+0** (net swaps)

Estimated total: **+8 lines**, within the plan's stated 8-12 range.

Headroom check: 479 + 12 (worst case) = **491 <= 500**. The remaining headroom fits P1-T4's
additions with at least 9 lines to spare. No later phase edits this file.
