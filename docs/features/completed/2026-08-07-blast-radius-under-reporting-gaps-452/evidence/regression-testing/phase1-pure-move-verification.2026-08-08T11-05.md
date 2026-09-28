# Phase 1 — Python Pure-Move Verification (full toolchain)

Timestamp: 2026-08-08T11-05
Task: [P1-T9]

Command: `poetry run black .` then `poetry run ruff check .` then `poetry run pyright` then
`poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0, 0, 0, 0

## Stage results

| Stage | Command | EXIT_CODE | Result |
| --- | --- | ---: | --- |
| 1 Format | `poetry run black .` | 0 | `361 files left unchanged` (0 reformatted) |
| 2 Lint | `poetry run ruff check .` | 0 | `All checks passed!` — 0 findings |
| 3 Type-check | `poetry run pyright` | 0 | `0 errors, 0 warnings, 0 informations` |
| 4 Test | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 0 | `2835 passed` |

The file count rose from 360 to 361, which is exactly the one added module
`scripts/dev_tools/_blast_radius_glob.py`.

## Toolchain loop history

The loop required one restart. On the first pass, stage 3 reported two Pyright errors introduced
by the split:

```
_blast_radius_conflicts.py:31:50 - error: "_entries_overlap" is private and used outside of the module in which it is declared (reportPrivateUsage)
_blast_radius_glob.py:210:5 - error: Function "_entries_overlap" is not accessed (reportUnusedFunction)
```

Resolution: an `__all__` declaration was added to `scripts/dev_tools/_blast_radius_glob.py`
naming its seven package-internal exports, which states that `_literal_prefix` and
`_entries_overlap` are intentional exports of this helper module rather than private access. The
underscore names are retained because the spec's acceptance criterion at line 662 and the parity
corpus both name `_entries_overlap` and `_literal_prefix` literally. This is a declaration only:
no function body, signature, or call site changed, and no suppression (`# noqa` or
`# type: ignore`) was added. The loop then restarted from stage 1 and completed all four stages
cleanly in a single pass, which is the result recorded in the table above.

## Pure-move proof: test counts equal the P0-T6 baseline

| Metric | P0-T6 baseline | P1-T9 post-split | Delta |
| --- | ---: | ---: | ---: |
| Passed | 2835 | 2835 | 0 |
| Failed | 0 | 0 | 0 |
| Skipped | 0 | 0 | 0 |
| Errors | 0 | 0 | 0 |

Every one of the 2835 tests that passed before the split passes after it, with no test added,
removed, skipped, or modified in body. The only test-file edit in Phase 1 is the import-origin
redirect at `tests/scripts/dev_tools/test_blast_radius_extraction.py` required by [P1-T4].

## Per-file coverage after the split

| File | Cover | Statements | Branches |
| --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_extraction.py` | 100% | 91 | 40 |
| `scripts/dev_tools/_blast_radius_glob.py` | 98% | 54 (1 miss, line 222) | 28 (1 partial) |
| `scripts/dev_tools/_blast_radius_validation.py` | 100% | 115 | 46 |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 100% | 58 | 22 |
| `scripts/dev_tools/compute_blast_radius.py` | 100% | 59 | 8 |
| TOTAL (repository) | 90% combined | 13360 | 4932 |

The single uncovered line moved with its function: `_blast_radius_conflicts.py:195` was the one
uncovered statement at baseline, and after the move the same statement is
`_blast_radius_glob.py:222` inside the relocated `_entries_overlap`. `_blast_radius_conflicts.py`
correspondingly rises from 98% to 100%. Total statement count rose 13354 -> 13360 (+6), which is
the new module's `__all__` and import lines; total missed statements is unchanged at 1107 and
total branches unchanged at 4932, confirming no executable logic was added or removed.

Output Summary: All four commands exit 0. Black reformatted 0 files, Ruff reported 0 findings,
Pyright reported 0 errors / 0 warnings, and pytest reported 2835 passed / 0 failed / 0 skipped —
counts identical to the P0-T6 baseline of 2835 / 0 / 0. Total missed statements (1107) and total
branches (4932) are unchanged from baseline. The Phase 1 structural split is therefore a pure
move with zero behaviour change.
