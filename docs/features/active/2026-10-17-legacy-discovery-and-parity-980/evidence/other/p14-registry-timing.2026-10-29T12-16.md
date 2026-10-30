# P14-T9 Registry cost and suite durations, before and after

Timestamp: 2026-10-29T12-16
Task: [P14-T9] Record before and after registry cost and suite durations.
Command: poetry run python -m cProfile -o SCRATCH/issue-980-p14-hot-after.prof -m pytest tests/discovery_runtime/test_service_publication.py::test_clean_snapshot_export_publishes_exact_files -p no:cacheprovider; poetry run python SCRATCH/issue-980-p14-profile-summary.py SCRATCH/issue-980-p14-hot-after.prof; poetry run python SCRATCH/issue-980-p14-junit-durations.py SCRATCH/issue-980-p14-junit.xml
EXIT_CODE: 0
Output Summary: After the correction the profiled test passes in 8.51 s (`1 passed in 8.51s`); `_registry` is called once, equal to the one `SchemaCatalog.__post_init__` call, for 0.93 cumulative seconds (before: 327 calls, 348.58 s). The PT suite falls from 17698.97 s to 854.08 s and the full Python run from 17965.16 s to 1046.46 s. Every after value is lower than its before value, and every figure names its source.

## Profiled test (same command, no coverage)

| Figure | Before | After |
| --- | --- | --- |
| pytest result | `1 passed in 356.67s` | `1 passed in 8.51s` |
| `_registry` calls | 327 | 1 |
| `SchemaCatalog.__post_init__` calls | 1 | 1 |
| `_registry` cumulative seconds | 348.58 | 0.93 |
| total profiled seconds | 352.60 | 8.78 |
| source | FEATURE/evidence/baseline/p14-registry-timing-before.2026-10-29T10-18.md (SCRATCH/issue-980-p14-hot-before.prof) | SCRATCH/issue-980-p14-hot-after.prof, this run |

The summary helper selects `SchemaCatalog.__post_init__` by the starting line `inspect.getsourcelines` reports at run time; it moved because the correction added the `field` import and the shared-registry field above it.

## Suite durations (coverage mode for both sides of each pair)

| Figure | Before | After |
| --- | --- | --- |
| PT suite (`tests.discovery_runtime` classnames), summed testcase seconds | 17698.97 s over 6115 testcases (measured) | 854.08 s over 6120 testcases (measured) |
| All testcases in the JUnit file, summed seconds | 17939.35 s over 15663 testcases | 1016.72 s over 15674 testcases |
| Full Python run, pytest wall-clock | 17965.16 s (`15657 passed, 6 skipped`) | 1046.46 s (`15668 passed, 6 skipped`) |
| source | P13-T1: SCRATCH/issue-980-p13t1-junit.xml and FEATURE/evidence/qa-gates/p13-python-tests.2026-10-29T05-28.md | P14-T6: SCRATCH/issue-980-p14-junit.xml and FEATURE/evidence/qa-gates/p14-python-tests.2026-10-29T10-44.md |

No pair uses an orchestrator-reported value: the P13-T1 JUnit file was available, so the PT before value is measured. The PT testcase count grew by 5: the three P14-T2 tests, the P14-T3 test, and one further discovery-runtime case present in the tree at P14-T6. The full run took 5.8% of its earlier wall-clock time (17 min 26 s).

Result: PASS
