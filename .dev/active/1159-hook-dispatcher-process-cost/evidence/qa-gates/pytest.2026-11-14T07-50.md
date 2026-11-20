# Pytest gate — main-sync cycle 1 ([P1-T10])

Timestamp: 2026-11-14T07-50
Command: sh SCRATCH/issue-1159-pytest.sh (env -u VIRTUAL_ENV poetry run pytest -n auto -p no:cacheprovider --cov --cov-branch --cov-report=term:skip-covered --cov-report=json:artifacts/python/coverage-final.json -rf -q, run from the worktree root; line and branch totals read from the JSON report)
EXIT_CODE: 0
Output Summary: 16723 passed, 6 skipped, 0 failed in 227.91s (pytest-xdist, -n auto). Repo-wide line coverage: 97.13% (34574 of 35595 statements), against 97.11% (34334 of 35355) at the approved [P0-T6] baseline (evidence/baseline/pytest.2026-11-11T04-11.md). Branch coverage: 94.42% (12785 of 13540 branches; 555 partial), against 94.37% (12668 of 13424) at baseline. No line or branch drop. Combined term TOTAL is 96% (baseline 96%). The push-down contract tests named in the execution-environment brief's '## Contract Tests That Pin Mirrored Files' are in the run, and the run has 0 failures and 0 errors.
