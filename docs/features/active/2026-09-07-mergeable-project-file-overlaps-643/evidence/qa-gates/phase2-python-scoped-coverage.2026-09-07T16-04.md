# Phase 2 gate — scoped Python coverage (issue #643, task [P2-T6])

- Timestamp: 2026-09-07T16:04Z
- Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py tests/scripts/dev_tools/test_blast_radius_conflicts.py tests/scripts/dev_tools/test_blast_radius_parity.py --cov=scripts.dev_tools._blast_radius_mergeable --cov=scripts.dev_tools._blast_radius_conflicts --cov-branch --cov-report=term-missing` (run from the worktree root)
- EXIT_CODE: 0

## Output Summary

`138 passed in 0.50s`.

The two coverage table rows, verbatim:

```text
scripts\dev_tools\_blast_radius_conflicts.py      62      0     22      0   100%
scripts\dev_tools\_blast_radius_mergeable.py      28      1     14      1    95%   122
```

- Row ending with `_blast_radius_mergeable.py`: `Cover` is **95%**, at or above the 90% bound.
- Row ending with `_blast_radius_conflicts.py`: `Cover` is **100%**, at or above the 90% bound.

The `Missing` column is recorded verbatim above and carries no acceptance condition, because an
empty `Missing` column co-holds with a percentage bound only at 100%.

For reference the run also printed:

```text
TOTAL                                             90      1     36      1    98%
```
