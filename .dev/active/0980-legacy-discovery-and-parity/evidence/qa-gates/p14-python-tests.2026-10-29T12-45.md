# P14-T6 Python test gate with coverage on the final tree (repeat after P14-T12)

Timestamp: 2026-10-29T12-45
Task: [P14-T6] Re-run the Python formatting, lint, type and full coverage loop on the corrected, rebased tree.
Command: poetry run pytest --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p14r2-coverage.json --junitxml=SCRATCH/issue-980-p14r2-junit.xml -p no:cacheprovider --cov; poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report SCRATCH/issue-980-p14r2-coverage.json --min-line 85 --min-branch 75
EXIT_CODE: 0 (pytest), 0 (threshold gate)
Output Summary: `15668 passed, 6 skipped in 929.37s (0:15:29)` over the complete `tests` population, 0 failed, 0 errors; run from 2026-10-29T12-28 to 12-44 UTC. JSON report totals: lines 31988/33080 (96.70%), branches 11644/12438 (93.62%), above the 85% line and 75% branch floors. Terminal TOTAL row `33080 1092 12438 550 96%`. The CI threshold gate exits 0 (it prints nothing on success).

## Why the loop was repeated

P14-T12 regenerated `packages/discovery-runtime/src/drm_copilot_discovery/_build_manifest.json`, a generated production resource of the runtime package, after the first P14-T6 run (`p14-python-tests.2026-10-29T10-44.md`). The plan's `## Revision: schema-registry memoization and final-QA re-run` section requires the affected loop to be repeated when a later task changes a production file, so the full Python loop ran again from formatting on the final tree. The results equal the first run (same pass count, same coverage totals); the wall-clock time is 929.37 s against 1046.46 s for the first run. This record supersedes the first-run record as the final Python evidence.

## Notes

- The six skips are the same six pre-existing `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` manifest cases as in P13-T1.
- `packages/discovery-runtime/src/drm_copilot_discovery/catalog.py`: lines 168/168, branches 82/82 (100%).
- The SCRATCH path passed to coverage.py is a Windows path in this run, so the JSON report was written in place.

Result: PASS
