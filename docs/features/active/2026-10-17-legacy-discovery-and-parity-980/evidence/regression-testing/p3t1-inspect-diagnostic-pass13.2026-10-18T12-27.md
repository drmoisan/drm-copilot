# p3t1-inspect-diagnostic-pass13

Timestamp: 2026-10-18T12-27
Command: poetry run pytest -o addopts= tests/discovery_runtime/test_mutation_plan.py::test_values_reject_mutability_and_metadata_ambiguity --cov=drm_copilot_discovery.mutation_plan --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t1-inspect-diagnostic.json -q
EXIT_CODE: 0
Output Summary: -------------------------------------------------------------------------------------------------------------------; TOTAL                                                                     149     76     56      3    43%; Coverage JSON written to file SCRATCH/issue-980-p3t1-inspect-diagnostic.json; 1 passed in 2.28s

Working directory: .
Started: 2026-10-18T12:27:15.073787+00:00
Duration seconds: 3.468
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
.                                                                        [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                    Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py     149     76     56      3    43%   47-48, 78, 112, 125, 160-161, 165, 170-175, 189-222, 226, 230-232, 243-247, 283-379
-------------------------------------------------------------------------------------------------------------------
TOTAL                                                                     149     76     56      3    43%
Coverage JSON written to file SCRATCH/issue-980-p3t1-inspect-diagnostic.json
1 passed in 2.28s
```
