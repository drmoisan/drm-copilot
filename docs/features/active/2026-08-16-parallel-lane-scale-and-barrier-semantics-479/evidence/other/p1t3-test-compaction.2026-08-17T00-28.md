# [P1-T3] Behavior-Preserving Compaction of `test_parallel_mutation_protocol_properties.py`

Timestamp: 2026-08-17T00-28

Command:
```
poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py -q --collect-only
grep -c '' tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py
poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py -q
poetry run black --check .
poetry run ruff check .
```

EXIT_CODE: 0 (all five)

## Output Summary

- Collected-test count recorded IMMEDIATELY BEFORE the edit: **180 tests collected in 0.05s**.
- Line count before: **500** (at the ceiling). Line count after: **494** (target `<= 494`).
- Collected/passing count after the edit: **180 passed in 0.18s** — identical count, zero
  test functions, parametrize cases, property strategies, or assertions removed or weakened.
- `poetry run black --check .` -> `415 files would be left unchanged` (exit 0).
- `poetry run ruff check .` -> `All checks passed!` (exit 0).

## What was condensed (docstring and comment narrative only)

| Region | Before | After | Saved |
|---|---|---|---|
| Module docstring, opening paragraph + P1/P2 bullets + sibling-module note + Mechanism note | 27 | 22 | 5 |
| `GeneratedRun.__init__` body comments (partition, edge generation, item labelling) | 10 | 7 | 3 |
| Module-level constant comments (`SEEDS`, `MIN_ITEMS`/`MAX_ITEMS`, `START_GENERATION`) | 6 | 5 | 1 |
| `GeneratedRun.recolor` docstring wrapper note | 2 | 1 | 1 |
| `GeneratedRun` class docstring (rewrapped, net zero) | 5 | 5 | 0 |
| Net after intermediate re-wrapping to satisfy E501 | — | — | **6 total** |

One intermediate iteration widened three docstring lines past the 88-character limit and
`poetry run ruff check .` reported four `E501` findings. The lines were rewrapped and the
loop was re-run from formatting; the recorded results above are the final clean pass.

## Headroom for [P1-T4]

The four exploded `recolor_unstarted(` call sites are at lines **151**, **250**, **353**, and
**483** (confirmed by `grep -n "recolor_unstarted(" ...`). Each carries a magic trailing comma,
so black at line-length 88 keeps one argument per line and each site gains exactly one line for
`highest_pinned_cohort=`. Projected: 494 + 4 = **498 <= 500**.
