# Python Full-Suite Coverage Baseline (P0-T19)

Timestamp: 2026-10-13T00-13
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/scratch-903/py-coverage-baseline-903.json" -q
EXIT_CODE: 0
BASE: fd81a43b45de65078236da6c1cbfd077c3eb010c

Run from `<worktree>`; stdout and stderr were captured to the scratch file `artifacts/scratch-903/py-pytest-full-baseline-903.txt` (not committed). Platform win32, Python 3.13.12.

## Pytest summary line

```
7065 passed, 6 skipped in 87.07s (0:01:27)
```

- Passed: 7065
- Failed: 0
- Skipped: 6
- Errors: 0

## TOTAL row

```
Name     Stmts   Miss Branch BrPart  Cover
TOTAL    17636   1094   6366    505    92%
```

## Skipped tests (pre-existing)

```
SKIPPED [1] tests\scripts\dev_tools\test_blast_radius_regression_452.py:483: Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_empty_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_missing_opening_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_non_mapping_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_unterminated_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_yaml_parse_failure declares no accessor expectation.
```

## Failing tests

None (0 failed, 0 errors).

## Row for the one production Python module this plan changes

```
scripts\dev_tools\_blast_radius_token_shapes.py    25    0    8    0   100%
```

Output Summary: PASS. 7065 passed, 0 failed, 6 skipped. TOTAL 17636 statements, 1094 missed, 6366 branches, 505 partial, 92% combined cover. Coverage JSON written to `artifacts/scratch-903/py-coverage-baseline-903.json` for P0-T20. No pre-existing failures.
