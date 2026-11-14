# pytest Gate (remediation cycle 2, P2-T4)

Timestamp: 2026-11-13T16-32
Command: sh SCRATCH/issue-1164-pytest-gate.sh issue-1164-cov-r2-final (in the item worktree: env -u VIRTUAL_ENV poetry run pytest tests/ -n auto -q -p no:cacheprovider --junitxml=SCRATCH/issue-1164-cov-r2-final.junit.xml --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1164-cov-r2-final.json --cov); figures read from the JSON report and JUnit file by SCRATCH/issue-1164-pytest-fig.ps1
EXIT_CODE: 0
Output Summary:
- Run on head 7d36a5e8c; 2026-11-13T16-28-40 to 16-31-54 UTC; summary line "16676 passed, 6 skipped in 190.34s (0:03:10)"; 0 failed. JUnit: 16682 tests, 0 failures, 0 errors, 6 skipped (P0-T4: 16670 passed, 0 failed; +6 are the P1-T3 stems).
- Repo-wide (JSON report totals): line 34525 / 35546 = 97.13%; branch 12758 / 13514 = 94.41% (P0-T4 equal; no drop).
- Per-file: scripts/dev_tools/_parallel_state_records.py: line 191 / 191 = 100.00%, branch 96 / 96 = 100.00% (P0-T4 equal; no drop).
- test_parallel_state_scheduling_parity.py: 31 cases, 0 failed; the six P1-T3 stems pass as test_validator_reproduces_the_expected_errors cases (newline, tab, control, backslash, non-printable, apostrophe-newline).
- test_push_down_claude_resource_contracts.py: 14 cases, 0 failed.
