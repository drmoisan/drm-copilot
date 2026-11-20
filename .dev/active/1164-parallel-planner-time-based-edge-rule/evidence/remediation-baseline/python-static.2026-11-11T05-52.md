# Python Static Baseline (remediation cycle 1, P0-T2)

Timestamp: 2026-11-11T05-50
Command: sh SCRATCH/issue-1164-py-static.sh (in the item worktree: env -u VIRTUAL_ENV poetry run black --check; ruff check; pyright) over tests/scripts/dev_tools/test_blast_radius_access_weights.py, tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py, scripts/dev_tools/_blast_radius_scheduling.py; then grep -c reportPrivateUsage over the test file
EXIT_CODE: 0
Output Summary:
- Black --check: exit 0, "3 files would be left unchanged." Finding count 0.
- Ruff check: exit 0, "All checks passed!" Finding count 0.
- Pyright: exit 0, "0 errors, 0 warnings, 0 informations". Finding count 0.
- reportPrivateUsage suppression comments in tests/scripts/dev_tools/test_blast_radius_access_weights.py: 1 (grep -c reportPrivateUsage).
