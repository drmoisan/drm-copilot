# p3t1-inspect-boundary-pass13

Timestamp: 2026-10-18T12-27
Command: poetry run pytest -o addopts= tests/discovery_runtime/test_mutation_plan.py::test_values_reject_mutability_and_metadata_ambiguity tests/discovery_runtime/test_mutation_plan.py::test_planner_projects_complete_valid_graph_and_preserves_originals --cov=drm_copilot_discovery.mutation_plan --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t1-inspect-boundary.json -q
EXIT_CODE: 0
Output Summary: -------------------------------------------------------------------------------------------------------------------; TOTAL                                                                     149     24     56     13    79%; Coverage JSON written to file SCRATCH/issue-980-p3t1-inspect-boundary.json; 2 passed in 10.45s

Working directory: .
Started: 2026-10-18T12:27:36.003219+00:00
Duration seconds: 12.793
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
..                                                                       [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                    Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py     149     24     56     13    79%   47-48, 78, 125, 160-161, 165, 170-175, 231, 284, 305, 315, 318, 328, 332, 356, 358, 365, 374
-------------------------------------------------------------------------------------------------------------------
TOTAL                                                                     149     24     56     13    79%
Coverage JSON written to file SCRATCH/issue-980-p3t1-inspect-boundary.json
2 passed in 10.45s
```
