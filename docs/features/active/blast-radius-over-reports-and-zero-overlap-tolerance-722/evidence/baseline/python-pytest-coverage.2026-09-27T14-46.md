# Python Coverage Baseline (P0-T18)

Timestamp: 2026-09-27T14-46
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/coverage-722-baseline.json ; poetry run python SCRATCH/py-cov-files.py SCRATCH/coverage-722-baseline.json scripts/dev_tools/compute_blast_radius.py scripts/dev_tools/_blast_radius_validation.py scripts/dev_tools/parallel_drift_detection.py
EXIT_CODE: 0
Output Summary: pytest exited 0 with 5149 passed, 0 failed, 5 skipped. Terminal-table TOTAL line percentage: 91% (15841 statements, 1114 missed, 5760 branches, 573 partial). Baseline FAILED node-ID set: empty. Per-file coverage: compute_blast_radius.py LinePercent=100.00 BranchPercent=100.00; _blast_radius_validation.py LinePercent=100.00 BranchPercent=100.00; parallel_drift_detection.py LinePercent=100.00 BranchPercent=100.00.

## Counts

| Metric | Value |
| --- | --- |
| passed | 5149 |
| failed | 0 |
| skipped | 5 |
| TOTAL line (terminal table) | 91% |

## TOTAL line and summary (verbatim)

```text
TOTAL                                                               15841   1114   5760    573    91%
====================== 5149 passed, 5 skipped in 22.56s =======================
```

## Baseline FAILED node IDs

None. The short test summary lists only the five SKIPPED entries below; no line begins "FAILED".

```text
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_empty_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_missing_opening_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_non_mapping_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_unterminated_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_yaml_parse_failure declares no accessor expectation.
```

## Per-file coverage (script A7 output, exit 0)

```text
COVERAGE file=scripts/dev_tools/compute_blast_radius.py LinePercent=100.00 BranchPercent=100.00
COVERAGE file=scripts/dev_tools/_blast_radius_validation.py LinePercent=100.00 BranchPercent=100.00
COVERAGE file=scripts/dev_tools/parallel_drift_detection.py LinePercent=100.00 BranchPercent=100.00
```

## Execution note

A first launch of this task appended two flags (quiet output and a cache-provider disable) that the
catalogue command does not carry. That run was stopped before its result was used, and the exact
catalogue command above was re-run; only the re-run's output is recorded here.
