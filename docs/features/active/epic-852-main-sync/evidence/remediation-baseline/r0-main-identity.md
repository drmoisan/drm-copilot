# Baseline Identity Against Main Tip daa6436cd

Timestamp: 2026-10-11T01-17
Task: [P0-T6]
Command: git diff --quiet daa6436cd37c05ff0348f74939c1e24afd1bac48 HEAD -- extensions/drm-copilot/src extensions/drm-copilot/test extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/tsconfig.jest.json extensions/drm-copilot/package.json; git diff --quiet daa6436cd37c05ff0348f74939c1e24afd1bac48 HEAD -- '*.py' pyproject.toml poetry.lock
EXIT_CODE: 0

TS_IDENTITY_EXIT: 0
PY_IDENTITY_EXIT: 1

Context for PY_IDENTITY_EXIT (informational, from `git diff --name-only daa6436cd37c05ff0348f74939c1e24afd1bac48 HEAD -- '*.py' pyproject.toml poetry.lock`): the differing paths are test files only:

- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
- `tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py`

No production `.py` file, `pyproject.toml`, or `poetry.lock` differs from main tip. Per the Verdict Rules, PY_IDENTITY_EXIT 1 means the NO-REGRESSION path is not available for Python per-file rows.

Output Summary: TS inputs are byte-identical to main tip (exit 0). Python inputs differ (exit 1; two test files). Both values recorded; EXIT_CODE 0 refers to the recording step.
