# Fail-Before — Python Regression Gate (issue #472)

Timestamp: 2026-08-15T11-05

Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py` (working directory: repo root)

EXIT_CODE: 1

Output Summary:

```
======================== 3 failed, 36 passed in 0.10s =========================
```

## Failing tests (expected red against the pre-fix committed map)

| Test | Task | Failure |
| --- | --- | --- |
| `test_disjoint_items_do_not_contend_through_the_committed_map` | P1-T1 | `AssertionError: Two items with disjoint production paths must not contend; observed reasons (('module_overlap', 'docs'),).` |
| `test_no_committed_copy_declares_a_location_bucket_module[config/blast-radius.json-path0]` | P1-T3 | `AssertionError: config/blast-radius.json must not declare module 'docs'.` |
| `test_no_committed_copy_declares_a_location_bucket_module[extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json-path1]` | P1-T3 | `AssertionError: extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json must not declare module 'docs'.` |

The P1-T1 failure names the defect precisely: the two work items have disjoint
production paths and distinct feature folders, yet the committed map forces a
`module_overlap` reason whose detail is the location bucket `docs`. That single
false conflict edge is what serializes an otherwise parallel run.

## Passing tests (P1-T2 behavior-preservation matrix, asserted inclusively)

Verified with `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py -v`:

```
test_items_sharing_a_dev_tools_file_contend_on_path_and_module PASSED
test_items_sharing_only_a_test_file_contend_on_the_path_level  PASSED
test_items_sharing_the_truth_table_contend_on_three_levels     PASSED
```

All three matrix tests pass against the pre-fix committed config, as required by
the P1-T2 acceptance clause. They are asserted inclusively so they also hold
after the P2 config correction; their pass-after state is captured by P2-T4.

## Fail-before / pass-after pairing

- Fail-before (this artifact): `EXIT_CODE: 1`, three failures.
- Pass-after: `evidence/regression-testing/pass-after-pytest.<ISO-8601>.md`, captured at P2-T4.

This red state is planned and evidenced per plan binding constraint 6; it is
resolved by the Phase 2 configuration correction and is not silenced by
weakening any assertion.
