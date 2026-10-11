# Baseline: whole-repository Python coverage ([P0-T15])

Timestamp: 2026-10-09T21-00
Command: poetry run pytest --cov --cov-branch --cov-report=term "--cov-report=json:artifacts/python/coverage.json"
EXIT_CODE: 0
Output Summary: "6722 passed, 6 skipped in 76.99s (0:01:16)". 0 failed, 0 deselected (no failed or deselected count printed). TOTAL row: 17565 statements, 1110 missed, 6340 branches, 566 partial, 92% combined. COVTOTAL: line 93.68%, branch 87.1%. Coverage JSON written to artifacts/python/coverage.json. No pre-existing test failure.

## Pytest summary line (verbatim)

```
================= 6722 passed, 6 skipped in 76.99s (0:01:16) ==================
```

Skipped tests (6, verbatim reasons):
- tests\scripts\dev_tools\test_blast_radius_regression_452.py:483: Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.
- tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_empty_frontmatter declares no accessor expectation.
- tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_missing_opening_fence declares no accessor expectation.
- tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_non_mapping_frontmatter declares no accessor expectation.
- tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_unterminated_fence declares no accessor expectation.
- tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_yaml_parse_failure declares no accessor expectation.

## TOTAL row (verbatim)

```
Name                                                                  Stmts   Miss Branch BrPart  Cover
TOTAL                                                                 17565   1110   6340    566    92%
```

## Block 2

Command: poetry run python -c "import json,sys;s=json.load(open(sys.argv[1]))['totals'];print('TOTAL line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2))" artifacts/python/coverage.json
EXIT_CODE: 0
Output Summary: `TOTAL line 93.68 branch 87.1`

Baseline-Total-Line: 93.68
Baseline-Total-Branch: 87.1
