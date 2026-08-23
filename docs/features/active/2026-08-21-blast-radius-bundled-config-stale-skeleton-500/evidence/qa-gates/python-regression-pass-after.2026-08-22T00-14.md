# Python regression, pass-after (Issue #500)

Timestamp: 2026-08-22T00:14:00Z
Issue: #500
Task: [P7-T3]

Pairs with the fail-before artifact
`evidence/regression-testing/python-regression-fail-before.2026-08-21T23-08.md`.

Command:

```
poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py
```

(working directory: worktree root; byte-identical to the fail-before command)

EXIT_CODE: 0
ExpectedExitCode: 0

Output Summary: `14 passed in 0.06s`. Zero failures. The fail-before run recorded exit code 1 with
exactly two failed tests; both now pass.

## Both regression tests named

| Node ID | Direction | Fail-before | Pass-after |
| --- | --- | --- | --- |
| `tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_unrelated_claude_citations_do_not_contend_under_the_bundled_table` | fail-closed | FAILED, `AssertionError: ... observed reasons (('module_overlap', 'claude-runtime'),).` | PASSED |
| `tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table` | fail-open | FAILED, `AssertionError: ... observed reasons ().` | PASSED |

The node IDs are byte-identical to those in the fail-before artifact. The [P6-T13] split moved only
constants and accessors into `tests/scripts/dev_tools/blast_radius_parity_test_support.py`, so every
assertion and every test identifier is unchanged.

The remaining twelve passing cases are the three-class gate and its supporting assertions, recorded
in `evidence/qa-gates/phase6-python-gate.2026-08-22T00-04.md`.
