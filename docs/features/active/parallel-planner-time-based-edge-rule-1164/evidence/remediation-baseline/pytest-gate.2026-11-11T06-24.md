# pytest Phase 0 Baseline (remediation cycle 1, P0-T5)

Timestamp: 2026-11-11T06-17
Command: sh SCRATCH/issue-1164-pytest-gate.sh baseline (in the item worktree: env -u VIRTUAL_ENV poetry run pytest tests/ -n auto -q -p no:cacheprovider --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1164-cov-r1-baseline.json --junitxml=SCRATCH/issue-1164-pytest-baseline.junit.xml --cov); figures read by SCRATCH/issue-1164-pytest-extract.py
EXIT_CODE: 0
Output Summary:
- Run 2026-11-11T06-17 to 06-22 UTC; summary line "16667 passed, 6 skipped in 304.36s (0:05:04)"; 0 failed. JUnit: 16673 tests, 0 failures, 0 errors, 6 skipped.
- Repo-wide (JSON report totals): line 34525 / 35546 = 97.13%; branch 12759 / 13514 = 94.41%.
- Per-file (JSON report):
  - scripts/dev_tools/_blast_radius_scheduling.py: line 171/171 = 100.00%, branch 40/40 = 100.00%
  - scripts/dev_tools/_parallel_state_records.py: line 191/191 = 100.00%, branch 96/96 = 100.00%
- Named suites (cases, failed): test_blast_radius_access_weights 18, 0; test_parallel_state_scheduling_parity 22, 0; test_push_down_claude_resource_contracts 14, 0; test_parallel_cohort_barrier_parity 33, 0.
- Note: the JSON report was first written to an MSYS /tmp translation of the SCRATCH path and was moved into SCRATCH unchanged before reading.
