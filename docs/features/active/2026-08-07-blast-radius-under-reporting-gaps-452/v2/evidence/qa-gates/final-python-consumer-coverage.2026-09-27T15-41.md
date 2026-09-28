# Final QA — Consumer-Only Coverage (P6-T7)

Timestamp: 2026-09-27T15-41

Iteration: 1

Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_regression_452.py --cov=scripts.dev_tools._blast_radius_conflicts --cov=scripts.dev_tools._blast_radius_glob --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_validation --cov=scripts.dev_tools.compute_blast_radius --cov-branch --cov-report=term-missing

EXIT_CODE: 0

Output (coverage table and summary):

```
collected 26 items

Name                                            Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------
scripts\dev_tools\_blast_radius_conflicts.py       62      4     22      3    92%   98, 133, 140, 157
scripts\dev_tools\_blast_radius_extraction.py     101     38     46      5    54%   197-203, 237, 298, 306-341, 445-473
scripts\dev_tools\_blast_radius_glob.py            58     11     28      2    73%   113, 163-176, 222
scripts\dev_tools\_blast_radius_validation.py     101     37     32      3    56%   105-112, 224, 260, 288->287, 321-346, 363-375, 396-417, 440-454
scripts\dev_tools\compute_blast_radius.py          72     14     10      4    76%   165, 176, 206, 209, 330-356, 392-394, 420
-------------------------------------------------------------------------------------------
TOTAL                                             394    104    138     17    67%
SKIPPED [1] tests\scripts\dev_tools\test_blast_radius_regression_452.py:483: Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.
======================== 25 passed, 1 skipped in 0.22s ========================
```

Acceptance evaluation:

| Criterion | Required | Observed | Result |
| --- | --- | --- | --- |
| EXIT_CODE | 0 | 0 | pass |
| Summary | "25 passed, 1 skipped" (branch NOT FOUND) | 25 passed, 1 skipped | pass |
| Table lists the five modules with numeric Stmts and Miss | yes | yes (informational; no threshold for a single-file run) | pass |

Output Summary: PASS. 25 passed, 1 skipped. Informational consumer-only coverage (Stmts/Miss/Cover): _blast_radius_conflicts 62/4/92%; _blast_radius_extraction 101/38/54%; _blast_radius_glob 58/11/73%; _blast_radius_validation 101/37/56%; compute_blast_radius 72/14/76%; total 394/104/67%.
