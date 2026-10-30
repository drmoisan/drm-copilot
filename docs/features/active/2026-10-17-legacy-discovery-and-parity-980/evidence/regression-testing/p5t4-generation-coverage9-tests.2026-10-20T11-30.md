# P5-T4 generation tests

Timestamp: 2026-10-20T11-30

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.acceptance_generation,drm_copilot_discovery.acceptance_generation_context -m pytest -v --tb=short --maxfail=3 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_acceptance_decisions.py::test_linked_scenario_selection_preserves_defensive_boundaries tests/discovery_runtime/test_acceptance_generation_limits.py::test_missing_reference_revision_rejects_before_output_reservation`

EXIT_CODE: 0

Output Summary: PASS; 20.662 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 4 items

tests/discovery_runtime/test_acceptance_decisions.py::test_linked_scenario_selection_preserves_defensive_boundaries[foreign-owner] PASSED [ 25%]
tests/discovery_runtime/test_acceptance_decisions.py::test_linked_scenario_selection_preserves_defensive_boundaries[coordinate] PASSED [ 50%]
tests/discovery_runtime/test_acceptance_decisions.py::test_linked_scenario_selection_preserves_defensive_boundaries[duplicate] PASSED [ 75%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_missing_reference_revision_rejects_before_output_reservation PASSED [100%]

============================= 4 passed in 18.41s ==============================

```
