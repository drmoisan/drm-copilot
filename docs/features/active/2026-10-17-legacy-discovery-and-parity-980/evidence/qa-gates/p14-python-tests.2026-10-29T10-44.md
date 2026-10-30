# P14-T6 Python test gate with coverage on the corrected, rebased tree

Timestamp: 2026-10-29T10-44
Task: [P14-T6] Re-run the Python formatting, lint, type and full coverage loop on the corrected, rebased tree.
Command: poetry run pytest --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p14-coverage.json --junitxml=SCRATCH/issue-980-p14-junit.xml -p no:cacheprovider --cov; poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report SCRATCH/issue-980-p14-coverage.json --min-line 85 --min-branch 75
EXIT_CODE: 0 (pytest), 0 (threshold gate)
Output Summary: `15668 passed, 6 skipped in 1046.46s (0:17:26)` over the complete `tests` population, 0 failed, 0 errors; run from 2026-10-29T10-25 to 10-43 UTC. JSON report totals: lines 31988/33080 (96.70%), branches 11644/12438 (93.62%), above the 85% line and 75% branch floors. Terminal TOTAL row `33080 1092 12438 550 96%`. The CI threshold gate exits 0.

## Notes

- The six skips are the same six pre-existing `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` manifest cases as in P13-T1.
- Compared with P13-T1 (`p13-python-tests.2026-10-29T05-28.md`: 15657 passed in 17965.16s), the population grew by 11 tests: 5 are the 3 P14-T2 tests, the P14-T3 test and the P14-T5 brief contract test; the other 6 were added to the tree between the P13-T1 run and the Phase 14 revision commit (not individually attributed here). Wall-clock time fell from 17965.16 s to 1046.46 s.
- `packages/discovery-runtime/src/drm_copilot_discovery/catalog.py`: lines 168/168, branches 82/82 (100%).
- Coverage-report path: the first threshold invocation reported that the JSON report could not be read, because the launcher passed a POSIX-style SCRATCH path inside the `--cov-report=json:` value and coverage.py wrote the report under a drive-root `tmp` directory. The report file was moved into SCRATCH unchanged and the threshold gate was re-run against it (exit 0). No test was re-run and no figure was altered; the launcher now resolves SCRATCH as a Windows path.

Result: PASS
