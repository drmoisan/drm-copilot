# Pytest Phase 0 Baseline ([P0-T3])

Timestamp: 2026-11-08T18-57
Command: sh SCRATCH/issue-1139-pytest.sh (from the worktree root: env -u VIRTUAL_ENV poetry install; env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1139-pytest-baseline.json --cov --junitxml=SCRATCH/issue-1139-pytest-baseline.json.junit.xml)
EXIT_CODE: 0
Output Summary: Phase 0 baseline, one pytest -n auto run with coverage. Install exit code 0 ("No dependencies to install or update" path; lock file installed). Pytest exit code 0; summary "16560 passed, 6 skipped in 312.78s (0:05:12)"; failed 0. Failing node IDs: none. Repo-wide totals from the JSON report: lines 34296/35317 = 97.11%; branches 12648/13404 = 94.36%; combined percent_covered 96.35% (terminal TOTAL row 96%).

## Notes

- The run started at 2026-11-08T18-57 UTC and ended at 2026-11-08T19-02 UTC (clock reads written by the launcher).
- The JSON report path was given in the POSIX `/c/...` spelling, so the Windows Python process wrote it beneath an extra `c` directory segment; the file was moved into SCRATCH before it was read. The figures above come from that file. The launcher now converts the SCRATCH path to the Windows spelling before the final gate.
