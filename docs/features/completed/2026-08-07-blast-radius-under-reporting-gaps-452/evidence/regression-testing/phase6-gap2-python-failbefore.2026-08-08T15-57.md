# [P6-T1] [expect-fail] Gap 2 Python fail-before — direct `_entries_overlap` coverage

Timestamp: 2026-08-08T15-57
Task: [P6-T1]

Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_conflicts.py -q`

EXIT_CODE: 1

`_entries_overlap` is imported from `scripts.dev_tools._blast_radius_glob`, its post-split home
established at [P1-T3]. Before issue #452 no Python test exercised the entry-level relation
directly; it was reachable only through `conflicts`, which is why the Gap 2 under-reporting was
invisible to the Python suite.

## Output Summary

`13 failed, 19 passed in 0.10s`. All 19 pre-existing tests in the file continue to pass; every
one of the 13 failures is a newly added case failing against the unmodified relation, which is
the expected `[expect-fail]` outcome.

The six required cases, all asserting `True` and all failing:

| # | `entry_a` | `entry_b` | Expected | Actual |
| --- | --- | --- | --- | --- |
| 1 | `scripts/dev_tools` | `scripts/dev_tools/a.py` | `True` | `False` |
| 2 | `scripts/dev_tools/` | `scripts/dev_tools/a.py` | `True` | `False` |
| 3 | `docs` | `docs/features/active/x/spec.md` | `True` | `False` |
| 4 | `scripts/dev_tools` | `scripts/dev_tools/**` | `True` | `False` |
| 5 | `scripts/dev_tools` | `scripts/dev_tools/*.py` | `True` | `False` |
| 6 | `scripts/dev_tools` | `scripts/*/a.py` | `True` | `False` |

Cases 1 through 3 exercise the concrete-by-concrete branch; cases 4 through 6 exercise the mixed
concrete-by-glob branches, with case 6 requiring the two-way literal-prefix nest.

Failing node IDs:

```
test_a_listed_directory_overlaps_what_lies_beneath_it[scripts/dev_tools-scripts/dev_tools/a.py]
test_a_listed_directory_overlaps_what_lies_beneath_it[scripts/dev_tools/-scripts/dev_tools/a.py]
test_a_listed_directory_overlaps_what_lies_beneath_it[docs-docs/features/active/x/spec.md]
test_a_listed_directory_overlaps_what_lies_beneath_it[scripts/dev_tools-scripts/dev_tools/**]
test_a_listed_directory_overlaps_what_lies_beneath_it[scripts/dev_tools-scripts/dev_tools/*.py]
test_a_listed_directory_overlaps_what_lies_beneath_it[scripts/dev_tools-scripts/*/a.py]
test_the_entry_relation_is_symmetric_for_overlapping_pairs[... same six pairs, arguments swapped]
test_a_directory_entry_overlaps_a_file_beneath_it
```

The six symmetry cases re-evaluate the same pairs with the arguments swapped, proving the
correction must be two-way rather than one-directional.

`test_a_directory_entry_overlaps_a_file_beneath_it` is the Python counterpart of the Pester
assertion inverted at [P7-T1] (`spec.md` line 659). Its failure text:

```
>       assert _entries_overlap("scripts/dev_tools", "scripts/dev_tools/a.py") is True
E       AssertionError: assert False is True
E        +  where False = _entries_overlap('scripts/dev_tools', 'scripts/dev_tools/a.py')
```

Output Summary: 13 failed, 19 passed. All six required `True` cases fail against the unmodified
relation, plus their six swapped-argument symmetry counterparts and the dedicated Python
counterpart to the inverted Pester test. No pre-existing test in the file was modified or broken.
