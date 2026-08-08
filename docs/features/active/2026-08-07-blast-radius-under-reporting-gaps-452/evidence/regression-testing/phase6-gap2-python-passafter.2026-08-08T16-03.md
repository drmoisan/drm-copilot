# [P6-T8] Gap 2 Python pass-after — full scoped toolchain

Timestamp: 2026-08-08T16-03
Task: [P6-T8]

## Step 1 — Formatting

Command: `poetry run black .`

EXIT_CODE: 0

Output Summary: `All done! 361 files left unchanged.` Zero files reformatted, so the loop did not
restart.

## Step 2 — Linting

Command: `poetry run ruff check .`

EXIT_CODE: 0

Output Summary: `All checks passed!` Zero findings. No `# noqa` suppression was added anywhere in
the change set.

## Step 3 — Type checking

Command: `poetry run pyright`

EXIT_CODE: 0

Output Summary: `0 errors, 0 warnings, 0 informations`. No `# type: ignore` suppression was added
anywhere in the change set. The two lines of incidental output are a venv-path note and a
pyright-version availability notice, neither of which is a diagnostic.

## Step 4 — Testing with coverage

Command: `poetry run pytest tests/scripts/dev_tools/ --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary: `2784 passed in 10.20s`. Zero failures, zero errors, zero skips.

### Coverage for the five blast-radius Python modules

| Module | Stmts | Miss | Branch | BrPart | Cover | Phase 1 baseline |
| --- | --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_glob.py` | 58 | 1 | 28 | 1 | 98% | 98% (unchanged) |
| `scripts/dev_tools/_blast_radius_extraction.py` | 93 | 0 | 42 | 0 | 100% | 100% |
| `scripts/dev_tools/_blast_radius_validation.py` | 118 | 0 | 46 | 0 | 100% | 100% |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 58 | 0 | 22 | 0 | 100% | 100% |
| `scripts/dev_tools/compute_blast_radius.py` | 60 | 0 | 8 | 0 | 100% | 100% |

Scoped-run TOTAL: 90% line over 13370 statements, 4934 branches.

The single miss in `_blast_radius_glob.py` is line 222, the `return entry` fallback of
`_literal_prefix` reached only when an entry contains no wildcard at all. It is a pre-existing,
relocated line, uncovered at the same statement in the [P1-T9] pure-move baseline with the same
count of 1. No line added by [P6-T3], [P6-T4], or [P6-T5] is uncovered, so new/changed-code
coverage for this task is 100% line and 100% branch. No coverage regression against baseline.

### The [P6-T1] cases now pass

All thirteen previously-failing cases pass. `tests/scripts/dev_tools/test_blast_radius_conflicts.py`
reports `40 passed`, against `13 failed, 19 passed` at the [P6-T1] fail-before capture.

| Pair | Fail-before | Now |
| --- | --- | --- |
| `("scripts/dev_tools", "scripts/dev_tools/a.py")` | `False` | `True` |
| `("scripts/dev_tools/", "scripts/dev_tools/a.py")` | `False` | `True` |
| `("docs", "docs/features/active/x/spec.md")` | `False` | `True` |
| `("scripts/dev_tools", "scripts/dev_tools/**")` | `False` | `True` |
| `("scripts/dev_tools", "scripts/dev_tools/*.py")` | `False` | `True` |
| `("scripts/dev_tools", "scripts/*/a.py")` | `False` | `True` |

The six swapped-argument symmetry cases pass as well, confirming the correction is two-way.

### The [P6-T2] guards still pass

All four disjoint pairs, plus their four swapped-argument counterparts, still return `False`:
`("scripts/dev_tools", "scripts/dev_toolsX/a.py")`,
`("scripts/dev_tools/a.py", "scripts/dev_tools/b.py")`,
`("docs/features/active/alpha", "docs/features/active/beta/**")`, and
`("scripts/a.py", "tests/**")`.

### The five named pre-existing tests pass unmodified

Command: `poetry run pytest tests/scripts/dev_tools/ -q -k "test_distinct_concrete_paths_do_not_overlap or test_provably_disjoint_globs_do_not_conflict or test_is_path_subsumed_does_not_treat_a_sibling_prefix_as_a_directory or test_widening_a_radius_never_removes_a_conflict or test_widening_a_disjoint_radius_can_only_create_a_conflict"`

EXIT_CODE: 0 — `11 passed, 2773 deselected`. The count is 11 rather than 5 because two of the
named tests are parametrized. None of the five was modified by this plan.

Output Summary: black exit 0 with zero files reformatted; ruff exit 0 with zero findings; pyright
exit 0 with zero errors and zero warnings; pytest exit 0 with 2784 passed and zero failures. All
four commands passed in a single pass. The six [P6-T1] cases now return `True`, the four [P6-T2]
guards still return `False`, and the five named pre-existing tests pass without modification. The
five blast-radius modules sit at 98% to 100% line coverage with no regression against the Phase 1
baseline; every line added by this phase is covered.
