# P14-T1 Registry cost on the uncorrected tree

Timestamp: 2026-10-29T10-18
Task: [P14-T1] Measure the registry cost on the uncorrected tree.
Command: poetry run python -m cProfile -o SCRATCH/issue-980-p14-hot-before.prof -m pytest tests/discovery_runtime/test_service_publication.py::test_clean_snapshot_export_publishes_exact_files -p no:cacheprovider; poetry run python SCRATCH/issue-980-p14-profile-summary.py SCRATCH/issue-980-p14-hot-before.prof; poetry run python SCRATCH/issue-980-p14-junit-durations.py SCRATCH/issue-980-p13t1-junit.xml
EXIT_CODE: 0
Output Summary: Profiled test passed (`1 passed in 356.67s (0:05:56)`). `_registry` was called 327 times for 348.58 cumulative seconds, against 1 call of `SchemaCatalog.__post_init__`, out of 352.60 total profiled seconds. The `_registry` call count exceeds the `SchemaCatalog.__post_init__` call count, which demonstrates the per-validation rebuild.

Tree: HEAD of feature/legacy-discovery-and-parity-980 before any Phase 14 code change (Phase 14 plan revision commit); the profile run started at 2026-10-29T10-11 UTC.

## Profiled test (measured)

| Figure | Value | Source |
| --- | --- | --- |
| pytest result | `1 passed in 356.67s (0:05:56)` | profile run above |
| `_registry` calls | 327 | SCRATCH/issue-980-p14-hot-before.prof via the summary helper |
| `_registry` cumulative seconds | 348.58 | same |
| `SchemaCatalog.__post_init__` calls | 1 | same; entry selected by the runtime starting line that `inspect.getsourcelines` reports for `SchemaCatalog.__post_init__` |
| total profiled seconds | 352.60 | same |

The helper selects `_registry` and `SchemaCatalog.__post_init__` in `drm_copilot_discovery/catalog.py` by function name and by the starting line reported at run time, so the `ExtensionSchema.__post_init__` entry in the same module is excluded.

## Suite before values (measured, coverage mode)

| Figure | Value | Source |
| --- | --- | --- |
| Full Python run | 17965.16 s (`15657 passed, 6 skipped` in 4:59:25) | lexicographically greatest FEATURE/evidence/qa-gates/p13-python-tests.*.md (p13-python-tests.2026-10-29T05-28.md) |
| PT suite (`tests.discovery_runtime` classnames) | 17698.97 s over 6115 testcases | SCRATCH/issue-980-p13t1-junit.xml (the P13-T1 run) summed by SCRATCH/issue-980-p14-junit-durations.py |
| All testcases in the same JUnit file | 17939.35 s over 15663 testcases | same |

SCRATCH/issue-980-p13t1-junit.xml exists, so the PT suite before value is measured, not orchestrator-reported. The PT suite holds 98.7% of the summed testcase time of the P13-T1 run.

Result: PASS
