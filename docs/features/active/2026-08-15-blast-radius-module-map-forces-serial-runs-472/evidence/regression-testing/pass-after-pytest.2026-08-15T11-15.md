# Pass-After — Python Regression Gate (issue #472)

Timestamp: 2026-08-15T11-15

Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py` (working directory: repo root)

EXIT_CODE: 0

Output Summary:

```
collected 37 items
tests\scripts\dev_tools\test_blast_radius_config.py .................... [ 54%]
.................                                                        [100%]
============================= 37 passed in 0.12s ==============================
```

All 37 tests pass after the [P2-T1] and [P2-T2] configuration corrections.

## Gate tests verified individually

Verified with `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py -v`:

| Test | Task | Result |
| --- | --- | --- |
| `test_disjoint_items_do_not_contend_through_the_committed_map` | P1-T1 (AC3) | PASSED |
| `test_items_sharing_a_dev_tools_file_contend_on_path_and_module` | P1-T2 (AC4) | PASSED |
| `test_items_sharing_only_a_test_file_contend_on_the_path_level` | P1-T2 (AC5) | PASSED |
| `test_items_sharing_the_truth_table_contend_on_three_levels` | P1-T2 (AC6) | PASSED |
| `test_no_committed_copy_declares_a_location_bucket_module[config/blast-radius.json-path0]` | P1-T3 (AC7) | PASSED |
| `test_no_committed_copy_declares_a_location_bucket_module[extensions/.../blast-radius.json-path1]` | P1-T3 (AC7) | PASSED |

## Collected-count change is the predicted parametrization shrink

The fail-before run collected 39 items (36 passed, 3 failed); this run collects
37. The difference of exactly two is the pre-existing
`test_every_module_maps_to_a_non_empty_glob_list` parametrization, which is
generated from the committed module map and therefore shrinks by the two removed
modules with no amendment to the test. This is the behavior the plan predicted
for [P2-T4] and is not a lost assertion.

## Fail-before / pass-after pairing

- Fail-before: `evidence/regression-testing/fail-before-pytest.2026-08-15T11-05.md` (`EXIT_CODE: 1`, three failures).
- Pass-after (this artifact): `EXIT_CODE: 0`, zero failures.

The gate demonstrably distinguishes the defective committed map from the
corrected one, satisfying AC3 through AC7.
