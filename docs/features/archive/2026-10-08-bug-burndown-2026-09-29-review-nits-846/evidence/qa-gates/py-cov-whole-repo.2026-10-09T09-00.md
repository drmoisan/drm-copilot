# Final QC: whole-repository Python coverage ([P10-T8])

Timestamp: 2026-10-09T21-55
Loop-Iteration: 1
Command: poetry run pytest --cov --cov-branch --cov-report=term "--cov-report=json:artifacts/python/coverage.json"
EXIT_CODE: 0
Output Summary: "6731 passed, 6 skipped in 79.06s (0:01:19)". 0 failed, 0 deselected. The 6 skipped tests are the same 6 recorded in [P0-T15]. TOTAL row: 17571 statements, 1107 missed, 6342 branches, 511 partial, 92% combined. COVTOTAL: line 93.7, branch 87.97 (baseline 93.68 / 87.1). Coverage JSON written to artifacts/python/coverage.json.

## Pytest summary line (verbatim)

```
================= 6731 passed, 6 skipped in 79.06s (0:01:19) ==================
```

Skipped tests (6, verbatim reasons, unchanged from baseline):
- tests\scripts\dev_tools\test_blast_radius_regression_452.py:483: Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.
- tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_empty_frontmatter declares no accessor expectation.
- tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_missing_opening_fence declares no accessor expectation.
- tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_non_mapping_frontmatter declares no accessor expectation.
- tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_unterminated_fence declares no accessor expectation.
- tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_yaml_parse_failure declares no accessor expectation.

## TOTAL row (verbatim)

```
Name                                                                  Stmts   Miss Branch BrPart  Cover
TOTAL                                                                 17571   1107   6342    511    92%
```

## Block 2

Command: poetry run python -c "import json,sys;s=json.load(open(sys.argv[1]))['totals'];print('TOTAL line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2))" artifacts/python/coverage.json
EXIT_CODE: 0
Output Summary: `TOTAL line 93.7 branch 87.97`

Post-Total-Line: 93.7
Post-Total-Branch: 87.97
