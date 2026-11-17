# Python Test Baseline (Remediation Cycle 1, P0-T2)

Timestamp: 2026-11-17T12-36
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov=scripts --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1035-cov-p0.json --junitxml=SCRATCH/issue-1035-junit-p0.xml -q (sh SCRATCH/issue-1035-pytest.sh p0; the launcher runs poetry run pytest -n auto over testpaths `tests` with the integration and golden lanes excluded; artifacts/python/lcov.info written through the project addopts). Figures read with SCRATCH/issue-1035-pyfig.py from the JSON report and the JUnit file.
EXIT_CODE: 0
Baseline-Head: 4ba9c6ab33076366b1d40e0ccb3d61142e1278d4
Output Summary: 17085 passed, 6 skipped, 0 failed, 0 errors (JUnit: 17091 tests) in 147.99 s. Repo-wide (`--cov=scripts`): line 96.24% (17649/18338), branch 92.07% (6161/6692). Run 2026-11-17T12-33-47 to 12-36-20 UTC; artifacts/python/lcov.info written 2026-11-17T12-36-12 UTC.

| Module | Line % | Branch % |
| --- | --- | --- |
| scripts.dev_tools.copy_research_to_issue | 50.00 (41/82) | 46.15 (12/26) |
| scripts.dev_tools.plan_progress_report | 82.35 (84/102) | 84.62 (22/26) |
| scripts.dev_tools.atomic_executor.cli | 89.07 (163/183) | 73.08 (38/52) |
