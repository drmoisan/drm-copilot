# Python batch 3 expected-red coverage

Timestamp: 2026-08-12T10:28:50.255Z

Command: `$env:COVERAGE_FILE='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/.coverage-python-batch-3-red'; poetry run pytest -o "addopts=" -q tests/scripts/dev_tools/test_resolve_codex_deployment.py tests/scripts/dev_tools/test_resolve_codex_topology.py -k "parallel_persona_context_seam or parallel_root_context_seam" --cov=scripts.dev_tools.resolve_codex_deployment --cov=scripts.dev_tools.resolve_codex_topology --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/python-batch-3-coverage-red.json`

EXIT_CODE: 1

Output Summary: 2 failed and 70 deselected. Combined line coverage was 40% across 198 statements, with 118 statements missing. The canonical JSON report was written beside this evidence file.

## Exact uncovered-line mappings

- `scripts/dev_tools/resolve_codex_deployment.py` -> `tests/scripts/dev_tools/test_resolve_codex_deployment.py`: 43%; missing `145-147, 153-158, 167-175, 183-184, 206-254, 270-281, 287-295`.
- `scripts/dev_tools/resolve_codex_topology.py` -> `tests/scripts/dev_tools/test_resolve_codex_topology.py`: 38%; missing `126-131, 137-142, 148-153, 159-160, 175, 211-303, 322-333, 339-349`.

Acceptance result: PASS as expected-red. Each numeric deficit maps to its owning production path and P5-T1 test owner before any batch-3 production edit.
