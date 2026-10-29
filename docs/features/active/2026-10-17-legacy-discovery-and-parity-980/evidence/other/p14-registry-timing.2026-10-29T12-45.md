# P14-T9 Registry cost and suite durations, before and after (refreshed after the repeated P14-T6)

Timestamp: 2026-10-29T12-45
Task: [P14-T9] Record before and after registry cost and suite durations.
Command: poetry run python SCRATCH/issue-980-p14-junit-durations.py SCRATCH/issue-980-p14r2-junit.xml (suite after values from the repeated P14-T6 run); profile figures carried from `p14-registry-timing.2026-10-29T12-16.md` (poetry run python -m cProfile -o SCRATCH/issue-980-p14-hot-after.prof -m pytest tests/discovery_runtime/test_service_publication.py::test_clean_snapshot_export_publishes_exact_files -p no:cacheprovider; poetry run python SCRATCH/issue-980-p14-profile-summary.py SCRATCH/issue-980-p14-hot-after.prof)
EXIT_CODE: 0
Output Summary: The after profile builds the registry once (`_registry` calls 1, equal to `SchemaCatalog.__post_init__` calls 1) for 0.93 cumulative seconds, against 327 builds and 348.58 s before. In the final full run the PT suite takes 768.46 s against 17698.97 s before, and the full Python run 929.37 s against 17965.16 s. Every after value is lower than its before value, and every figure names its source. This record supersedes `p14-registry-timing.2026-10-29T12-16.md`, whose suite after values came from the first P14-T6 run. The Python loop was repeated after P14-T12 regenerated `_build_manifest.json`.

## Profiled test (same command, no coverage)

The profile is unaffected by the repeat: the regenerated `_build_manifest.json` changes no Python code that the profiled test executes, and the profile was taken on the same catalog code.

| Figure | Before | After |
| --- | --- | --- |
| pytest result | `1 passed in 356.67s` | `1 passed in 8.51s` |
| `_registry` calls | 327 | 1 |
| `SchemaCatalog.__post_init__` calls | 1 | 1 |
| `_registry` cumulative seconds | 348.58 | 0.93 |
| total profiled seconds | 352.60 | 8.78 |
| source | FEATURE/evidence/baseline/p14-registry-timing-before.2026-10-29T10-18.md (SCRATCH/issue-980-p14-hot-before.prof) | SCRATCH/issue-980-p14-hot-after.prof (`p14-registry-timing.2026-10-29T12-16.md`) |

## Suite durations (coverage mode for both sides of each pair)

| Figure | Before | After (final run) | After (first P14-T6 run, for reference) |
| --- | --- | --- | --- |
| PT suite (`tests.discovery_runtime` classnames), summed testcase seconds | 17698.97 s over 6115 testcases | 768.46 s over 6120 testcases | 854.08 s over 6120 testcases |
| All testcases in the JUnit file, summed seconds | 17939.35 s over 15663 testcases | 905.61 s over 15674 testcases | 1016.72 s over 15674 testcases |
| Full Python run, pytest wall-clock | 17965.16 s (`15657 passed, 6 skipped`) | 929.37 s (`15668 passed, 6 skipped`) | 1046.46 s (`15668 passed, 6 skipped`) |
| source | P13-T1: SCRATCH/issue-980-p13t1-junit.xml and `p13-python-tests.2026-10-29T05-28.md` | repeated P14-T6: SCRATCH/issue-980-p14r2-junit.xml and `p14-python-tests.2026-10-29T12-45.md` | first P14-T6: SCRATCH/issue-980-p14-junit.xml and `p14-python-tests.2026-10-29T10-44.md` |

All before values are measured; none is orchestrator-reported. The final full run took 5.2% of its earlier wall-clock time (15 min 29 s). The difference between the two after runs (1046.46 s and 929.37 s) is run-to-run variation on the same code and test population.

Result: PASS
