# Python Test and Coverage Baseline (#623)

Timestamp: 2026-09-30T08-26
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json; then NODE-PYCOV with no trailing arguments
EXIT_CODE: 0
Output Summary:
- Final summary line: `================= 5697 passed, 6 skipped in 91.60s (0:01:31) ==================`
- TOTAL row: `TOTAL                                                                 16937   1126   6106    584    91%`
- Baseline failure set P0F: empty (no failing nodes)
- KL-510: PASSED (tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts did not fail)
- scripts/dev_tools/potential_to_issue.py: lines=190/200 (line 95.00%); branches=54/66 (branch 81.82%)
- NODE-PYCOV TOTAL: lines=15811/16937 (93.35%); branches=5270/6106 (86.31%)

## Term-missing row for the module (verbatim)

```
scripts\dev_tools\potential_to_issue.py                                 200     10     66     12    92%   81->exit, 83->exit, 85->exit, 87->exit, 216->exit, 218->exit, 220->exit, 222->exit, 224->exit, 226->exit, 228->exit, 255, 258, 261, 264, 267-268, 271, 274-275, 500
```

## NODE-PYCOV output (verbatim)

```
scripts/dev_tools/potential_to_issue.py lines=190/200 branches=54/66
TOTAL lines=15811/16937 branches=5270/6106
```

## Short test summary (verbatim)

```
SKIPPED [1] tests\scripts\dev_tools\test_blast_radius_regression_452.py:483: Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_empty_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_missing_opening_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_non_mapping_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_unterminated_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_yaml_parse_failure declares no accessor expectation.
================= 5697 passed, 6 skipped in 91.60s (0:01:31) ==================
```

P0F: (empty)
