# pytest final gate, remediation (P4-T3)

Timestamp: 2026-11-08T15-59
Command: poetry run pytest -n auto --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/pytest-cov-p4t3.json --junitxml=SCRATCH/pytest-junit-p4t3.xml -q -p no:cacheprovider (via sh launcher SCRATCH/run-pytest.sh; one run after the last tree change)
EXIT_CODE: 0
Output Summary: 16537 passed, 6 skipped, 0 failed in 154.97s (Phase 0 baseline: 16537 passed, 6 skipped, 0 failed). The push-down resource, pack-manifest completeness, and dependency-closure contract tests are within the run and passed. scripts.dev_tools coverage from the JSON totals: lines 93.58% (16738 of 17653), branches 90.17% (5787 of 6418), terminal combined 94%; equal to the Phase 0 baseline (93.58%, 90.17%, 94%), so no drop.
