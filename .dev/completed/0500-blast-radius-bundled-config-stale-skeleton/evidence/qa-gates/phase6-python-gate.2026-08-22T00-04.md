# Phase 6 Python drift gate (Issue #500)

Timestamp: 2026-08-22T00:04:00Z
Issue: #500
Task: [P6-T14]

Command:

```
poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py
```

(working directory: worktree root)

EXIT_CODE: 0

Output Summary:

```
collected 14 items
tests\scripts\dev_tools\test_blast_radius_config_parity.py ............. [ 92%]
.                                                                        [100%]

14 passed in 0.08s
```

- passed: **14**
- failed: **0**

## The two Phase 1 regression tests now pass

Both tests added by [P1-T1] and [P1-T2], which failed before the fix and are recorded failing at
`evidence/regression-testing/python-regression-fail-before.2026-08-21T23-08.md`, now pass:

| Node ID | Direction | Fail-before | Now |
| --- | --- | --- | --- |
| `test_blast_radius_config_parity.py::test_unrelated_claude_citations_do_not_contend_under_the_bundled_table` | fail-closed | FAILED with `module_overlap : claude-runtime` | PASSED |
| `test_blast_radius_config_parity.py::test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table` | fail-open | FAILED with an empty reason collection | PASSED |

The node IDs are byte-identical to those recorded in the fail-before artifact, because the [P6-T13]
split moved only constants and accessors and left every assertion in place.

## The twelve gate cases

| Case | Class |
| --- | --- |
| `test_class_one_keys_are_equal_across_both_committed_copies[version]` | 1 |
| `test_class_one_keys_are_equal_across_both_committed_copies[over_breadth_fraction]` | 1 |
| `test_class_one_keys_are_equal_across_both_committed_copies[mandate_reads]` | 1 |
| `test_class_two_bundled_shared_surfaces_are_the_portable_set` | 2 |
| `test_class_two_bundled_shared_surface_globs_are_empty` | 2 |
| `test_class_three_bundled_modules_are_payload_modules_only` | 3 |
| `test_no_committed_copy_declares_an_umbrella_module[config/blast-radius.json-path0]` | denylist |
| `test_no_committed_copy_declares_an_umbrella_module[extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json-path1]` | denylist |
| `test_every_separator_free_bundled_shared_surface_is_wildcard_free` | separator-free |
| `test_the_gate_compares_non_empty_collections` | non-vacuity floor |
| `test_every_committed_copy_parses_and_declares_schema_version_one[config/blast-radius.json-path0]` | parse and version |
| `test_every_committed_copy_parses_and_declares_schema_version_one[extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json-path1]` | parse and version |

The two parametrized cases confirm the gate is parametrized over exactly the two committed copies,
which the non-vacuity floor also asserts as `len(COMMITTED_CONFIGS) == 2`.

## Toolchain stages run for this module, in order

| Stage | Command | Exit code |
| --- | --- | --- |
| Format | `poetry run black tests/scripts/dev_tools/` | 0 |
| Lint | `poetry run ruff check tests/scripts/dev_tools/` | 0 |
| Type check | `poetry run pyright <the two modules>` | 0 |
| Test | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py` | 0 |

Two defects were resolved during the loop, neither by suppression. Ruff reported `S105` on a
constant whose name contained the substring `TOKEN`; it was resolved by renaming the constant to
`ROOT_SURFACE_FILENAME`. Pyright reported `reportUnknownVariableType` on two comprehension
variables; it was resolved with an explicit `cast("list[object]", value)`, matching the pattern
already used by `require_string_list` in `tests/scripts/dev_tools/test_blast_radius_config.py`. The
loop was restarted from formatting after each fix.
