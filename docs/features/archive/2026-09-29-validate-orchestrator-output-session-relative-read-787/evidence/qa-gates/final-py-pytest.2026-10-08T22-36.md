# Final Python Tests with Coverage (P6-T14), pass 1

Timestamp: 2026-10-08T22-36

Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/py-coverage-final.json
EXIT_CODE: 0
Output Summary:
- Summary line: `6633 passed, 6 skipped in 114.67s (0:01:54)` (6603 at baseline + 30 PYLANE nodes)
- Terminal TOTAL row: `TOTAL 17556 1104 6338 562 92%`
- Failed node ids: none (the failed-node set is empty, a subset of the empty P0-T29 baseline set)
- PYLANE: all 30 nodes of `tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py` passed (no failure in the run)
- The six SKIPPED nodes are the same six as at baseline (test_blast_radius_regression_452.py and five test_parallel_manifest_bash_parity.py cases)

Command: sh SCRATCH/run-ps.sh SCRATCH/py-coverage-totals.ps1 -Path SCRATCH/py-coverage-final.json
EXIT_CODE: 0
Output Summary: PY-COVERAGE LinePercent=93.71 BranchPercent=87.16 CombinedPercent=91.97

Result: PASS.
