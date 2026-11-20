# pytest Gate, Correction (remediation P2-T5)

Timestamp: 2026-11-10T02-46
Command: sh SCRATCH/issue-1164-pytest-gate.sh (env -u VIRTUAL_ENV poetry run pytest tests/ -n auto -q -p no:cacheprovider --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1164-cov-correction.json --junitxml=SCRATCH/issue-1164-pytest-correction.junit.xml --cov)
EXIT_CODE: 0
Output Summary:
- Run started 2026-11-10T02-42 (UTC); summary line "16659 passed, 6 skipped in 158.17s (0:02:38)"; 0 failed. JUnit: 16665 tests, 0 failures, 0 errors, 6 skipped.
- The JSON report landed under a host-translated copy of the SCRATCH path, because the POSIX-form path was passed to a Windows Python; it was read from there. The terminal table of the same run gives the same per-file figures.
- Repo-wide (JSON report totals): line 34525 / 35546 = 97.13% (P0-T1 baseline 97.13%); branch 12758 / 13514 = 94.41% (P0-T1 baseline 94.41%). No drop.
- Per-file (JSON report), against P0-T1 (every value unchanged, no drop):
  - scripts/dev_tools/_parallel_state_records.py: line 191/191 = 100.00%, branch 96/96 = 100.00% (baseline 100.00% / 100.00%)
  - scripts/dev_tools/parallel_manifest_contract.py: line 168/168 = 100.00%, branch 82/82 = 100.00% (baseline 100.00% / 100.00%)
  - scripts/dev_tools/_blast_radius_scheduling.py: line 171/171 = 100.00%, branch 40/40 = 100.00% (baseline 100.00% / 100.00%)
  - scripts/dev_tools/_parallel_drift_scheduling.py: line 47/47 = 100.00%, branch 18/18 = 100.00% (baseline 100.00% / 100.00%)
- Named suites (JUnit): test_parallel_state_scheduling_parity.py 22 cases, 0 failed; test_parallel_manifest_bash_parity.py 133 cases, 0 failed, 5 skipped; test_blast_radius_access_weights.py 18 cases, 0 failed.
