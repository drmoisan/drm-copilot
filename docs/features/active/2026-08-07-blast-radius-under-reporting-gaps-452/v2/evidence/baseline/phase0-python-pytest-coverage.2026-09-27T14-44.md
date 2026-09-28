# Phase 0 Baseline — Pytest Repository-Wide Coverage (P0-T23)

Timestamp: 2026-09-27T14-44

Task start: 2026-09-27T14:38:22 (local)

Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json

EXIT_CODE: 0

Command: poetry run python `<scratchpad>`/coverage_totals.py

EXIT_CODE: 0

Pytest summary line:

```
====================== 5149 passed, 5 skipped in 23.05s =======================
TOTAL                                                               15841   1114   5760    573    91%
```

Skipped tests (short test summary, all five from one parametrized test):

```
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_empty_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_missing_opening_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_non_mapping_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_unterminated_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_yaml_parse_failure declares no accessor expectation.
```

Helper output:

```
GENERATED_AT=2026-09-27T14:38:41.185593
TOTAL_LINE=14727/15841=92.97
TOTAL_BRANCH=4935/5760=85.68
FILE _blast_radius_conflicts.py line=100.00 branch=100.00
FILE _blast_radius_extraction.py line=100.00 branch=100.00
FILE _blast_radius_glob.py line=98.28 branch=96.43
FILE _blast_radius_guards.py line=100.00 branch=100.00
FILE _blast_radius_mergeable.py line=96.43 branch=92.86
FILE _blast_radius_normalization.py line=100.00 branch=100.00
FILE _blast_radius_thresholds.py line=100.00 branch=100.00
FILE _blast_radius_token_shapes.py line=100.00 branch=100.00
FILE _blast_radius_validation.py line=100.00 branch=100.00
FILE compute_blast_radius.py line=100.00 branch=100.00
```

Output Summary:
- Collected 5154, passed 5149, failed 0, skipped 5, errors 0.
- Baseline failed node-ID set: empty.
- Baseline Python repository-wide line coverage: 92.97% (14727/15841).
- Baseline Python repository-wide branch coverage: 85.68% (4935/5760).
- GENERATED_AT 2026-09-27T14:38:41 is later than the task start 2026-09-27T14:38:22.
