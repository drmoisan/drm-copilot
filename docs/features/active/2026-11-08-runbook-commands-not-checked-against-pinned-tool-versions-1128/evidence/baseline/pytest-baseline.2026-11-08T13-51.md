# pytest baseline (P0-T3)

Timestamp: 2026-11-08T13-51
Command: poetry run pytest -n auto --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/pytest-cov-base.json --junitxml=SCRATCH/pytest-junit-base.xml -q -p no:cacheprovider (via sh launcher SCRATCH/run-pytest.sh; one run before any change)
EXIT_CODE: 0
Output Summary: 16537 passed, 6 skipped, 0 failed in 271.92s. Coverage of scripts.dev_tools: total 94% (terminal combined column); from the JSON report totals line coverage 93.58% (16738 of 17653 statements), branch coverage 90.17% (5787 of 6418 branches).
