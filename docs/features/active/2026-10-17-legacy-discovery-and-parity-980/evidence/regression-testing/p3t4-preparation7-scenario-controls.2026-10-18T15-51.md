# p3t4-preparation7-scenario-controls

Timestamp: 2026-10-18T15-51
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_draft_scenarios.py -k multifeature_scenario or scenario_shared_commit -v -x --junitxml=SCRATCH/issue-980-p3t4-preparation7-scenario-controls.xml
EXIT_CODE: 0
Output Summary: tests/discovery_runtime/test_draft_scenarios.py::test_scenario_shared_commit_and_repeatable_dry_run_have_honest_effects[False] PASSED [100%]; ; - generated xml file: SCRATCH\issue-980-p3t4-preparation7-scenario-controls.xml -; ================= 4 passed, 27 deselected in 80.65s (0:01:20) =================

Working directory: .
Started: 2026-10-18T15:50:03.180548+00:00
Duration seconds: 81.766
Phase: P3-T4 contract and scenario drafting; focused task verification.

## Captured output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 31 items / 27 deselected / 4 selected

tests/discovery_runtime/test_draft_scenarios.py::test_multifeature_scenario_preserves_unknown_expectation_and_linked_question[False] PASSED [ 25%]
tests/discovery_runtime/test_draft_scenarios.py::test_multifeature_scenario_preserves_unknown_expectation_and_linked_question[True] PASSED [ 50%]
tests/discovery_runtime/test_draft_scenarios.py::test_scenario_shared_commit_and_repeatable_dry_run_have_honest_effects[True] PASSED [ 75%]
tests/discovery_runtime/test_draft_scenarios.py::test_scenario_shared_commit_and_repeatable_dry_run_have_honest_effects[False] PASSED [100%]

- generated xml file: SCRATCH\issue-980-p3t4-preparation7-scenario-controls.xml -
================= 4 passed, 27 deselected in 80.65s (0:01:20) =================
```
