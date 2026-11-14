# pytest Phase 0 Baseline (remediation cycle 2, P0-T4)

Timestamp: 2026-11-13T14-45
Command: sh SCRATCH/issue-1164-pytest-gate.sh issue-1164-cov-r2-baseline (in the item worktree: env -u VIRTUAL_ENV poetry run pytest tests/ -n auto -q -p no:cacheprovider --junitxml=SCRATCH/issue-1164-cov-r2-baseline.junit.xml --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1164-cov-r2-baseline.json --cov); figures read from the JSON report by SCRATCH/issue-1164-cov-json.js
EXIT_CODE: 0
Output Summary:
- Run on head 40a30508d; 2026-11-13T14-45-49 to 14-51-13 UTC; summary line "16670 passed, 6 skipped in 317.44s (0:05:17)"; 0 failed. JUnit: 16676 tests, 0 failures, 0 errors, 6 skipped.
- Repo-wide (JSON report totals): line 34525 / 35546 = 97.13%; branch 12758 / 13514 = 94.41%.
- Per-file (JSON report): scripts/dev_tools/_parallel_state_records.py: line 191 / 191 = 100.00%, branch 96 / 96 = 100.00%.
- test_parallel_state_scheduling_parity: 25 cases, 0 failed.
- No failing test, so no failure is classified under the Execution Terms.
